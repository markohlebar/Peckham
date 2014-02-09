//
//  MHRemoveDuplicateImportsOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHRemoveDuplicateImportsOperation.h"
#import "MHXcodeDocumentNavigator.h"
#import "XCFXcodePrivate.h"
#import "MHStatementParser.h"
#import "MHImportStatement.h"
#import "DVTSourceTextStorage+Operations.h"

@implementation MHRemoveDuplicateImportsOperation

- (void)execute {
    NSArray *statements = [[MHStatementParser new] parseText:self.source.string
                                                       error:nil
                                            statementClasses:@[[MHFrameworkImportStatement class],
                                                               [MHProjectImportStatement class]]];
	NSSet *countedSet = [NSSet setWithArray:statements];
	NSMutableIndexSet *linesOfCodeToDelete = [NSMutableIndexSet indexSet];
	NSMutableArray *linesToAdd = [NSMutableArray array];
    
	for (MHImportStatement *statement in countedSet) {
		NSInteger count = 2; //[countedSet countForObject:statement];
		if (count > 1) {
			[linesToAdd addObject:statement];
			BOOL isFirstImportStatement = YES;
			for (MHImportStatement *importStatement in statements) {
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
    
    [self.source mhDeleteLines:linesOfCodeToDelete];
}


@end
