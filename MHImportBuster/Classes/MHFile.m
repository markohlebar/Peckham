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
{
    NSOperationQueue *_operationQueue;
}

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

	if ([filePath containsIllegalCharacters])
	{
		class = Nil;
	}

	return [[class alloc] initWithFilePath:filePath];
}

+ (instancetype)fileWithCurrentFilePath {
    return [self fileWithPath:[MHXcodeDocumentNavigator currentFilePath]];
}

- (void)observeFileChanges {
    
}

- (id)initWithFilePath:(NSString *)filePath {

	if ([filePath containsIllegalCharacters])
	{
		return nil;
	}

	self = [super init];
	if (self) {
		_filePath = filePath.copy;
        _operationQueue = [NSOperationQueue new];
	}
	return self;
}

- (void)removeDuplicateImports {
    DVTSourceTextStorage *textStorage = [self currentTextStorage];
    if (textStorage) {
        NSOperation *operation = [MHRemoveDuplicateImportsOperation operationWithSource:textStorage];
        [_operationQueue addOperation:operation];
    }
}

- (void)sortImportsAlphabetically {
    DVTSourceTextStorage *textStorage = [self currentTextStorage];
    if (textStorage) {
        NSOperation *operation = [MHSortImportsAlphabeticallyOperation operationWithSource:textStorage];
        [_operationQueue addOperation:operation];
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
        [_operationQueue addOperation:operation];
    }
}

@end

@implementation MHInterfaceFile

@end

@implementation MHImplementationFile

@end
