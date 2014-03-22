//
//  MHMethodStatementSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 01/02/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHMethodStatement.h"
#import "MHTestTokens.h"

SPEC_BEGIN(MHMethodStatementSpec)

describe(@"MHClassMethodStatement", ^{
    __block NSArray *tokens = classMethodTokens();
    __block MHClassMethodStatement *statement = [MHClassMethodStatement statement];

    tokenFeedBlock(statement, tokens);

    it(@"Should return value +(void)classMethod", ^{
        [[statement.value should] equal:@"+(void)classMethod"];
	});
});

describe(@"MHInstanceMethodStatement", ^{
    __block NSArray *tokens = instanceMethodTokens();
    __block MHInstanceMethodStatement *statement = [MHInstanceMethodStatement statement];

    tokenFeedBlock(statement, tokens);

    it(@"Should return value -(void)instanceMethod", ^{
        [[statement.value should] equal:@"-(void)instanceMethod"];
	});
});

SPEC_END
