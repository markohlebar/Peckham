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
}

+ (instancetype)sharedCache {
    static MHHeaderCache *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (BOOL) shouldReloadHeadersForTarget:(XCTarget *)target {
    return ![self.currentTarget.name isEqualToString:target.name] ||
            [self.lastModifiedDate compare:[target.project dateModified]] != NSOrderedSame;
}

- (void)setCurrentTarget:(XCTarget *)currentTarget {
    _currentTarget = currentTarget;
    self.lastModifiedDate = [currentTarget.project dateModified];
    [self reloadHeaders];
}

- (void)reloadHeaders {
    [self reloadFrameworkHeaders];
    [self reloadProjectHeaders];
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

- (void) reloadHeadersIfNeeded {
    XCTarget *target = [MHXcodeDocumentNavigator currentTarget];
    if ([self shouldReloadHeadersForTarget:target]) {
        self.currentTarget = target;
    }
}

- (NSArray *)frameworkHeaders {
    [self reloadHeadersIfNeeded];
    return _frameworkHeaders;
}

- (NSArray *)projectHeaders {
    [self reloadHeadersIfNeeded];
    return _projectHeaders;
}

@end
