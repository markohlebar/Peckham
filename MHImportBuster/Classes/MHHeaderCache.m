//
//  MHHeaderCache.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHHeaderCache.h"
#import "MHInterfaceStatement.h"
#import "MHStatementParser.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSArray+MHStatement.h"
#import "NSFileManager+Headers.h"
#import "XCTarget+XCProject.h"
#import "XCWorkspace.h"
#import "MHImportStatement+Construction.h"
#import "XcodeEditor.h"
#import "XCBuildSettings.h"
#import "XCProject+Extensions.h"
#import "XCProject+SubProject.h"

NSString *const MHHeaderCacheFrameworksSubPath = @"/System/Library/Frameworks";

@interface MHHeaderCache ()
@property (nonatomic, strong) XCTarget *currentTarget;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, copy) MHArrayBlock headersBlock;
@end

@implementation MHHeaderCache {
    NSArray *_projectHeaders;
    NSArray *_frameworkHeaders;
    NSArray *_userHeaders;

    NSOperationQueue *_operationQueue;
}

+ (instancetype)sharedCache {
    static MHHeaderCache *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _projectHeaders = [NSArray new];
        _frameworkHeaders = [NSArray new];
        _userHeaders = [NSArray new];
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}

- (BOOL) shouldReloadHeadersForTarget:(XCTarget *)target {
    return ![self.currentTarget.name isEqualToString:target.name] ||
            [self.lastModifiedDate compare:[target.project dateModified]] != NSOrderedSame ||
            _projectHeaders.count == 0 ||
            _frameworkHeaders.count == 0;
}

- (void)setCurrentTarget:(XCTarget *)currentTarget {
    _currentTarget = currentTarget;
    self.lastModifiedDate = [currentTarget.project dateModified];
}

- (NSArray *)allFrameworksForTarget:(XCTarget *) target {
    NSMutableArray *frameworkPaths = [NSMutableArray array];
    NSArray *names = [[target frameworks] valueForKey:@"name"];
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        NSString *frameworkPath = [MHXcodeDocumentNavigator pathForFrameworkNamed:name];
        if(frameworkPath) [frameworkPaths addObject:frameworkPath];
    }];
    
    return [NSSet setWithArray:frameworkPaths].allObjects;
}

- (void)reloadFrameworkHeaders {
    NSArray *frameworkPaths = [self allFrameworksForTarget:self.currentTarget];
    __block NSMutableArray *allHeaderPaths = [NSMutableArray array];
    [frameworkPaths enumerateObjectsUsingBlock:^(NSString *frameworkPath, NSUInteger idx, BOOL *stop) {
        NSString *headersDirectory = [frameworkPath stringByAppendingPathComponent:@"Headers/"];
        NSArray *headerPaths = [NSFileManager findFilesWithExtension:@"h" inDirectory:headersDirectory];
        [allHeaderPaths addObjectsFromArray:headerPaths];
    }];
    _frameworkHeaders = [allHeaderPaths sortedArrayUsingSelector:@selector(compare:)];
}

- (void) reloadProjectHeaders {
    NSMutableArray *allHeaders = [NSMutableArray array];
    
    XCBuildSettings *buildSettings = [XCBuildSettings buildSettingsWithTarget:self.currentTarget];
    //project, header search paths, user header search paths
    NSString *projectPath = [buildSettings valueForKey:XCBuildSettingsProjectDirKey];
    
    if(projectPath) {
        NSArray *projectHeaders = [NSFileManager findFilesWithExtension:@"h"
                                                            inDirectory:projectPath];
        [allHeaders addObjectsFromArray:projectHeaders];
    }
    else {
        NSLog(@"PROJECT PATH NOT FOUND");
        NSLog(@"%@", buildSettings.settings);
    }
    
    NSArray *headerSearchPaths = [buildSettings valueForKey:XCBuildSettingsHeaderSearchPathsKey];
    if ([headerSearchPaths isKindOfClass:[NSString class]]) headerSearchPaths = @[headerSearchPaths];
    [headerSearchPaths enumerateObjectsUsingBlock:^(NSString *headerSearchPath, NSUInteger idx, BOOL *stop) {
        _userHeaders =[NSFileManager findFilesWithExtension:@"h"
                                                inDirectory:headerSearchPath];
    }];
    
    NSArray *userHeaderSearchPaths = [buildSettings valueForKey:XCBuildSettingsUserHeaderSearchPathsKey];
    if ([userHeaderSearchPaths isKindOfClass:[NSString class]]) userHeaderSearchPaths = @[userHeaderSearchPaths];
    [userHeaderSearchPaths enumerateObjectsUsingBlock:^(NSString *headerSearchPath, NSUInteger idx, BOOL *stop) {
        NSArray *headers =[NSFileManager findFilesWithExtension:@"h"
                                                    inDirectory:headerSearchPath];
        [allHeaders addObjectsFromArray:headers];
    }];
    
    //This solves the problem of having 2 of the same files in different places in project (CocoaPods),
    //but might potentially introduce some other issues
    __block NSMutableArray *filteredHeaders = [NSMutableArray new];
    [allHeaders enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
        if (![self array:filteredHeaders containsStringWithLastPathComponent:[path lastPathComponent]]) {
            [filteredHeaders addObject:path];
        }
    }];
    
    _projectHeaders = [filteredHeaders sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1.lastPathComponent compare:obj2.lastPathComponent];
    }];
}

- (BOOL) array:(NSArray *) array containsStringWithLastPathComponent:(NSString *)lastPathComponent {
    __block BOOL contains = NO;
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if([obj rangeOfString:lastPathComponent].location != NSNotFound) {
            contains = YES;
            *stop = YES;
        }
    }];
    return contains;
}

- (BOOL)isProjectHeader:(NSString *)header {
    return [_projectHeaders containsObject:header];
}

- (BOOL)isFrameworkHeader:(NSString *)header {
    return [_frameworkHeaders containsObject:header];
}

- (BOOL)isUserHeader:(NSString *)header {
    return [_userHeaders containsObject:header];
}

- (NSArray *) allHeaders {
    NSMutableArray *allHeaders = [NSMutableArray array];
    [allHeaders addObjectsFromArray:_projectHeaders];
    [allHeaders addObjectsFromArray:_userHeaders];
    [allHeaders addObjectsFromArray:_frameworkHeaders];
    return allHeaders.copy;
}

- (void)loadHeaders:(MHArrayBlock)headersBlock {
    self.headersBlock = headersBlock;

    XCTarget *target = [MHXcodeDocumentNavigator currentTarget];
    
    if ([self shouldReloadHeadersForTarget:target]) {
        self.currentTarget = target;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self reloadProjectHeaders];
            [self notifyAllHeaders];
        }];
        operation.queuePriority = NSOperationQueuePriorityVeryHigh;
        operation.threadPriority = 1;
        [_operationQueue addOperation:operation];
        
        operation = [NSBlockOperation blockOperationWithBlock:^{
            [self reloadFrameworkHeaders];
            [self notifyAllHeaders];
        }];
        [_operationQueue addOperation:operation];
    } else {
        [self notifyAllHeaders];
    }
}

- (void)notifyAllHeaders {
    if (self.headersBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headersBlock([self allHeaders]);
        });
    }
}

@end
