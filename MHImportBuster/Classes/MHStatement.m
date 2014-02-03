//
//  MHLOC.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import "MHStatement.h"

@implementation MHStatement
{
	NSMutableIndexSet *_codeLineNumbers;
}

+ (instancetype)statement {
	return [[self alloc] init];
}

- (id)init {
	self = [super init];
	if (self) {
		_tokens = [[NSMutableArray alloc] init];
		_codeLineNumbers = [[NSMutableIndexSet alloc] init];
	}
	return self;
}

/**
 *  Feed the next token in the line
 *
 *  @param token a token
 *
 *  @return is endToken reached
 */
- (BOOL)feedToken:(PKToken *)token {
	[self processToken:token];
	return [self containsCannonicalTokens];
}

- (void)feedTokens:(NSArray *)tokens {
	[_tokens addObjectsFromArray:tokens];
}

/**
 *  Checks if the LOC contains all the tokens needed
 *
 *  @return YES if it contains all cannonical tokens
 */
- (BOOL)containsCannonicalTokens {
	return [[self class] containsCannonicalTokens:_tokens];
}

- (NSIndexSet *)codeLineNumbers {
	return _codeLineNumbers;
}

- (void)addLineNumber:(NSInteger)lineNumber {
	[_codeLineNumbers addIndex:lineNumber];
}

- (void)processToken:(PKToken *)token {
	[_tokens addObject:token];
}

- (NSString *)endTokenString {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+ (NSArray *)cannonicalTokens {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+ (BOOL)containsCannonicalTokens:(NSArray *)tokens {
	NSInteger startTokenIndex = 0;
	NSArray *cannonicalTokens = [[self class] cannonicalTokens];
	for (PKToken *processedToken in tokens) {
		for (NSInteger tokenIndex = startTokenIndex; tokenIndex < cannonicalTokens.count; tokenIndex++) {
			if ([processedToken isEqual:cannonicalTokens[tokenIndex]]) {
				startTokenIndex++;
				break;
			}
		}
	}
	return startTokenIndex == cannonicalTokens.count;
}

+ (BOOL)isPrimaryCannonicalToken:(PKToken *)token {
	return [token isEqual:[[self class] cannonicalTokens][0]];
}

- (BOOL)isEqual:(id)object {
	return [self isEqualValue:object];
}

- (NSUInteger)hash {
	return [self.value hash];
}

- (BOOL)isEqualValue:(MHStatement *)otherStatement {
	NSString *value = self.value;
	NSString *otherValue = otherStatement.value;
	BOOL isEqual = [value isEqualToString:otherValue];
	return isEqual;
}

@end
