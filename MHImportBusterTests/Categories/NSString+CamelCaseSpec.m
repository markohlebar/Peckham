//
//  NSString+CamelCaseSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 02/05/2016.
//  Copyright 2016 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "NSString+CamelCase.h"


SPEC_BEGIN(NSString_CamelCaseSpec)

describe(@"NSString+CamelCase", ^{
    
    context(@"Initials", ^{
        it(@"Should return initials from camelcase strings", ^{
            [[[@"test" mh_camelCaseInitials] should] equal:@""];
            [[[@"MHDocumentObserver" mh_camelCaseInitials] should] equal:@"MHDO"];
        });
    });

    context(@"Decomposition", ^{
        it(@"Should decompose a lowercase string", ^{
            [[[@"test" mh_componentsSeparatedByCamelCase][0] should] equal:@"test"];
        });
        
        it(@"Should decompose a uppercase string", ^{
            [[[@"Test" mh_componentsSeparatedByCamelCase][0] should] equal:@"Test"];
        });
        
        it(@"Should decompose 2 uppercase strings", ^{
            NSArray *components = [@"TestClass" mh_componentsSeparatedByCamelCase];
            [[components[0] should] equal:@"Test"];
            [[components[1] should] equal:@"Class"];
        });
        
        it(@"Should decompose 3 uppercase strings", ^{
            NSArray *components = [@"TestSuperClass" mh_componentsSeparatedByCamelCase];
            [[components[0] should] equal:@"Test"];
            [[components[1] should] equal:@"Super"];
            [[components[2] should] equal:@"Class"];
        });
        
        it(@"Should decompose a prefix and uppercase string", ^{
            NSArray *components = [@"ABCTest" mh_componentsSeparatedByCamelCase];
            [[components[0] should] equal:@"ABC"];
            [[components[1] should] equal:@"Test"];
        });
        
        it(@"Should decompose a one letter string", ^{
            NSArray *components = [@"a" mh_componentsSeparatedByCamelCase];
            [[components[0] should] equal:@"a"];
            
            components = [@"A" mh_componentsSeparatedByCamelCase];
            [[components[0] should] equal:@"A"];
        });
        
        it(@"Should decompose a two letter capital string", ^{
            NSArray *components = [@"AA" mh_componentsSeparatedByCamelCase];
            [[components[0] should] equal:@"AA"];
        });
    });
    
});

SPEC_END
