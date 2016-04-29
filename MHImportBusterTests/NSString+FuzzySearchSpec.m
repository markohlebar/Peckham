//
//  NSString+FuzzySearchSpec.m
//  MHImportBuster
//
//  Created by Clément Padovani on 4/29/16.
//  Copyright 2016 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "NSString+FuzzySearch.h"


SPEC_BEGIN(NSString_FuzzySearchSpec)

describe(@"NSString+FuzzySearch", ^{

    __block NSString *searchStringWithSingleWord = nil;

    __block NSString *searchStringWithTwoWords = nil;

    beforeAll(^{

        NSString *_searchStringWithSingleWord = @"helloWorld";

        searchStringWithSingleWord = [_searchStringWithSingleWord mh_fuzzifiedSearchString];

        NSString *_searchStringWithTwoWords = @"hello world";

        searchStringWithTwoWords = [_searchStringWithTwoWords mh_fuzzifiedSearchString];

    });

    it(@"should not have empty search strings", ^{
        [[searchStringWithSingleWord shouldNot] beNil];

        [[searchStringWithSingleWord should] beKindOfClass: [NSString class]];

        [[searchStringWithSingleWord shouldNot] beEmpty];

        [[searchStringWithTwoWords shouldNot] beNil];

        [[searchStringWithTwoWords should] beKindOfClass: [NSString class]];

        [[searchStringWithTwoWords shouldNot] beEmpty];
    });

    it(@"should be equal to fuzzy search strings", ^{

        [[searchStringWithSingleWord should] equal: @"*h*e*l*l*o*W*o*r*l*d*"];

        [[searchStringWithTwoWords should] equal: @"*h*e*l*l*o* *w*o*r*l*d*"];

    });
});

SPEC_END
