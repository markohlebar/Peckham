//
//  MHLOC.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import "MHStatement.h"
#import "PKToken+Equality.h"
#import "MHPropertyStatement.h"
#import "PKTokenizer+Factory.h"

@implementation MHStatement
{
	NSMutableIndexSet *_codeLineNumbers;
    MHStatement *_currentChild;
}

+ (instancetype)statement {
	return [[self alloc] init];
}

+ (instancetype)statementWithString:(NSString *) string {
    return [[self alloc] initWithString:string];
}

- (id)initWithString:(NSString *)string {
    self = [self init];
    if (self) {
        [self feedTokensFromString:string];
    }
    return self;
}

- (void) feedTokensFromString:(NSString *)string {
    PKTokenizer *tokenizer = [PKTokenizer defaultTokenizer];
    tokenizer.string = string;
    [tokenizer enumerateTokensUsingBlock:^(PKToken *tok, BOOL *stop) {
        [self feedToken:tok];
    }];
}

- (id)init {
	self = [super init];
	if (self) {
		_tokens = [[NSMutableArray alloc] init];
        _children = [[NSMutableArray alloc] init];
		_codeLineNumbers = [[NSMutableIndexSet alloc] init];
	}
	return self;
}

- (MHStatement *)feedToken:(PKToken *)token {
    if ([self shouldFeedChildren:token]) {
        for (Class childStatementClass in [self childStatementClasses]) {
            if([childStatementClass isPrimaryCannonicalToken:token]) {
                _currentChild = [childStatementClass statement];
                [self addChild:_currentChild];
                break;
            }
        }
    }
    
    if (_currentChild) {
        [_currentChild feedToken:token];
        if ([_currentChild containsCannonicalTokens]) {
            _currentChild = nil;
        }
    }
    else {
        [self processToken:token];
    }
    return self;
}

- (BOOL)shouldFeedChildren:(PKToken *)token {
    return YES;
}

- (NSArray *)childStatementClasses {
    return @[];
}

- (void) addChild:(MHStatement *)statement {
    if (![_children containsObject:statement]) {
        [_children addObject:statement];
        statement.parent = self;
    }
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
    if(![_codeLineNumbers containsIndex:lineNumber]) [_codeLineNumbers addIndex:lineNumber];
}

- (void)processToken:(PKToken *)token {
	[_tokens addObject:token];
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
            PKToken *cannonicalToken = cannonicalTokens[tokenIndex];
			if ([processedToken isEqualIgnoringPlaceholderWord:cannonicalToken]) {
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

-(BOOL) isEqual:(id)object {
    return [self isEqualValue:object];
}

-(NSUInteger) hash {
    return [self.value hash];
}

- (BOOL)isEqualValue:(MHStatement *)otherStatement {
	NSString *value = self.value;
	NSString *otherValue = otherStatement.value;
	BOOL isEqual = [value isEqualToString:otherValue];
	return isEqual;
}

@end
