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
#import "XCProject+NSDate.h"

NSString *const MHHeaderCacheFrameworksSubPath = @"/System/Library/Frameworks";

@interface MHHeaderCache ()
@property (nonatomic, strong) XCTarget *currentTarget;
@property (nonatomic, strong) NSDate *lastModifiedDate;
@end

@implementation MHHeaderCache {
    NSArray *_projectHeaders;
    NSArray *_frameworkHeaders;
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
    NSArray *headers = [self.currentTarget.project.headerFiles valueForKey:@"pathRelativeToProjectRoot"];
    //remove .pch files
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS[c] %@)", @".pch"];
    headers = [headers filteredArrayUsingPredicate:predicate];
    _projectHeaders = [headers sortedArrayUsingSelector:@selector(compare:)];
}

- (BOOL)isProjectHeader:(NSString *)header {
    return [_projectHeaders containsObject:header];
}

- (BOOL)isFrameworkHeader:(NSString *)header {
    return [_frameworkHeaders containsObject:header];
}

- (NSArray *) allHeaders {
    return [_projectHeaders arrayByAddingObjectsFromArray:_frameworkHeaders];
}

- (void)loadHeaders:(MHArrayBlock)headersBlock {
    
    XCTarget *target = [MHXcodeDocumentNavigator currentTarget];
    if ([self shouldReloadHeadersForTarget:target]) {
        self.currentTarget = target;
        
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            [self reloadProjectHeaders];
            dispatch_async(dispatch_get_main_queue(), ^{
                headersBlock([self allHeaders]);
            });
        }];
        [_operationQueue addOperation:operation];
        
        operation = [NSBlockOperation blockOperationWithBlock:^{
            [self reloadFrameworkHeaders];
            dispatch_async(dispatch_get_main_queue(), ^{
                headersBlock([self allHeaders]);
            });
        }];
        [_operationQueue addOperation:operation];
    } else {
        headersBlock([self allHeaders]);
    }
}

@end
