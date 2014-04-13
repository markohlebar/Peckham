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

describe(@"MHClassMethodDeclarationStatement", ^{
//    __block NSArray *tokens = classMethodTokens();
//    __block MHClassMethodDeclarationStatement *statement = [MHClassMethodDeclarationStatement statement];
//    
//    tokenFeedBlock(statement, tokens);
//    
//    it(@"Should return value +(void)classMethod", ^{
//        [[statement.value should] equal:@"+(void)classMethod"];
//	});
});

describe(@"MHInstanceMethodDeclarationStatement", ^{
//    __block NSArray *tokens = classMethodTokens();
//    __block MHInstanceMethodDeclarationStatement *statement = [MHInstanceMethodDeclarationStatement statement];
//    
//    tokenFeedBlock(statement, tokens);
//    
//    it(@"Should return value +(void)classMethod", ^{
//        [[statement.value should] equal:@"-(void)instanceMethod"];
//	});
});

describe(@"MHClassMethodImplementationStatement", ^{
    __block MHClassMethodImplementationStatement *statement = nil;
    beforeEach(^{
        statement = [MHClassMethodImplementationStatement statement];
    });
    
    it(@"Should be able to parse class methods with no arguments", ^{
        feedStatement(statement, @"+(void)classMethod {\n}");
        [[statement.value should] equal:@"+classMethod"];
	});
    
    it(@"Should be able to parse class methods with no arguments and return statements", ^{
        feedStatement(statement, @"+classMethod {\n}");
        [[statement.value should] equal:@"+classMethod"];
	});

    it(@"Should be able to parse class methods with one argument", ^{
        feedStatement(statement, @"+(void)classMethod:(BOOL) argument {\n}");
        [[statement.value should] equal:@"+classMethod:"];
	});

    it(@"Should be able to parse class methods with multiple arguments", ^{
        feedStatement(statement, @"+(void)classMethod:(BOOL) argument :(NSObject*)integer{\n}");
        [[statement.value should] equal:@"+classMethod::"];
	});
    
    it(@"Should be able to parse class methods with multiple arguments 2", ^{
        feedStatement(statement, @"+(void)classMethod:(BOOL) argument andInteger:(NSInteger)integer{\n}");
        [[statement.value should] equal:@"+classMethod:andInteger:"];
	});
});

describe(@"MHInstanceMethodImplementationStatement", ^{
    __block MHInstanceMethodImplementationStatement *statement = [MHInstanceMethodImplementationStatement statement];

    beforeEach(^{
        statement = [MHInstanceMethodImplementationStatement statement];
    });
    
    it(@"Should be able to parse instance methods with no arguments", ^{
        feedStatement(statement, @"-(void)instanceMethod {\n}");
        [[statement.value should] equal:@"-instanceMethod"];
	});
    
    it(@"Should be able to parse instance methods with no arguments and return statements", ^{
        feedStatement(statement, @"-instanceMethod {\n}");
        [[statement.value should] equal:@"-instanceMethod"];
	});
    
    it(@"Should be able to parse instance methods with one argument", ^{
        feedStatement(statement, @"-(void)instanceMethod:(BOOL) argument {\n}");
        [[statement.value should] equal:@"-instanceMethod:"];
	});
    
    it(@"Should be able to parse instance methods with multiple arguments", ^{
        feedStatement(statement, @"-(void)instanceMethod:(BOOL) argument :(NSObject*)integer{\n}");
        [[statement.value should] equal:@"-instanceMethod::"];
	});
    
    it(@"Should be able to parse instance methods with multiple arguments 2", ^{
        feedStatement(statement, @"-(void)instanceMethod:(BOOL) argument andInteger:(NSInteger)integer{\n}");
        [[statement.value should] equal:@"-instanceMethod:andInteger:"];
	});

});

SPEC_END
