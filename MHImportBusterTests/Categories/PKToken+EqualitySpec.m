//
//  PKToken+EqualitySpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/04/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "PKToken+Equality.h"
#import "PKToken+Factory.h"

SPEC_BEGIN(PKToken_EqualitySpec)

describe(@"PKToken+Equality", ^{
    
    __block PKToken *token = [PKToken tokenWithTokenType:PKTokenTypeWord
                                             stringValue:@"someString"
                                              doubleValue:0];
    it(@"Should be equal to the same token", ^{
        PKToken *token2 = [PKToken tokenWithTokenType:PKTokenTypeWord
                                          stringValue:@"someString"
                                           doubleValue:0];
        
        [[theValue([token isEqualIgnoringPlaceholderWord:token2]) should] beYes];
    });
    
    it(@"Should be equal to the placeholder token", ^{
        PKToken *token2 = [PKToken placeholderWord];
        [[theValue([token isEqualIgnoringPlaceholderWord:token2]) should] beYes];
    });
});

SPEC_END
