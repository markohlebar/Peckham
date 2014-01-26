//
//  MHLOCSpec.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright 2013 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHStatement.h"
#import "MHTestTokens.h"

@interface MHStatementTest : MHStatement

@end

@implementation MHStatementTest

static NSArray *MHLOCTestTokens = nil;
+(NSArray*) cannonicalTokens {
    if (!MHLOCTestTokens) {
        MHLOCTestTokens = @[
                            [PKToken tokenWithTokenType:PKTokenTypeWord
                                            stringValue:@"#import"
                                             floatValue:0],
                            [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                            stringValue:@"\""
                                             floatValue:0],
                            [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                            stringValue:@"\""
                                             floatValue:0],
                            ];
    }
    return MHLOCTestTokens;
}
@end


SPEC_BEGIN(MHStatementSpec)

describe(@"MHStatement", ^{

    __block PKToken *token = [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" floatValue:0];
    __block MHStatement *statement = nil;
    
    beforeEach(^{
        statement = [MHStatementTest statement];
    });
    
    it(@"Should be able to instantiate", ^{
        [[statement should] beNonNil];
    });
    
    it(@"Should be able to feed new token", ^{
        [statement feedToken:token];
    });

    it(@"Should return YES if contains all the needed cannonical tokens", ^{
        
        BOOL contains = NO;
        for(PKToken *token in projectTokens()) {
            if ([statement feedToken:token]) {
                contains = YES;
                break;
            }
        }
        
        [[theValue(contains) should] equal:@YES];
    });
});


SPEC_END
