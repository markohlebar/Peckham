//
//  MHPropertyQualifierStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHPropertyQualifierStatement.h"

@implementation MHPropertyQualifierStatement

- (NSArray *)childStatementClasses {
    return @[];
}

+ (NSArray *)cannonicalTokens {
    static NSArray *MHPropertyQualifierStatementTokens = nil;
	if (!MHPropertyQualifierStatementTokens) {
		MHPropertyQualifierStatementTokens = @[
                                               [PKToken parenthesesLeft],
                                               [PKToken parenthesesRight]
                                               ];
	}
	return MHPropertyQualifierStatementTokens;
}

@end
