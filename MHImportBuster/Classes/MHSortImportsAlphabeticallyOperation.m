//
//  MHSortImportsAlphabeticallyOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHSortImportsAlphabeticallyOperation.h"
#import "MHStatementParser.h"
#import "MHImportStatement.h"
#import "MHImportStatement+Sorting.h"
#import "DVTSourceTextStorage+Operations.h"

@implementation MHSortImportsAlphabeticallyOperation

- (void)execute {
    NSArray *statements = [[MHStatementParser new] parseText:self.source.string
                                                       error:nil
                                            statementClasses:@[[MHFrameworkImportStatement class],
                                                               [MHProjectImportStatement class]]];
    
    NSMutableIndexSet *linesOfCodeToDelete = [NSMutableIndexSet indexSet];
 
    for (MHImportStatement *importStatement in statements) {
        [linesOfCodeToDelete addIndexes:importStatement.codeLineNumbers];
    }
    
    //first delete all imports.
    [self.source mhDeleteLines:linesOfCodeToDelete];
    
    NSInteger firstIndex = linesOfCodeToDelete.firstIndex;
    statements = [statements sortedArrayUsingSelector:@selector(compare:)];
    
    NSMutableString *sortedStatements = [NSMutableString string];
    for(MHImportStatement *statement in statements) {
        NSString *statementValue = [NSString stringWithFormat:@"%@\n", statement.value];
        [sortedStatements appendString:statementValue];
    }
        
    [self.source mhInsertString:sortedStatements
                         atLine:firstIndex];
}

@end
