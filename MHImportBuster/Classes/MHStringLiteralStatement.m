//
//  MHStringLiteralStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 20/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHStringLiteralStatement.h"
#import "PKToken+Factory.h"

@implementation MHStringLiteralStatement

- (id) value {
    if (![self containsCannonicalTokens]) {
		return nil;
	}
    
    NSArray *subtokens = [_tokens subarrayWithRange:NSMakeRange(2, _tokens.count-3)];
    NSMutableString *string = [NSMutableString string];
    [subtokens enumerateObjectsUsingBlock:^(PKToken *token, NSUInteger idx, BOOL *stop) {
        [string appendString:token.stringValue];
    }];
    return string.copy;
}

+ (NSArray *)cannonicalTokens {
    static NSArray *MHStringLiteralStatementTokens = nil;
	if (!MHStringLiteralStatementTokens) {
		MHStringLiteralStatementTokens = @[
                                            [PKToken at],
                                            [PKToken doubleQuote],
                                            [PKToken placeholderWord],
                                            [PKToken doubleQuote]
                                            ];
	}
	return MHStringLiteralStatementTokens;
}
@end
