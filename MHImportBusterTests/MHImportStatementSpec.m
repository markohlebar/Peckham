//
//  MHImportLOCSpec.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright 2013 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHImportStatement.h"
#import "MHTestTokens.h"

SPEC_BEGIN(MHImportStatementSpec)

describe(@"Framework headers", ^{
    __block MHImportStatement *statement = nil;
    beforeEach(^{
        statement = [MHFrameworkImportStatement statement];
        feedStatement(statement, @"#import <Framework/Header.h>\n");
    });
    
    it(@"Should return value #import <Framework/Header.h>", ^{
        [[statement.value should] equal:@"#import <Framework/Header.h>"];
    });
});

describe(@"Project headers", ^{
    __block MHImportStatement *statement = nil;
    beforeEach(^{
        statement = [MHProjectImportStatement statement];
        feedStatement(statement, @"#import \"Subpath/Header.h\"\n");
    });

    it(@"Should return value #import \"Subpath/Header.h\"", ^{
        [[statement.value should] equal:@"#import \"Subpath/Header.h\""];
    });
});

describe(@"Project headers with no subpath", ^{
    __block MHImportStatement *statement = nil;
    beforeEach(^{
        statement = [MHProjectImportStatement statement];
        feedStatement(statement, @"#import \"Header.h\"\n");
    });
    
    it(@"Should return value #import \"Header.h\"", ^{
        [[statement.value should] equal:@"#import \"Header.h\""];
    });
});

SPEC_END
