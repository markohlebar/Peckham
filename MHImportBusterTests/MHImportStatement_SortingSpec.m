//
//  MHImportStatement_SortingSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHImportStatement+Sorting.h"
#import "MHTestTokens.h"

SPEC_BEGIN(MHImportStatement_SortingSpec)

describe(@"MHImportStatement+Sorting", ^{
    it(@"Framework imports should have higher precedence than Project imports", ^{
        MHFrameworkImportStatement *frameworkImport = [MHFrameworkImportStatement statement];
        MHProjectImportStatement *projectImport = [MHProjectImportStatement statement];
        
        NSComparisonResult comparisonResult = [frameworkImport compare:projectImport];
        [[theValue(comparisonResult) should] equal:theValue(NSOrderedAscending)];
        
        comparisonResult = [projectImport compare:frameworkImport];
        [[theValue(comparisonResult) should] equal:theValue(NSOrderedDescending)];
    });
    
    it(@"Should sort imports alphabetically", ^{
        MHProjectImportStatement *aProjectImport = [MHProjectImportStatement statement];
        feedStatement(aProjectImport, @"#import \"AProject/Header.h\"");
        
        MHProjectImportStatement *bProjectImport = [MHProjectImportStatement statement];
        feedStatement(bProjectImport, @"#import \"BProject/Header.h\"");
        
        NSComparisonResult comparisonResult = [aProjectImport compare:bProjectImport];
        [[theValue(comparisonResult) should] equal:theValue(NSOrderedAscending)];
        
        comparisonResult = [bProjectImport compare:aProjectImport];
        [[theValue(comparisonResult) should] equal:theValue(NSOrderedDescending)];
    });
});

SPEC_END
