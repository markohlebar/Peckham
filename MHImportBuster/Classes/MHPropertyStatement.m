//
//  MHPropertyStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHPropertyStatement.h"
#import "MHPropertyQualifierStatement.h"

@implementation MHPropertyStatement

- (id)value {
	if (![self containsCannonicalTokens]) {
		return nil;
	}
	return [_tokens[_tokens.count-2] stringValue];
}

- (NSArray *)childStatementClasses {
    return @[[MHPropertyQualifierStatement class]];
}

+ (NSArray *)cannonicalTokens {
    static NSArray *MHPropertyStatementStatementTokens = nil;
	if (!MHPropertyStatementStatementTokens) {
		MHPropertyStatementStatementTokens = @[
                                               [PKToken tokenWithTokenType:PKTokenTypeWord
                                                               stringValue:@"@property"
                                                                floatValue:0],
                                               [PKToken semicolon],
                                               ];
	}
	return MHPropertyStatementStatementTokens;
}

@end
