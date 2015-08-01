//
//  MHTestTokens.h
//  MHImportBuster
//
//  Created by marko.hlebar on 30/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#ifndef MHImportBuster_MHTestTokens_h
#define MHImportBuster_MHTestTokens_h

#import "MHStatement.h"
#import "MHStatementParser.h"
#import <PEGKit/PKToken.h>
#import "PKTokenizer+Factory.h"

static void (^feedStatement)(MHStatement *, NSString *) = ^(MHStatement *statement, NSString *string) {
    PKTokenizer *tokenizer = [PKTokenizer defaultTokenizer];
    tokenizer.string = string;
    [tokenizer enumerateTokensUsingBlock:^(PKToken *tok, BOOL *stop) {
        [statement feedToken:tok];
    }];
};

static void (^tokenFeedBlock)(MHStatement *loc, NSArray* tokens) = ^(MHStatement *loc, NSArray* tokens) {
    beforeEach(^{
        for(PKToken *token in tokens) {
            if([loc feedToken:token]) {
                break;
            }
        }
    });
};

static NSArray* (^frameworkTokensWithStrings) (NSString*, NSString*) = ^NSArray* (NSString *subpath, NSString *header) {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:subpath doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:header doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@">" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" doubleValue:0],
             ];
};

static NSArray* (^projectTokensWithStrings) (NSString*, NSString*) = ^NSArray* (NSString *subpath, NSString *header) {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:subpath doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:header doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" doubleValue:0],
             ];
};

static NSArray* (^projectTokensWithString) (NSString*) = ^NSArray* (NSString *header) {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:header doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" doubleValue:0],
             ];
};

static NSArray* (^frameworkTokens) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Framework" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Header" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@">" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" doubleValue:0],
             ];
};

static NSArray* (^projectTokens) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Subpath" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Header" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" doubleValue:0],
             ];
};

static NSArray* (^projectTokensNoSubpath) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Header" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" doubleValue:0],
             ];
};

static NSArray* (^classMethodTokens) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"+" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"void" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@")" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"classMethod" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" doubleValue:0]
             ];
};

static NSArray* (^instanceMethodTokens) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"-" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"void" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@")" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"instanceMethod" doubleValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" doubleValue:0]
             ];
};

#endif
