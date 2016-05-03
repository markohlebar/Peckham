//
//  MHCreateSearchDictionaryOperationSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 03/05/2016.
//  Copyright 2016 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHCreateSearchDictionaryOperation.h"
#import "MHConcreteSourceFile.h"


SPEC_BEGIN(MHCreateSearchDictionaryOperationSpec)

describe(@"MHCreateSearchDictionaryOperation", ^{
    
    __block NSOperationQueue *_queue = nil;
    __block MHCreateSearchDictionaryOperation *_operation = nil;
    __block NSDictionary *_dictionary = nil;
    
    void (^createDictionary)(NSArray *) = ^(NSArray *searchArray) {
        _operation = [MHCreateSearchDictionaryOperation operationWithSearchArray:searchArray
                                                           searchDictionaryBlock:^(NSDictionary *dictionary) {
                                                               _dictionary = dictionary;
                                                           }];
        [_queue addOperation:_operation];
    };
    
    beforeEach(^{
        _queue = [NSOperationQueue new];
        _operation = nil;
        _dictionary = nil;
    });
    
    context(@"Words dictionary", ^{
        it(@"Should create a dictionary for a single import with one word", ^{
            id sourceFile1 = [MHConcreteSourceFile sourceFileWithName:@"File.h"];
            createDictionary(@[
                               sourceFile1
                               ]);
            
            [[expectFutureValue(_dictionary) shouldEventually] equal:@{
                                                                       @"File" : @[sourceFile1]
                                                                       }];
        });
        
        it(@"Should create a dictionary for a single import with two word", ^{
            id sourceFile1 = [MHConcreteSourceFile sourceFileWithName:@"TestFile.h"];
            createDictionary(@[
                               sourceFile1
                               ]);
            
            [[expectFutureValue(_dictionary) shouldEventually] equal:@{
                                                                       @"File" : @[sourceFile1],
                                                                       @"Test" : @[sourceFile1]
                                                                       }];
        });
        
        it(@"Should create a dictionary for a two import with three words", ^{
            id sourceFile1 = [MHConcreteSourceFile sourceFileWithName:@"TestFile.h"];
            id sourceFile2 = [MHConcreteSourceFile sourceFileWithName:@"TestLobby.h"];

            createDictionary(@[
                               sourceFile1,
                               sourceFile2
                               ]);
            
            [[expectFutureValue(_dictionary) shouldEventually] equal:@{
                                                                       @"File" : @[sourceFile1],
                                                                       @"Test" : @[sourceFile1, sourceFile2],
                                                                       @"Lobby" : @[sourceFile2]
                                                                       }];
        });
        
        it(@"Should create a dictionary for an extended tree with prefixes", ^{
            id sourceFile1 = [MHConcreteSourceFile sourceFileWithName:@"ABCTestFile.h"];
            id sourceFile2 = [MHConcreteSourceFile sourceFileWithName:@"ABCTestLobby.h"];
            id sourceFile3 = [MHConcreteSourceFile sourceFileWithName:@"ABCMyTestLobby.h"];
            id sourceFile4 = [MHConcreteSourceFile sourceFileWithName:@"DEFJobby.h"];
            id sourceFile5 = [MHConcreteSourceFile sourceFileWithName:@"DEFTest.h"];

            createDictionary(@[
                               sourceFile1,
                               sourceFile2,
                               sourceFile3,
                               sourceFile4,
                               sourceFile5
                               ]);
            
            NSDictionary *desiredDictionary = @{
                                                @"ABC" : @[sourceFile1, sourceFile2, sourceFile3],
                                                @"DEF" : @[sourceFile4, sourceFile5],
                                                @"Test" : @[sourceFile1, sourceFile2, sourceFile3, sourceFile5],
                                                @"File" : @[sourceFile1],
                                                @"Lobby" : @[sourceFile2, sourceFile3],
                                                @"My": @[sourceFile3],
                                                @"Jobby": @[sourceFile4]
                                                };
            
            [[expectFutureValue(_dictionary) shouldEventually] equal:desiredDictionary];
        });
    });
});

SPEC_END
