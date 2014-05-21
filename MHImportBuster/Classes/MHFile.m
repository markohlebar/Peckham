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
#import "MHAddImportOperation.h"

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

+ (instancetype)fileWithCurrentFilePath {
    return [self fileWithPath:[MHXcodeDocumentNavigator currentFilePath]];
}

- (void)observeFileChanges {
    
}

- (id)initWithFilePath:(NSString *)filePath {
	self = [super init];
	if (self) {
		_filePath = filePath.copy;
	}
	return self;
}

- (void)removeDuplicateImports {
    DVTSourceTextStorage *textStorage = [self currentTextStorage];
    if (textStorage) {
        NSOperation *operation = [MHRemoveDuplicateImportsOperation operationWithSource:textStorage];
        [operation start];
    }
}

- (void)sortImportsAlphabetically {
    DVTSourceTextStorage *textStorage = [self currentTextStorage];
    if (textStorage) {
        NSOperation *operation = [MHSortImportsAlphabeticallyOperation operationWithSource:textStorage];
        [operation start];
    }
}

- (DVTSourceTextStorage *)currentTextStorage {
    if (![[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return nil;
    }
    NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    return (DVTSourceTextStorage*)textView.textStorage;
}

- (void)addImport:(MHImportStatement *)statement {
    DVTSourceTextStorage *textStorage = [self currentTextStorage];
    if (textStorage) {
        NSOperation *operation = [MHAddImportOperation operationWithSource:textStorage
                                                               importToAdd:statement];
        [operation start];
    }
}

@end

@implementation MHInterfaceFile

@end

@implementation MHImplementationFile

@end
