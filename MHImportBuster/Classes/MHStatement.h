//
//  MHLOC.h
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PEGKit/PKToken.h>
#import "PKToken+Factory.h"

/**
 *  Represents a single tokenized code statement.
 */
@interface MHStatement : NSObject {
	@protected
	id _value;
	NSMutableArray *_tokens;
}

/**
 *  The parent statement of this statement
 */
@property (nonatomic, strong) MHStatement *parent;

/**
 *  The children statements of this statement
 */
@property (nonatomic, strong) NSMutableArray *children;

/**
 *  The value is available when LOC reaches endToken
 */
@property (nonatomic, readonly, strong) id value;

+ (instancetype)statement;

+ (instancetype)statementWithString:(NSString *) string;

/**
 *  Feed the next token in the line
 *
 *  @param token a token
 *
 *  @return a child statement if one is found
 */
- (MHStatement *)feedToken:(PKToken *)token;

/**
 *  Processes the token
 *
 *  @param token a token
 *  @return NO if the token can't be accepted.
 */
- (BOOL)processToken:(PKToken *)token;

/**
 *  Checks if the LOC contains all the tokens needed
 *
 *  @return YES if it contains all cannonical tokens
 */
- (BOOL)containsCannonicalTokens;

/**
 *  Checks if the statement should feed children. 
 *  This is a hook for special cases and returns YES by default.
 *
 *  @return should I feed my children?
 */
- (BOOL)shouldFeedChildren:(PKToken *)token;

- (NSIndexSet *)codeLineNumbers;
- (void)addLineNumber:(NSInteger)lineNumber;

+ (BOOL)containsCannonicalTokens:(NSArray *)tokens;
+ (BOOL)isPrimaryCannonicalToken:(PKToken *)token;
+ (NSArray *)cannonicalTokens;

- (BOOL)isEqualValue:(MHStatement *)otherStatement;


- (void) addChild:(MHStatement *)statement;

- (NSDictionary *) serialize;

@end
