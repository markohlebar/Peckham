//
//  MHLOC.h
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseKit/PKToken.h>

/**
 *  Represents a single tokenized code statement.
 */
@interface MHStatement : NSObject {
	@protected
	id _value;
	NSMutableArray *_tokens;
}

/**
 *  The value is available when LOC reaches endToken
 */
@property (nonatomic, readonly, strong) id value;

+ (instancetype)statement;

/**
 *  Feed the next token in the line
 *
 *  @param token a token
 *
 *  @return is endToken reached
 */
- (BOOL)feedToken:(PKToken *)token;

- (void)feedTokens:(NSArray *)tokens;

/**
 *  Processes the token
 *
 *  @param token a token
 */
- (void)processToken:(PKToken *)token;

/**
 *  Checks if the LOC contains all the tokens needed
 *
 *  @return YES if it contains all cannonical tokens
 */
- (BOOL)containsCannonicalTokens;

- (NSIndexSet *)codeLineNumbers;
- (void)addLineNumber:(NSInteger)lineNumber;

+ (BOOL)containsCannonicalTokens:(NSArray *)tokens;
+ (BOOL)isPrimaryCannonicalToken:(PKToken *)token;
+ (NSArray *)cannonicalTokens;

- (BOOL)isEqualValue:(MHStatement *)otherStatement;

@end
