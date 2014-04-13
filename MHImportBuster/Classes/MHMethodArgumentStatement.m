//
//  MHMethodArgumentStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 13/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHMethodArgumentStatement.h"

@implementation MHMethodArgumentStatement

- (id) value {
    if (![self containsCannonicalTokens]) {
		return nil;
	}
    
    return [_tokens[_tokens.count-1] stringValue];
}

+ (NSArray *)cannonicalTokens {
    static NSArray *MHMethodArgumentStatementTokens = nil;
	if (!MHMethodArgumentStatementTokens) {
		MHMethodArgumentStatementTokens = @[
                                            [PKToken parenthesesLeft],
                                            [PKToken placeholderWord],
                                            [PKToken parenthesesRight],
                                            [PKToken placeholderWord]
                                            ];
	}
	return MHMethodArgumentStatementTokens;
}

@end
