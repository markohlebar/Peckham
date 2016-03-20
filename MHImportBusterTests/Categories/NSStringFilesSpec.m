//
//  NSStringFilesSpec.m
//  MHImportBuster
//
//  Created by Clément Padovani on 3/20/16.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "NSString+Files.h"

SPEC_BEGIN(NSStringFilesSpec)

describe(@"NSString+Files", ^{

    __block NSString *validCharactersString = nil;

    __block NSString *invalidCharactersString = nil;

    beforeEach(^{

        NSMutableString *_validCharactersString = [NSMutableString stringWithCapacity: 258];

        [_validCharactersString appendString: @"/"];

        for (NSUInteger i = 0; i < 256; i++)
        {
            [_validCharactersString appendFormat: @"%C", (unichar) i];
        }

        [_validCharactersString appendString: @".h"];

        validCharactersString = [_validCharactersString copy];

        NSMutableString *_invalidCharactersString = [NSMutableString stringWithCapacity: 515];

        [_invalidCharactersString appendString: @"/"];

        for (NSUInteger i = 0; i < 512; i++)
        {
            [_invalidCharactersString appendFormat: @"%C", (unichar) i];
        }

        [_invalidCharactersString appendString: @".h"];

        invalidCharactersString = [_invalidCharactersString copy];

    });

    it(@"should not contain invalid characters", ^{

        [[theValue([validCharactersString containsIllegalCharacters]) should] beNo];

    });

    it(@"should contain invalid characters", ^{

        [[theValue([invalidCharactersString containsIllegalCharacters]) should] beYes];
    });

});

SPEC_END
