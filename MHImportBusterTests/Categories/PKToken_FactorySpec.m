//
//  PKToken_FactorySpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PKToken+Factory.h"


SPEC_BEGIN(PKToken_FactorySpec)

describe(@"PKToken_Factory", ^{
    
    context(@"Forward slash", ^{
        
        it(@"Should create a forward slash token", ^{
            PKToken *token = [PKToken forwardSlash];
            [[token.value should] equal:@"/"];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
       
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken forwardSlash];
            PKToken *token2 = [PKToken forwardSlash];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"Dot", ^{
        it(@"Should create a dot token", ^{
            PKToken *token = [PKToken dot];
            [[token.value should] equal:@"."];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken dot];
            PKToken *token2 = [PKToken dot];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
});

SPEC_END
