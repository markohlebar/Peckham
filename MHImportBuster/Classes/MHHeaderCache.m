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
#import "MHSourceFile.h"
#import "MHConcreteSourceFile.h"
#import "NSArray+Operations.h"

typedef NSString * MHHeaderCacheHeaderKind;
MHHeaderCacheHeaderKind const MHHeaderCacheHeaderKindProjects = @"MHHeaderCacheHeaderKindProjects";
MHHeaderCacheHeaderKind const MHHeaderCacheHeaderKindFrameworks = @"MHHeaderCacheHeaderKindFrameworks";

@interface MHHeaderCache ()
@property (nonatomic, strong) NSDate *lastModifiedDate;
@property (nonatomic, copy) MHHeaderLoadingBlock headersBlock;
@property (nonatomic, strong) NSMutableArray *projectHeaders;
@property (nonatomic, strong) NSMutableArray *frameworkHeaders;

@property (nonatomic, strong) NSMapTable *workspacesMapTable;
@property (nonatomic, strong) NSMutableDictionary *workspaceCacheDictionary;
@end

@implementation MHHeaderCache {
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
        _frameworkHeaders = [NSMutableArray new];
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

- (NSArray *)allFrameworksForProject:(XCProject *) project {
    NSArray *names = [[project valueForKeyPath:@"targets.frameworks.name"] mhFlattenedArray];
    names = [[NSSet setWithArray:names] allObjects];
    
    NSMutableArray *frameworkPaths = [NSMutableArray array];
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        NSString *frameworkPath = [MHXcodeDocumentNavigator pathForFrameworkNamed:name];
        if(frameworkPath) {
            [frameworkPaths addObject:frameworkPath];
        }
    }];
    
    return frameworkPaths;
}

- (NSArray *)frameworkHeadersForProject:(XCProject *)project {
    NSArray *frameworkPaths = [self allFrameworksForProject:project];
    __block NSMutableArray *allHeaders = [NSMutableArray array];
    [frameworkPaths enumerateObjectsUsingBlock:^(NSString *frameworkPath, NSUInteger idx, BOOL *stop) {
        NSString *headersDirectory = [frameworkPath stringByAppendingPathComponent:@"Headers/"];
        NSArray *headerPaths = [NSFileManager findFilesWithExtension:@"h" inDirectory:headersDirectory];
        [headerPaths enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL *stop) {
            MHConcreteSourceFile *header = [MHConcreteSourceFile sourceFileWithName:path];
            [allHeaders addObject:header];
        }];
    }];
    return allHeaders;
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
    [allHeaders addObjectsFromArray:self.projectHeaders];
    [allHeaders addObjectsFromArray:self.frameworkHeaders];
    return allHeaders.copy;
}

- (void)loadHeaders:(MHHeaderLoadingBlock)headersBlock {
    self.headersBlock = headersBlock;
    [self asyncReloadHeaders];
}

- (void)asyncReloadHeaders {
    [self.projectHeaders removeAllObjects];
    [self.frameworkHeaders removeAllObjects];
    
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
    return [self workspaceWithPath:workspacePath];
}

- (XCWorkspace *)workspaceWithPath:(NSString *)workspacePath {
    XCWorkspace *workspace = _workspaceCacheDictionary[workspacePath];
    if (!workspace) {
        workspace = [XCWorkspace workspaceWithFilePath:workspacePath];
        _workspaceCacheDictionary[workspacePath] = workspace;
    }
    
    return workspace;
}

- (NSMapTable *)mapTableForWorkspace:(XCWorkspace *)workspace
                                kind:(MHHeaderCacheHeaderKind)kind {
    NSMutableDictionary *mapTableDictionary = [_workspacesMapTable objectForKey:workspace];
    NSMapTable *mapTable = mapTableDictionary[kind];
    if (!mapTable) {
        mapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory
                                         valueOptions:NSPointerFunctionsStrongMemory];
        if (!mapTableDictionary) {
            mapTableDictionary = [NSMutableDictionary dictionary];
            [_workspacesMapTable setObject:mapTableDictionary
                                    forKey:workspace];
        }
        
        [mapTableDictionary setObject:mapTable
                               forKey:kind];
    }
    return mapTable;
}

- (NSMapTable *)projectsMapTableForWorkspace:(XCWorkspace *)workspace {
    return [self mapTableForWorkspace:workspace
                                 kind:MHHeaderCacheHeaderKindProjects];
}

- (NSMapTable *)frameworksMapTableForWorkspace:(XCWorkspace *)workspace {
    return [self mapTableForWorkspace:workspace
                                 kind:MHHeaderCacheHeaderKindFrameworks];
}

- (NSMapTable *)projectsMapTable {
    return [self projectsMapTableForWorkspace:self.currentWorkspace];
}

- (NSMapTable *)frameworksMapTable {
    return [self frameworksMapTableForWorkspace:self.currentWorkspace];
}

#pragma mark - Projects handling 

- (XCProject *)cachedProjectWithPath:(NSString *)path {
    __block XCProject *project = nil;
    
    [self.projectsMapTable.keyEnumerator.allObjects enumerateObjectsUsingBlock:
     ^(XCProject *cachedProject, NSUInteger idx, BOOL *stop) {
        if ([cachedProject.filePath isEqualToString:path]) {
            project = cachedProject;
            *stop = YES;
        }
    }];
    return project;
}

- (void)updateProjectWithPath:(NSString *)path {
    [self removeProjectWithPath:path];
    
    XCWorkspace *workspace = self.currentWorkspace;
    if (!workspace) {
        NSString *workspacePath = [path stringByAppendingPathComponent:@"project.xcworkspace"];
        workspace = [self workspaceWithPath:workspacePath];
    }
    
    XCProject *project = [XCProject projectWithFilePath:path];
    NSMapTable *projectsMapTable = [self mapTableForWorkspace:workspace
                                                         kind:MHHeaderCacheHeaderKindProjects];
    [projectsMapTable setObject:project.headerFiles
                         forKey:project];
    
    NSArray *frameworkHeaders = [self frameworkHeadersForProject:project];
    
    NSMapTable *frameworksMapTable = [self mapTableForWorkspace:workspace
                                                           kind:MHHeaderCacheHeaderKindFrameworks];
    [frameworksMapTable setObject:frameworkHeaders
                           forKey:project];
}

- (void)removeProjectWithPath:(NSString *)path {
    XCProject *project = [self cachedProjectWithPath:path];
    [self.projectsMapTable removeObjectForKey:project];
    [self.frameworksMapTable removeObjectForKey:project];

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
             [headers enumerateObjectsUsingBlock:^(id <MHSourceFile> source, NSUInteger idx, BOOL *stop) {
                 if (![weakSelf.projectHeaders containsObject:source] &&
                     [source.extension isEqualToString:@"h"]) {
                     [weakSelf.projectHeaders addObject:source];
                 }
             }];
        }];
        
        [weakSelf.frameworksMapTable.objectEnumerator.allObjects enumerateObjectsUsingBlock:
         ^(NSArray *headers, NSUInteger idx, BOOL *stop) {
             [headers enumerateObjectsUsingBlock:^(id <MHSourceFile> source, NSUInteger idx, BOOL *stop) {
                 if (![weakSelf.frameworkHeaders containsObject:source] &&
                     [source.extension isEqualToString:@"h"]) {
                     [weakSelf.frameworkHeaders addObject:source];
                 }
             }];
         }];
        
        [weakSelf.projectHeaders sortUsingDescriptors:[self headersSortDescriptors]];
        [weakSelf.frameworkHeaders sortUsingDescriptors:[self headersSortDescriptors]];

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
