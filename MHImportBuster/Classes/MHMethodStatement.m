//
//  MHMethodStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 01/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHMethodStatement.h"

@implementation MHMethodStatement
- (id)value {
	if (![self containsCannonicalTokens]) {
		return nil;
	}

	NSMutableString *string = [NSMutableString string];
	[_tokens enumerateObjectsUsingBlock: ^(PKToken *token, NSUInteger idx, BOOL *stop) {
	    NSString *tokenString = token.stringValue;
	    if ([tokenString isEqualToString:@"{"]) {
	        return;
		}
	    [string appendString:tokenString];
	}];

	return string;
}

@end

@implementation MHClassMethodStatement
static NSArray *MHClassMethodStatementTokens = nil;
+ (NSArray *)cannonicalTokens {
	if (!MHClassMethodStatementTokens) {
		MHClassMethodStatementTokens = @[
		        [PKToken tokenWithTokenType:PKTokenTypeSymbol
		                                stringValue:@"+"
		                                 floatValue:0],
		        [PKToken tokenWithTokenType:PKTokenTypeSymbol
		                                stringValue:@"{"
		                                 floatValue:0],
		    ];
	}
	return MHClassMethodStatementTokens;
}

@end

@implementation MHInstanceMethodStatement
static NSArray *MHInstanceMethodStatementTokens = nil;
+ (NSArray *)cannonicalTokens {
	if (!MHInstanceMethodStatementTokens) {
		MHInstanceMethodStatementTokens = @[
		        [PKToken tokenWithTokenType:PKTokenTypeSymbol
		                                  stringValue:@"-"
		                                   floatValue:0],
		        [PKToken tokenWithTokenType:PKTokenTypeSymbol
		                                  stringValue:@"{"
		                                   floatValue:0],
		    ];
	}
	return MHInstanceMethodStatementTokens;
}

@end
