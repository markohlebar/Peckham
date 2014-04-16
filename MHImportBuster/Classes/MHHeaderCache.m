//
//  MHHeaderCache.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHHeaderCache.h"
#import "XCFXcodePrivate.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSFileManager+Headers.h"
#import "NSString+Extensions.h"
#import "MHStatementParser.h"
#import "NSArray+MHStatement.h"

@implementation MHHeaderCache
{
    NSArray *_headers;
    NSDictionary *_interfaceDictionary;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _headers = [self allHeadersInCurrentWorkspace];
        _interfaceDictionary = [self parseInterfacesForHeaders:_headers];
    }
    return self;
}

- (NSArray *)allHeadersInCurrentWorkspace {
    IDEWorkspaceDocument *document = [MHXcodeDocumentNavigator currentWorkspaceDocument];
    NSURL *workspaceURL = document.workspace.representingFilePath.fileURL;
    NSURL *projectURL = [workspaceURL URLByDeletingLastPathComponent];
    if (projectURL) {
        return [NSFileManager findFilesWithExtension:@".h" inDirectory:[projectURL path]];
    }
    return nil;
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
    
    return nil;
}


@end
