//
//  MHFile.m
//  MHImportBuster
//
//  Created by marko.hlebar on 30/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import "MHFile.h"
#import "NSString+Files.h"
#import "MHImportStatement.h"
#import "MHStatementParser.h"
#import "MHXcodeDocumentNavigator.h"
#import "XCFXcodePrivate.h"
#import "NSObject+MHLogMethods.h"

#import "DVTSourceTextStorage+Operations.h"
#import "MHRemoveDuplicateImportsOperation.h"
#import "MHSortImportsAlphabeticallyOperation.h"

@implementation MHFile
+ (instancetype)fileWithPath:(NSString *)filePath {
	Class class = nil;
	if ([filePath isHeaderFilePath]) {
		class = [MHInterfaceFile class];
	}
	else if ([filePath isImplementationFilePath]) {
		class = [MHImplementationFile class];
	}
	else {
		//class remains nil if it is nor header nor implementation
	}
	return [[class alloc] initWithFilePath:filePath];
}

- (id)initWithFilePath:(NSString *)filePath {
	self = [super init];
	if (self) {
		_filePath = filePath.copy;
	}
	return self;
}

- (void)removeDuplicateImports {
    if (![[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return;
    }
    NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    DVTSourceTextStorage *textStorage = (DVTSourceTextStorage*)textView.textStorage;
    NSOperation *operation = [MHRemoveDuplicateImportsOperation operationWithSource:textStorage];
    [operation start];
}

- (void)sortImportsAlphabetically {
    if (![[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return;
    }
    NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    DVTSourceTextStorage *textStorage = (DVTSourceTextStorage*)textView.textStorage;
    NSOperation *operation = [MHSortImportsAlphabeticallyOperation operationWithSource:textStorage];
    [operation start];
}

@end

@implementation MHInterfaceFile

@end

@implementation MHImplementationFile

@end
