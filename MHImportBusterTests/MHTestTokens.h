//
//  MHTestTokens.h
//  MHImportBuster
//
//  Created by marko.hlebar on 30/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#ifndef MHImportBuster_MHTestTokens_h
#define MHImportBuster_MHTestTokens_h

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
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:subpath floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:header floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@">" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" floatValue:0],
             ];
};

static NSArray* (^projectTokensWithStrings) (NSString*, NSString*) = ^NSArray* (NSString *subpath, NSString *header) {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:subpath floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:header floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" floatValue:0],
             ];
};

static NSArray* (^frameworkTokens) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"<" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Framework" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Header" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@">" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" floatValue:0],
             ];
};

static NSArray* (^projectTokens) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Subpath" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Header" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" floatValue:0],
             ];
};

static NSArray* (^projectTokensNoSubpath) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"#import" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"Header" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"h" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"\"" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"\n" floatValue:0],
             ];
};

static NSArray* (^classMethodTokens) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"+" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"void" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@")" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"classMethod" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0]
             ];
};

static NSArray* (^instanceMethodTokens) () = ^NSArray* () {
    return @[
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"-" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"void" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@")" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeWord stringValue:@"instanceMethod" floatValue:0],
             [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0]
             ];
};

#endif
