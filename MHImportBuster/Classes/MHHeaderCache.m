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

NSString *const MHHeaderCacheFrameworksSubPath =       @"/System/Library/Frameworks";

@implementation MHHeaderCache
{
    NSArray *_headers;
    NSDictionary *_interfaceDictionary;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

+ (NSArray *)allFrameworksInCurrentWorkspace {
    XCTarget *target = [MHXcodeDocumentNavigator currentTarget];
    NSMutableArray *frameworkPaths = [NSMutableArray array];
    NSArray *names = [[target frameworks] valueForKey:@"name"];
    [names enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
        NSString *frameworkPath = [MHXcodeDocumentNavigator pathForFrameworkNamed:name];
        if(frameworkPath) [frameworkPaths addObject:frameworkPath];
    }];
    
    return [NSSet setWithArray:frameworkPaths].allObjects;
}

+ (NSArray *)frameworkHeaders {
    
    [MHXcodeDocumentNavigator currentTarget];
    
    NSArray *frameworkPaths = [self allFrameworksInCurrentWorkspace];
    __block NSMutableArray *allHeaderPaths = [NSMutableArray array];
    [frameworkPaths enumerateObjectsUsingBlock:^(NSString *frameworkPath, NSUInteger idx, BOOL *stop) {
        NSString *headersDirectory = [frameworkPath stringByAppendingPathComponent:@"Headers/"];
        NSArray *headerPaths = [NSFileManager findFilesWithExtension:@"h" inDirectory:headersDirectory];
        [allHeaderPaths addObjectsFromArray:headerPaths];
    }];
    return [allHeaderPaths sortedArrayUsingSelector:@selector(compare:)];
}

+ (NSArray *)projectHeaders {
    XCTarget *target = [MHXcodeDocumentNavigator currentTarget];
    NSArray *headers = [target.project.headerFiles valueForKey:@"pathRelativeToProjectRoot"];
    
    //remove .pch files
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF CONTAINS[c] %@)", @".pch"];
    headers = [headers filteredArrayUsingPredicate:predicate];
    return [headers sortedArrayUsingSelector:@selector(compare:)];;
}

#pragma mark - Legacy

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
