//
//  MHMethodArgumentStatementSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 13/04/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHMethodArgumentStatement.h"
#import "MHTestTokens.h"

SPEC_BEGIN(MHMethodArgumentStatementSpec)

describe(@"MHMethodArgumentStatement", ^{

    __block MHMethodArgumentStatement *statement = nil;
    
    beforeEach(^{
        statement = [MHMethodArgumentStatement statement];
    });
    
    it(@"Should find arguments of primitive types", ^{
        feedStatement(statement, @"(BOOL) argument");
        [[statement.value should] equal:@"argument"];
    });
    
    it(@"Should find arguments of primitive types", ^{
        feedStatement(statement, @"(NSInteger) integer");
        [[statement.value should] equal:@"integer"];
    });
    
    it(@"Should find arguments of non primitive types", ^{
        feedStatement(statement, @"(NSObject *) argument");
        [[statement.value should] equal:@"argument"];
    });
    
    it(@"Should find arguments of non primitive types", ^{
        feedStatement(statement, @"(NSDictionary *) dict");
        [[statement.value should] equal:@"dict"];
    });
    
});

SPEC_END
