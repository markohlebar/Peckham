//
//  MHRemoveDuplicateImportsOperationSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHRemoveDuplicateImportsOperation.h"


SPEC_BEGIN(MHRemoveDuplicateImportsOperationSpec)

describe(@"MHRemoveDuplicateImportsOperation", ^{
    __block MHRemoveDuplicateImportsOperation *operation = nil;
    __block NSTextStorage *testSource = [[NSTextStorage alloc] initWithString:@"#import <Framework/Framework.h>\n#import <Framework/Framework.h>\n#import <Framework/Framework.h>\n"];
    
    beforeEach(^{
        operation = [MHRemoveDuplicateImportsOperation operationWithSource:testSource];
    });
    
    it(@"Should remove duplicate imports from source", ^{
        [operation execute];
        [[operation.source.string should] equal:@"#import <Framework/Framework.h>\n"];
    });
    
});

SPEC_END
