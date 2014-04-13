//
//  MHMethodReturnStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 13/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHMethodReturnStatement.h"

@implementation MHMethodReturnStatement

+ (NSArray *)cannonicalTokens {
    static NSArray *MHMethodReturnStatementTokens = nil;
	if (!MHMethodReturnStatementTokens) {
		MHMethodReturnStatementTokens = @[
                                            [PKToken parenthesesLeft],
                                            [PKToken placeholderWord],
                                            [PKToken parenthesesRight],
                                            ];
	}
	return MHMethodReturnStatementTokens;
}

@end
