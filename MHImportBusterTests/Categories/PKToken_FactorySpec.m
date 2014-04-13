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
    
    context(@"Curly brace left", ^{
        it(@"Should create a curly brace left token", ^{
            PKToken *token = [PKToken curlyBraceLeft];
            [[token.value should] equal:@"{"];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken curlyBraceLeft];
            PKToken *token2 = [PKToken curlyBraceLeft];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"Curly brace right", ^{
        it(@"Should create a curly brace right token", ^{
            PKToken *token = [PKToken curlyBraceRight];
            [[token.value should] equal:@"}"];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken curlyBraceRight];
            PKToken *token2 = [PKToken curlyBraceRight];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"Parentheses left", ^{
        it(@"Should create a parentheses left token", ^{
            PKToken *token = [PKToken parenthesesLeft];
            [[token.value should] equal:@"("];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken parenthesesLeft];
            PKToken *token2 = [PKToken parenthesesLeft];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"Parentheses right", ^{
        it(@"Should create a parentheses right token", ^{
            PKToken *token = [PKToken parenthesesRight];
            [[token.value should] equal:@")"];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken parenthesesRight];
            PKToken *token2 = [PKToken parenthesesRight];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"Placeholder word", ^{
        it(@"Should create a placeholder word token", ^{
            PKToken *token = [PKToken placeholderWord];
            [[token.value should] equal:kMHTokenPlaceholderValue];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeWord)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken placeholderWord];
            PKToken *token2 = [PKToken placeholderWord];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"@ symbol", ^{
        it(@"Should create an @ symbol token", ^{
            PKToken *token = [PKToken at];
            [[token.value should] equal:@"@"];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken at];
            PKToken *token2 = [PKToken at];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"; symbol", ^{
        it(@"Should create an ; symbol token", ^{
            PKToken *token = [PKToken semicolon];
            [[token.value should] equal:@";"];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken semicolon];
            PKToken *token2 = [PKToken semicolon];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"+ symbol", ^{
        it(@"Should create an + symbol token", ^{
            PKToken *token = [PKToken plus];
            [[token.value should] equal:@"+"];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken plus];
            PKToken *token2 = [PKToken plus];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
    
    context(@"- symbol", ^{
        it(@"Should create an - symbol token", ^{
            PKToken *token = [PKToken minus];
            [[token.value should] equal:@"-"];
            [[theValue(token.tokenType) should] equal:theValue(PKTokenTypeSymbol)];
        });
        
        it(@"Should reuse the token", ^{
            PKToken *token = [PKToken minus];
            PKToken *token2 = [PKToken minus];
            [[theValue(token == token2) should] equal:@YES];
        });
    });
});

SPEC_END
