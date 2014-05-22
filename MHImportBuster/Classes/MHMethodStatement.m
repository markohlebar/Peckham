//
//  MHMethodStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 01/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHMethodStatement.h"
#import "PKToken+Factory.h"
#import "PKTokenizer+Factory.h"
#import "MHPropertyStatement.h"
#import "MHMethodArgumentStatement.h"
#import "MHMethodReturnStatement.h"

@implementation MHMethodStatement
- (id)value {
	if (![self containsCannonicalTokens]) {
		return nil;
	}
    
	NSMutableString *string = [NSMutableString string];
	[_tokens enumerateObjectsUsingBlock: ^(PKToken *token, NSUInteger idx, BOOL *stop) {
        if ([token isEqual:[PKToken curlyBraceLeft]]) {
            *stop = YES;
            return;
        }
        if (![token isEqual:[PKToken whitespace]]) {
            [string appendString:token.stringValue];
        }
	}];
	return string;
}

- (BOOL)containsReturnStatement {
    for (MHStatement *statement in self.children) {
        if ([statement isKindOfClass:[MHMethodReturnStatement class]]) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)childStatementClasses {
    return [self containsReturnStatement]
    ? @[
        [MHMethodArgumentStatement class]
        ]
    : @[
        [MHMethodReturnStatement class],
        [MHMethodArgumentStatement class],
        ];
}

- (MHStatement *)feedToken:(PKToken *)token {
    MHStatement *statement = [super feedToken:token];
    
    //Workaround for situation when a method is declared as +methodName or -methodName withour return value
    if (_tokens.count == 2 &&
        ![self containsReturnStatement] &&
        [token isWord]) {
        [self addChild:[MHMethodStatement defaultReturnStatement]];
    }
    return statement;
}

+ (MHMethodReturnStatement *)defaultReturnStatement {
    return [MHMethodReturnStatement statementWithString:@"(void)"];
}

@end

@implementation MHClassMethodDeclarationStatement
static NSArray *MHClassMethodDeclarationStatementTokens = nil;

+ (NSArray *)cannonicalTokens {
	if (!MHClassMethodDeclarationStatementTokens) {
		MHClassMethodDeclarationStatementTokens = @[
                                                    [PKToken plus],
                                                    [PKToken placeholderWord],
                                                    [PKToken semicolon]
                                                    ];
	}
	return MHClassMethodDeclarationStatementTokens;
}

@end

@implementation MHInstanceMethodDeclarationStatement
static NSArray *MHInstanceMethodDeclarationStatementTokens = nil;
+ (NSArray *)cannonicalTokens {
	if (!MHInstanceMethodDeclarationStatementTokens) {
		MHInstanceMethodDeclarationStatementTokens = @[
                                                       [PKToken minus],
                                                       [PKToken placeholderWord],
                                                       [PKToken semicolon]
                                                       ];
	}
	return MHInstanceMethodDeclarationStatementTokens;
}
@end


@implementation MHClassMethodImplementationStatement
static NSArray *MHClassMethodImplementationStatementTokens = nil;
+ (NSArray *)cannonicalTokens {
	if (!MHClassMethodImplementationStatementTokens) {
		MHClassMethodImplementationStatementTokens = @[
                                                       [PKToken plus],
                                                       [PKToken placeholderWord],
                                                       [PKToken curlyBraceLeft],
                                                       [PKToken curlyBraceRight]
                                                       ];
	}
	return MHClassMethodImplementationStatementTokens;
}

@end

@implementation MHInstanceMethodImplementationStatement
static NSArray *MHInstanceMethodImplementationStatementTokens = nil;
+ (NSArray *)cannonicalTokens {
	if (!MHInstanceMethodImplementationStatementTokens) {
		MHInstanceMethodImplementationStatementTokens = @[
                                                          [PKToken minus],
                                                          [PKToken placeholderWord],
                                                          [PKToken curlyBraceLeft],
                                                          [PKToken curlyBraceRight]
                                                          ];
	}
	return MHInstanceMethodImplementationStatementTokens;
}

@end
