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
#import <XcodeEditor/XCBuildConfiguration.h>
#import "NSObject+MHLogMethods.h"
#import "XCSourceFile+Equality.h"

@interface MHHeaderCache ()
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, copy) MHHeaderLoadingBlock headersBlock;
@property (nonatomic, copy) XCTarget *currentTarget;
@property (nonatomic, strong) NSMutableArray *projectHeaders;

@property (nonatomic, strong) NSMapTable *workspacesMapTable;
@property (nonatomic, strong) NSMutableDictionary *workspaceCacheDictionary;
@end

@implementation MHHeaderCache {
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
        _projectHeaders = [NSMutableArray new];
        _frameworkHeaders = [NSArray new];
        _userHeaders = [NSArray new];
        _operationQueue = [NSOperationQueue new];
        _operationQueue.maxConcurrentOperationCount = 1;
        _workspacesMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                                    valueOptions:NSPointerFunctionsStrongMemory];
        _workspaceCacheDictionary = [NSMutableDictionary new];
        
        [self addObservers];
    }
    return self;
}

- (void) addObservers {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(projectDidOpen:)
                               name:@"PBXProjectDidOpenNotification"
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(projectDidChange:)
                               name:@"PBXProjectDidChangeNotification"
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(projectDidClose:)
                               name:@"PBXProjectDidCloseNotification"
                             object:nil];
}

- (BOOL)shouldReloadHeadersForTarget:(XCTarget *)target {
    return ![self.currentTarget.name isEqualToString:target.name] ||
            [self.lastModifiedDate compare:[target.project dateModified]] != NSOrderedSame ||
            _projectHeaders.count == 0 ||
            _userHeaders.count == 0 ||
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

- (BOOL)isProjectHeader:(XCSourceFile *)header {
    return [_projectHeaders containsObject:header];
}

- (BOOL)isFrameworkHeader:(XCSourceFile *)header {
    return [_frameworkHeaders containsObject:header];
}

- (BOOL)isUserHeader:(NSString *)header {
    return [_userHeaders containsObject:header];
}

- (NSArray *) allHeaders {
    NSMutableArray *allHeaders = [NSMutableArray array];
    [allHeaders addObjectsFromArray:_projectHeaders];
    [allHeaders addObjectsFromArray:_frameworkHeaders];
    return allHeaders.copy;
}

- (void)loadHeaders:(MHHeaderLoadingBlock)headersBlock {
    self.headersBlock = headersBlock;
    [self asyncReloadHeaders];
}

- (void)asyncReloadHeaders {
    self.currentTarget = [MHXcodeDocumentNavigator currentTarget];

    [self.projectHeaders removeAllObjects];
    
    NSBlockOperation *operation = nil;
    operation = [self sortProjectHeadersOperationWithCompletion:^{
        [self notifyAllHeaders];
    }];
    [_operationQueue addOperation:operation];
}

- (BOOL) isDoneLoading {
    return _operationQueue.operationCount == 0;
}

- (void)notifyAllHeaders {
    if (self.headersBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headersBlock([self allHeaders], self.isDoneLoading);
        });
    }
}

#pragma mark - Workspace Handling

- (XCWorkspace *)currentWorkspace {
    NSString *workspacePath = [MHXcodeDocumentNavigator currentWorkspacePath];
    if (!workspacePath) return nil;
    XCWorkspace *workspace = _workspaceCacheDictionary[workspacePath];
    if (!workspace) {
        workspace = [XCWorkspace workspaceWithFilePath:workspacePath];
        _workspaceCacheDictionary[workspacePath] = workspace;
    }
    
    return workspace;
}

- (NSMapTable *)projectsMapTableForWorkspace:(XCWorkspace *)workspace {
    NSMapTable *mapTable = [_workspacesMapTable objectForKey:workspace];
    if (!mapTable) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                         valueOptions:NSPointerFunctionsStrongMemory];
        [_workspacesMapTable setObject:mapTable forKey:workspace];
    }
    return mapTable;
}

- (NSMapTable *)projectsMapTable {
    return [self projectsMapTableForWorkspace:self.currentWorkspace];
}

#pragma mark - Projects handling 

- (XCProject *)cachedProjectWithPath:(NSString *)path {
    __block XCProject *project = nil;
    
    [self.projectsMapTable.keyEnumerator.allObjects enumerateObjectsUsingBlock:
     ^(XCProject *cachedProject, NSUInteger idx, BOOL *stop) {
        if ([cachedProject isKindOfClass:[XCProject class]] &&
            [cachedProject.filePath isEqualToString:path]) {
            project = cachedProject;
            *stop = YES;
        }
    }];
    return project;
}

- (void)updateProjectWithPath:(NSString *)path {
    [self removeProjectWithPath:path];
    
    XCProject *project = [XCProject projectWithFilePath:path];
    [self.projectsMapTable setObject:project.headerFiles
                          forKey:project];
}

- (void)removeProjectWithPath:(NSString *)path {
    XCProject *project = [self cachedProjectWithPath:path];
    [self.projectsMapTable removeObjectForKey:project];
}

#pragma mark - Notifications

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (NSString *)filePathForProjectFromNotification:(NSNotification *)notification {
    if ([notification.object respondsToSelector:@selector(projectFilePath)]) {
        NSString *pbxProjPath = [notification.object performSelector:@selector(projectFilePath)];
        return [pbxProjPath stringByDeletingLastPathComponent];
    }
    return nil;
}

#pragma clang diagnostic pop

- (void)projectDidOpen:(NSNotification *)notification {
    [self projectDidChange:notification];
}

- (void)projectDidChange:(NSNotification *)notification {
    NSString *filePath = [self filePathForProjectFromNotification:notification];
    if (filePath) {
        [self updateProjectWithPath:filePath];
    }
}

- (void)projectDidClose:(NSNotification *)notification {
    NSString *filePath = [self filePathForProjectFromNotification:notification];
    if (filePath) {
        [self removeProjectWithPath:filePath];
    }
}

#pragma mark - Utilities

- (NSBlockOperation *)sortProjectHeadersOperationWithCompletion:(void(^)(void)) completionBlock {
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        [weakSelf.projectsMapTable.objectEnumerator.allObjects enumerateObjectsUsingBlock:
         ^(NSArray *headers, NSUInteger idx, BOOL *stop) {
             [headers enumerateObjectsUsingBlock:^(XCSourceFile *source, NSUInteger idx, BOOL *stop) {
                 if (![weakSelf.projectHeaders containsObject:source] &&
                     [source.extension isEqualToString:@"h"]) {
                     [weakSelf.projectHeaders addObject:source];
                 }
             }];
        }];
        
        [weakSelf.projectHeaders sortUsingDescriptors:[self headersSortDescriptors]];
        completionBlock();
    }];
    return operation;
}

- (NSArray *)headersSortDescriptors {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastPathComponent"
                                                                     ascending:YES];
    return @[sortDescriptor];
}

@end
