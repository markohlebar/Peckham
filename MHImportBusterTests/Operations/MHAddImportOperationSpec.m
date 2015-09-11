//
//  MHAddImportOperationSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHAddImportOperation.h"
#import "MHImportStatement.h"
#import "MHTestTokens.h"

SPEC_BEGIN(MHAddImportOperationSpec)

describe(@"MHAddImportOperation", ^{
    __block MHAddImportOperation *operation = nil;
    __block NSTextStorage *testSource = [[NSTextStorage alloc] initWithString:@"@import Framework\n#import <Framework/Framework.h>\n#import <Framework/Framework.h>\n#import <Framework/Framework.h>\n"];
    
    beforeEach(^{
        MHProjectImportStatement *importStatement = [MHProjectImportStatement statementWithString:@"#import \"newImport.h\""];
        operation = [MHAddImportOperation operationWithSource:testSource
                                                  importToAdd:importStatement];
    });
    
    it(@"Should add an import after other source imports", ^{
        [operation execute];
        [[operation.source.string shouldEventually] equal:@"@import Framework\n#import <Framework/Framework.h>\n#import <Framework/Framework.h>\n#import \"newImport.h\"\n"];
    });
    
    it(@"Should not add another import if the import exists already", ^{
        [operation execute];
        [operation execute];
        [[operation.source.string shouldEventually] equal:@"@import Framework\n#import <Framework/Framework.h>\n#import <Framework/Framework.h>\n#import \"newImport.h\"\n"];
    });
});

SPEC_END
