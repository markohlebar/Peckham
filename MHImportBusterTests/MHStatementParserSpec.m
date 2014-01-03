//
//  MHLOCParserSpec.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright 2013 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHStatementParser.h"


SPEC_BEGIN(MHLOCParserSpec)

describe(@"Fake file", ^{
    __block MHStatementParser *parser = nil;
    __block NSString *fakeFilePath = @"fakeFilePath";
    __block NSNumber *isSuccessInvoked = @NO;
    __block NSNumber *isErrorInvoked = @NO;
    __block NSError *outError = nil;
    
    MHArrayBlock successBlock = ^(NSArray *array){
        isSuccessInvoked = @YES;
    };
    MHErrorBlock errorBlock = ^(NSError *error){
        outError = error;
        isErrorInvoked = @YES;
    };
    
    beforeEach(^{
        parser = [MHStatementParser parseFileAtPath:fakeFilePath
                                      success:successBlock
                                        error:errorBlock];
    });
    
    it(@"Should invoke an errorBlock if filePath is bad and the error should be correct", ^{
        [[expectFutureValue(outError) shouldEventually] beNonNil];
        [[expectFutureValue([NSNumber numberWithInteger: outError.code]) shouldEventually]
         equal:[NSNumber numberWithInteger:MHImportBusterFileDoesntExistAtPath]];
    });
});

describe(@"Existing file", ^{
    __block MHStatementParser *parser = nil;
    __block NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"MyClass" ofType:@"h"];
    
    __block NSNumber *isSuccessInvoked = @NO;
    __block NSNumber *isErrorInvoked = @NO;
    __block NSArray *outArray = nil;

    
    MHArrayBlock successBlock = ^(NSArray *array){
        outArray = array;
        isSuccessInvoked = @YES;
    };
    MHErrorBlock errorBlock = ^(NSError *error){
        isErrorInvoked = @YES;
    };
    beforeEach(^{
        parser = [MHStatementParser parseFileAtPath:filePath
                                      success:successBlock
                                        error:errorBlock];
    });
    
    it(@"Should be able to initialize with a file path", ^{
        [[parser should] beNonNil];
    });
    
    it(@"Should assign property file path after initialization", ^{
        [[parser.filePath should] beNonNil];
        [[parser.filePath should] equal:filePath];
    });
    
    it(@"Should eventually invoke a successBlock with array", ^{
        [[isSuccessInvoked shouldEventually] equal:@YES];
        [[expectFutureValue(outArray) shouldEventually] beKindOfClass:[NSArray class]];
    });
    
    it(@"Should not invoke error if there is no error", ^{
        [[isSuccessInvoked shouldEventually] equal:@YES];
        [[isErrorInvoked shouldEventually] equal:@NO];
    });
    
    it(@"Should return array with at least 2 statements", ^{
        [[expectFutureValue(outArray) shouldEventually] haveCountOfAtLeast:2];
    });
});

SPEC_END
