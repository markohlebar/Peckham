//
//  MHStringLiteralStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 20/05/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHStringLiteralStatement.h"


SPEC_BEGIN(MHStringLiteralStatementSpec)

describe(@"MHStringLiteralStatement", ^{

    __block MHStringLiteralStatement *statement = nil;
    
    specify(^{
        statement = [MHStringLiteralStatement statementWithString:@"@\"Test\""];
        [[statement should] beNonNil];
        [[statement.value should] equal:@"Test"];
        
        statement = [MHStringLiteralStatement statementWithString:@"@\"Test\"\""];
        [[statement should] beNonNil];
        [[statement.value should] equal:@"Test\""];
    });
    
});

SPEC_END
