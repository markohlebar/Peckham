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

@implementation MHHeaderCache
{
    NSArray *_headers;
    NSDictionary *_interfaceDictionary;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _headers = [MHHeaderCache allHeadersInCurrentWorkspace];
//        _interfaceDictionary = [self parseInterfacesForHeaders:_headers];
    }
    return self;
}

+ (NSArray *)allFrameworksInCurrentWorkspace {
    
    NSString *filePath = [MHXcodeDocumentNavigator currentWorkspacePath];
    XCWorkspace *workspace = [XCWorkspace workspaceWithFilePath:filePath];
    XCProject *project = [workspace.projects firstObject];

    XCTarget *target = [project.targets firstObject];
//    XCBuildSettings *buildSettings = [XCBuildSettings buildSettingsWithTarget:target];
//    NSLog(@"%@", buildSettings.settings);
    
//    NSLog(@"%@", resources);
    
//    NSDictionary *frameworkSearchPaths = target.defaultConfiguration.specifiedBuildSettings;
//    NSLog(@"%@", frameworkSearchPaths);
    

    //NSArray *frameworks = [NSBundle allFrameworks];
    //NSLog(@"%@", frameworks);
    
    //    for (id configuration in frameworkSearchPaths) {
//        NSLog(@"%@", configuration);
//        if (![configuration isEqualToString:@"$(inherited)"]) {
//            NSLog(@"%@", [self resolvePath:configuration]);
//        }
//    }
//    NSString* path = @(getenv("SYSTEM_APPS_DIR"));
//    NSLog(@"SYSTEM_APPS_DIR = %@", path);
    
//    for (id member in resources) {
//        NSLog(@"%@ %@", member, NSStringFromClass([member class]));
//    }
    
    return nil;
}

+ (NSArray *)allImportStatementsInCurrentWorkspace {
    NSMutableArray *importStatements = [NSMutableArray array];
    [importStatements addObjectsFromArray:[self projectImportStatements]];
    [importStatements addObjectsFromArray:[self frameworkImportStatements]];
    return importStatements.copy;
}

+ (NSArray *)frameworkImportStatements {
    NSString *filePath = [MHXcodeDocumentNavigator currentWorkspacePath];
    XCWorkspace *workspace = [XCWorkspace workspaceWithFilePath:filePath];
    XCProject *project = [workspace.projects firstObject];
    XCTarget *target = [project.targets firstObject];
    NSArray *frameworkNames = [[target frameworks] valueForKey:@"name"];

    __block NSMutableArray *importStatements = [NSMutableArray array];
    [frameworkNames enumerateObjectsUsingBlock:^(NSString *frameworkName, NSUInteger idx, BOOL *stop) {
        NSString *frameworkPath = [MHXcodeDocumentNavigator pathForFrameworkNamed:frameworkName];
        NSString *headersDirectory = [frameworkPath stringByAppendingPathComponent:@"Headers/"];
        NSArray *headerPaths = [NSFileManager findFilesWithExtension:@"h" inDirectory:headersDirectory];
        [headerPaths enumerateObjectsUsingBlock:^(NSString *headerPath, NSUInteger idx, BOOL *stop) {
            MHFrameworkImportStatement *statement = [MHFrameworkImportStatement statementWithFrameworkHeaderPath:headerPath];
            if (statement) {
                [importStatements addObject:statement];
            }
        }];
    }];

    return importStatements;
}

+ (NSArray *)projectImportStatements {
    NSString *filePath = [MHXcodeDocumentNavigator currentWorkspacePath];
    XCWorkspace *workspace = [XCWorkspace workspaceWithFilePath:filePath];
    NSMutableArray *headers = [NSMutableArray array];
    [workspace.projects enumerateObjectsUsingBlock:^(XCProject *project, NSUInteger idx, BOOL *stop) {
        [headers addObjectsFromArray:[project.headerFiles valueForKey:@"pathRelativeToProjectRoot"]];
    }];
    
    NSMutableArray *importStatements = [NSMutableArray array];
    [headers enumerateObjectsUsingBlock:^(NSString *headerPath, NSUInteger idx, BOOL *stop) {
        MHProjectImportStatement *statement = [MHProjectImportStatement statementWithHeaderPath:headerPath];
        if(statement) [importStatements addObject:statement];
    }];
    
    return importStatements.copy;
}

- (NSDictionary *) parseInterfacesForHeaders:(NSArray *)headers {
    __block NSMutableDictionary *interfaceDictionary = [NSMutableDictionary dictionary];
    for (NSString *headerPath in headers) {
        [MHStatementParser parseFileAtPath:headerPath
                                   success:^(NSArray *statements) {
                                       if (statements) {
                                           [interfaceDictionary setObject:statements forKey:headerPath];
                                       }
                                   }
                                     error:nil];
    }
    return interfaceDictionary.copy;
}

- (NSString *)headerForClassName:(NSString *)className {
    for (NSString *headerPath in _interfaceDictionary.allKeys) {
        NSArray *statements = _interfaceDictionary[headerPath];
        NSArray *interfaceStatements = [statements interfaceStatements];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.value == %@", className];
        NSArray *interfaceMatches = [interfaceStatements filteredArrayUsingPredicate:predicate];
        
        if (interfaceMatches.count > 0) {
            NSString *header = [headerPath lastPathComponent];
            return header;
        }
    }
    return nil;
}

- (NSString *)headerForMethod:(NSString *)method forClassName:(NSString *)className {
    for (NSString *headerPath in _interfaceDictionary.allKeys) {
        NSArray *statements = _interfaceDictionary[headerPath];
        NSArray *interfaceStatements = [statements interfaceStatements];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.value == %@", className];
        NSArray *interfaceMatches = [interfaceStatements filteredArrayUsingPredicate:predicate];
        
        for (MHInterfaceStatement *statement in interfaceMatches) {
            NSArray *methodStatements = [statement.children methodStatements];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.value == %@", method];
            NSArray *methodMatches = [methodStatements filteredArrayUsingPredicate:predicate];
            
            if (methodMatches.count > 0) {
                NSString *header = [headerPath lastPathComponent];
                return header;
            }
        }
    }
    return nil;
}


@end
