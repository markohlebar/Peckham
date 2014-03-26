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

@implementation MHHeaderCache
{
    NSArray *_headers;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _headers = [self findAllHeadersInCurrentWorkspace];
    }
    return self;
}

- (NSArray *)findAllHeadersInCurrentWorkspace {
    IDEWorkspaceDocument *document = [MHXcodeDocumentNavigator currentWorkspaceDocument];
    NSURL *workspaceURL = document.workspace.representingFilePath.fileURL;
    NSURL *projectURL = [workspaceURL URLByDeletingLastPathComponent];
    if (projectURL) {
        return [NSFileManager findFilesWithExtension:@".h" inDirectory:[projectURL path]];
    }
    return nil;
}

- (NSString *)headerForClassName:(NSString *)className {
    for (NSString *headerPath in _headers) {
        NSString *header = [headerPath lastPathComponent];
        if([header containsString:className]) return header;
    }
    return nil;
}

@end
