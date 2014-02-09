//
//  MHSortImportsAlphabeticallyOperationSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHSortImportsAlphabeticallyOperation.h"


SPEC_BEGIN(MHSortImportsAlphabeticallyOperationSpec)

describe(@"MHSortImportsAlphabeticallyOperation", ^{
    __block MHSortImportsAlphabeticallyOperation *operation = nil;

    it(@"Should sort so that framework imports have higher precedence than project imports", ^{
        NSTextStorage *testSource = [[NSTextStorage alloc] initWithString:@"#import \"Project.h\"\n#import <Framework/Framework.h>\n"];
        operation = [MHSortImportsAlphabeticallyOperation operationWithSource:testSource];
        [operation execute];
        [[operation.source.string should] equal:@"#import <Framework/Framework.h>\n#import \"Project.h\"\n"];
    });
    
    it(@"Should sort so that project import paths are sorted alphabetically ", ^{
//        NSTextStorage *testSource = [[NSTextStorage alloc] initWithString:@"#import \"CProject.h\"\n#import \"AProject.h\"\n#import \"BProject.h\"\n"];
//        operation = [MHSortImportsAlphabeticallyOperation operationWithSource:testSource];
//        [operation execute];
//        [[operation.source.string should] equal:@"#import \"AProject.h\"\n#import \"BProject.h\"\n#import \"CProject.h\"\n"];
    });
    
    
});

SPEC_END
