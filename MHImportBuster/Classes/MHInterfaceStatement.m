//
//  MHInterfaceStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHInterfaceStatement.h"
#import "PKToken+Factory.h"
#import "MHPropertyStatement.h"
#import "MHMethodStatement.h"
#import "MHConcreteSourceOperation.h"

@implementation MHInterfaceStatement

- (id)value {
	if (![self containsCannonicalTokens]) {
		return nil;
	}
	return [_tokens[2] stringValue];
}

+ (NSArray *)cannonicalTokens {
    static NSArray *MHInterfaceStatementTokens = nil;
	if (!MHInterfaceStatementTokens) {
		MHInterfaceStatementTokens = @[
                                       [PKToken tokenWithTokenType:PKTokenTypeWord
                                                       stringValue:@"@interface"
                                                        doubleValue:0],
                                       [PKToken placeholderWord],
                                       [PKToken tokenWithTokenType:PKTokenTypeWord
                                                       stringValue:@"@end"
                                                        doubleValue:0]
                                       ];
	}
	return MHInterfaceStatementTokens;
}

- (NSArray *)childStatementClasses {
    return @[
             [MHPropertyStatement class],
             [MHClassMethodDeclarationStatement class],
             [MHInstanceMethodDeclarationStatement class]
             ];
}

@end
