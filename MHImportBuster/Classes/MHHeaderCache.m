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
#import <XcodeEditor/XCProjectBuildConfig.h>
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
@property (strong) NSArray *projectHeaders;
@property (strong) NSArray *frameworkHeaders;
@property (strong) NSArray *userHeaders;

@property (nonatomic, strong) NSMapTable *workspacesMapTable;
@property (nonatomic, strong) NSMutableDictionary *workspaceCacheDictionary;
@end

@implementation MHHeaderCache {
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

- (instancetype)init {
    self = [super init];
    if (self) {
        _projectHeaders = [NSMutableArray new];
        _frameworkHeaders = [NSMutableArray new];
        _userHeaders = [NSMutableArray new];
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

- (BOOL)isProjectHeader:(id <MHSourceFile> )header {
    return [self.projectHeaders containsObject:header];
}

- (BOOL)isFrameworkHeader:(id <MHSourceFile> )header {
    return [self.frameworkHeaders containsObject:header];
}

- (BOOL)isUserHeader:(id <MHSourceFile> )header {
    return [self.userHeaders containsObject:header];
}

- (BOOL)isLoading {
    return _operationQueue.operationCount > 0;
}

- (NSArray *) allHeaders {
    NSMutableArray *allHeaders = [NSMutableArray array];
    [allHeaders addObjectsFromArray:self.projectHeaders];
    [allHeaders addObjectsFromArray:self.frameworkHeaders];
    return allHeaders.copy;
}

- (void)loadHeaders:(MHHeaderLoadingBlock)headersBlock {
    self.headersBlock = headersBlock;
    
    if (![self isLoading]) {
        [self asyncReloadHeaders];
    }
}

- (void)asyncReloadHeaders {
    self.projectHeaders = nil;
    self.frameworkHeaders = nil;
    self.userHeaders = nil;
    
    NSBlockOperation *operation = nil;
    //In some situations i.e. installing with Alcatraz, the projects can't be loaded
    //via notifications, but must be loaded manually
    if (self.shouldLoadWorkspace) {
        operation = [self loadWorkspaceOperation];
        [_operationQueue addOperation:operation];
    }
    
    operation = [self sortProjectHeadersOperationWithCompletion:^{
        [self notifyAllHeaders];
    }];
    [_operationQueue addOperation:operation];
}

- (BOOL)shouldLoadWorkspace {
    NSDictionary *mapTableDictionary = [self.workspacesMapTable objectForKey:self.currentWorkspace];
    return mapTableDictionary.allValues.count == 0;
}

- (void)notifyAllHeaders {
    if (self.headersBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headersBlock([self allHeaders], !self.isLoading);
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
    XCWorkspace *workspace = self.workspaceCacheDictionary[workspacePath];
    if (!workspace) {
        workspace = [XCWorkspace workspaceWithFilePath:workspacePath];
        self.workspaceCacheDictionary[workspacePath] = workspace;
    }
    
    return workspace;
}

- (NSMapTable *)mapTableForWorkspace:(XCWorkspace *)workspace
                                kind:(MHHeaderCacheHeaderKind)kind {
    NSMutableDictionary *mapTableDictionary = [self.workspacesMapTable objectForKey:workspace];
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

- (void)updateProject:(XCProject *)project {
    [self removeProjectWithPath:project.filePath];

    XCWorkspace *workspace = self.currentWorkspace;
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

- (void)updateProjectWithPath:(NSString *)path {
    if(![[NSFileManager defaultManager] fileExistsAtPath:path]) return;
    XCProject *project = [XCProject projectWithFilePath:path];
    [self updateProject:project];
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
        
        //TODO: This is a temporary solution which works. When opening .xcodeproj
        //files, it seems that the notification order is differrent and we can't find
        //the current workspace. Find out which notification gets fired after opening
        //.xcodeproj and act after that perhaps... 
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self updateProjectWithPath:filePath];
        });
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
        NSArray *projectHeaderArrays = weakSelf.projectsMapTable.objectEnumerator.allObjects;
        weakSelf.projectHeaders = [self sortedHeadersForHeaderArrays:projectHeaderArrays];
        
        NSArray *frameworkHeaderArrays = weakSelf.frameworksMapTable.objectEnumerator.allObjects;
        weakSelf.frameworkHeaders = [self sortedHeadersForHeaderArrays:frameworkHeaderArrays];

        completionBlock();
    }];
    return operation;
}

- (NSBlockOperation *)loadWorkspaceOperation {
    __weak typeof(self) weakSelf = self;
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self.currentWorkspace.projects enumerateObjectsUsingBlock:^(XCProject *project, NSUInteger idx, BOOL *stop) {
            [weakSelf updateProject:project];
        }];
    }];
    return operation;
}

- (NSArray *)sortedHeadersForHeaderArrays:(NSArray *)headerArrays {
    NSArray *filteredHeaders = [headerArrays mhFlattenedArray];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"extension == %@", @"h"];
    filteredHeaders = [filteredHeaders filteredArrayUsingPredicate:predicate];
    filteredHeaders = [[NSSet setWithArray:filteredHeaders] allObjects];
    return [filteredHeaders sortedArrayUsingDescriptors:[self headersSortDescriptors]];
}

- (NSArray *)headersSortDescriptors {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lastPathComponent"
                                                                     ascending:YES];
    return @[sortDescriptor];
}

@end
