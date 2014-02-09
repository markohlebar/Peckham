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
    _statements = [[MHStatementParser new] parseText:textStorage.string
                                               error:nil];
    
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self isKindOfClass:%@", [MHImportStatement class]];
	NSMutableArray *importStatements = [self.statements filteredArrayUsingPredicate:predicate].mutableCopy;
	NSSet *countedSet = [NSSet setWithArray:importStatements];

	NSMutableIndexSet *linesOfCodeToDelete = [NSMutableIndexSet indexSet];
	NSMutableArray *linesToAdd = [NSMutableArray array];

	for (MHImportStatement *statement in countedSet) {
		NSInteger count = 2; //[countedSet countForObject:statement];
		if (count > 1) {
			[linesToAdd addObject:statement];
			BOOL isFirstImportStatement = YES;
			for (MHImportStatement *importStatement in importStatements) {
				if ([importStatement isEqual:statement]) {
					//Dont add the first statement to the delete list.
					if (isFirstImportStatement) {
						isFirstImportStatement = NO;
						continue;
					}
					[linesOfCodeToDelete addIndexes:importStatement.codeLineNumbers];
				}
			}
		}
	}
    
    [textStorage mhDeleteLines:linesOfCodeToDelete];
}

- (void)sortImportsAlphabetically {
}

@end

@implementation MHInterfaceFile

@end

@implementation MHImplementationFile

@end
