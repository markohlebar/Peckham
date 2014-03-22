//
//  DVTSourceTextStorage+Operations.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 08/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "DVTSourceTextStorage+Operations.h"
#import "XCFXcodePrivate.h"
#import "MHXcodeDocumentNavigator.h"
#import "NSString+MHNSRange.h"

@implementation NSTextStorage (MHOperations)

- (void)mhInsertString:(NSString *)string atLine:(NSUInteger)lineNumber {
	NSRange range = [self.string mhRangeOfLine:lineNumber];
	range.length = 0;
    //edge case when string is out of bounds
    if (range.location == NSNotFound) {
        range = NSMakeRange(self.length, 0);
//        NSString *newLine = @"\n";
//        string = [newLine stringByAppendingString:string];
    };
    [self mhReplaceCharactersInRange:range withString:string];
}

- (void)mhDeleteLine:(NSInteger)lineNumber {
	NSRange range = [self.string mhRangeOfLine:lineNumber];
	if (range.location != NSNotFound) {
		[self mhReplaceCharactersInRange:range withString:@""];
	}
}

- (void)mhDeleteLines:(NSIndexSet *)lineNumbers {
	__block NSInteger offset = 0;
	[lineNumbers enumerateIndexesUsingBlock: ^(NSUInteger index, BOOL *stop) {
	    NSInteger indexToDelete = index - offset;
	    [self mhDeleteLine:indexToDelete];
	    offset++;
	}];
}

- (void)mhReplaceCharactersInRange:(NSRange)range withString:(NSString *)string {
    if ([self respondsToSelector:@selector(replaceCharactersInRange:withString:withUndoManager:)]) {
        IDESourceCodeDocument *document = [MHXcodeDocumentNavigator currentSourceCodeDocument];
		DVTSourceTextStorage *storage = (DVTSourceTextStorage *)self;
		[storage replaceCharactersInRange:range
		                       withString:string
		                  withUndoManager:document.undoManager];
    }
	else {
		[self replaceCharactersInRange:range
		                    withString:string];
	}
}

@end
