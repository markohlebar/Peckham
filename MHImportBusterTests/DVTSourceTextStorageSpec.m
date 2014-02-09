//
//  DVTSourceTextStorageSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 08/02/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "DVTSourceTextStorage+Operations.h"

SPEC_BEGIN(DVTSourceTextStorageSpec)

describe(@"DVTSourceTextStorage", ^{
    __block NSTextStorage *textStorage = nil;
    __block NSString *mockText = @"MOCK";
    __block NSString *mockTextWithNewLine = @"MOCK\n";

    
    beforeEach(^{
        NSString *string = @"Zero\nFirst\nSecond\nThird\nEND";
        textStorage = [[NSTextStorage alloc] initWithString:string];
    });
    
    describe(@"Inserting", ^{
        it(@"Should be able to insert text at 0 line", ^{
            [textStorage mhInsertString:mockText atLine:0];
            [[textStorage.string should] equal:@"MOCKZero\nFirst\nSecond\nThird\nEND"];
        });
        
        it(@"Should be able to insert text at middle line", ^{
            [textStorage mhInsertString:mockText atLine:2];
            [[textStorage.string should] equal:@"Zero\nFirst\nMOCKSecond\nThird\nEND"];
        });

        it(@"Should be able to insert text at end of file", ^{
            [textStorage mhInsertString:mockText atLine:4];
            [[textStorage.string should] equal:@"Zero\nFirst\nSecond\nThird\nMOCKEND"];
        });
        
        it(@"Should not insert a line if it's out of bounds", ^{
            [textStorage mhInsertString:mockText atLine:5];
            [[textStorage.string should] equal:@"Zero\nFirst\nSecond\nThird\nEND"];
        });
        
        it(@"Should be able to insert text with new line at middle line", ^{
            [textStorage mhInsertString:mockTextWithNewLine atLine:2];
            [[textStorage.string should] equal:@"Zero\nFirst\nMOCK\nSecond\nThird\nEND"];
        });
    });

    describe(@"Deleting", ^{
        it(@"Should be able to delete line 0", ^{
            [textStorage mhDeleteLine:0];
            [[textStorage.string should] equal:@"First\nSecond\nThird\nEND"];
        });
        
        it(@"Should be able to delete line 2", ^{
            [textStorage mhDeleteLine:2];
            [[textStorage.string should] equal:@"Zero\nFirst\nThird\nEND"];
        });
        
        it(@"Should be able to delete line 4", ^{
            [textStorage mhDeleteLine:4];
            [[textStorage.string should] equal:@"Zero\nFirst\nSecond\nThird\n"];
        });
    });
    
    describe(@"Batch Deleting", ^{
        it(@"Should be able to delete lines 0 and 1", ^{
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [indexSet addIndex:0];
            [indexSet addIndex:1];
            [textStorage mhDeleteLines:indexSet];
            [[textStorage.string should] equal:@"Second\nThird\nEND"];
        });
        
        it(@"Should be able to delete lines 0 and 2", ^{
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [indexSet addIndex:0];
            [indexSet addIndex:2];
            [textStorage mhDeleteLines:indexSet];
            [[textStorage.string should] equal:@"First\nThird\nEND"];
        });
        
        it(@"Should be able to delete lines 0, 2 and 4", ^{
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
            [indexSet addIndex:0];
            [indexSet addIndex:2];
            [indexSet addIndex:4];
            [textStorage mhDeleteLines:indexSet];
            [[textStorage.string should] equal:@"First\nThird\n"];
        });
    });
});

SPEC_END
