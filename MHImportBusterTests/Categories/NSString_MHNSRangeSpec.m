//
//  NSString_MHNSRangeSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 08/02/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "NSString+MHNSRange.h"


SPEC_BEGIN(NSString_MHNSRangeSpec)

describe(@"NSString+MHNSRange", ^{
    __block NSString *string = @"Zero\nFirst\nSecond\nThird\nEND";
    it(@"Should be able to find a range of line 0", ^{
        NSRange range = [string mhRangeOfLine:0];
        [[theValue(range.location) should] equal:@0];
        [[theValue(range.length) should] equal:@5];
    });
    
    it(@"Should be able to find a range of line 2", ^{
        NSRange range = [string mhRangeOfLine:2];
        [[theValue(range.location) should] equal:@11];
        [[theValue(range.length) should] equal:@7];
    });
    
    it(@"Should be able to find a range of line 4", ^{
        NSRange range = [string mhRangeOfLine:4];
        [[theValue(range.location) should] equal:@24];
        [[theValue(range.length) should] equal:@3];
    });
    
    it(@"Should return NSNotFound if line doesnt exist", ^{
        NSRange range = [string mhRangeOfLine:5];
        [[theValue(range.location) should] equal:[NSNumber numberWithInteger:NSNotFound]];
    });
});

SPEC_END
