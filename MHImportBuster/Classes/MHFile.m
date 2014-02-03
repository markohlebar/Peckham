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
#import "MHFileHandle.h"
#import "MHXcodeDocumentNavigator.h"
#import "XCFXcodePrivate.h"


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

		__weak id weakThis = self;
		[MHStatementParser parseFileAtPath:_filePath
		                           success: ^(NSArray *statements) {
		    [weakThis setStatements:statements];
		} error: ^(NSError *error) {
		}];
	}
	return self;
}

- (void)removeDuplicateImports {
    if (![[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return;
    }
    
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
    
    NSTextView *textView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    IDESourceCodeDocument *document = [MHXcodeDocumentNavigator currentSourceCodeDocument];
    __block DVTSourceTextStorage *textStorage = (DVTSourceTextStorage*)textView.textStorage;
    
	__block NSInteger offset = 0;
	NSMutableIndexSet *mutableLineNumbers = [linesOfCodeToDelete mutableCopy];
	[mutableLineNumbers enumerateIndexesUsingBlock: ^(NSUInteger idx, BOOL *stop) {
//	    [self deleteLine:idx - offset];
        __block NSUInteger deleteIndex = idx - offset;
        __block NSUInteger lineCount = 0;
        __block NSUInteger location = 0;
        [textStorage.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            if (lineCount == deleteIndex) {
                NSRange range = NSMakeRange(location, line.length+1);
                [textStorage replaceCharactersInRange:range
                                           withString:@""
                                      withUndoManager:[document undoManager]];
                *stop = YES;
            }
            location += line.length;
            lineCount++;
        }];
        
	    offset++;
	}];
    
//  
//    
//    
//    
//	MHFileHandle *fileHandle = [MHFileHandle handleWithFilePath:_filePath];
//	[fileHandle deleteLines:linesOfCodeToDelete];
}

- (void)sortImportsAlphabetically {
}

@end

@implementation MHInterfaceFile

@end

@implementation MHImplementationFile

@end
