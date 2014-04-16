//
//  PKToken+Factory.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#define kMHTokenPlaceholderValue @"0_MHPlaceholer"

#import "PKToken.h"

@interface PKToken (Factory)
/**
 *  Returns a / token
 *
 *  @return a token
 */
+(PKToken*) forwardSlash;

/**
 *  Returns a . token
 *
 *  @return a token
 */
+(PKToken*) dot;

/**
 *  Returns a { token
 *
 *  @return a token
 */
+(PKToken*) curlyBraceLeft;

/**
 *  Returns a } token
 *
 *  @return a token
 */
+(PKToken*) curlyBraceRight;

/**
 *  Returns a ( token
 *
 *  @return a token
 */
+(PKToken*) parenthesesLeft;

/**
 *  Returns a ) token
 *
 *  @return a token
 */
+(PKToken*) parenthesesRight;

/**
 *  Returns a placeholder word
 *
 *  @return a token
 */
+(PKToken*) placeholderWord;

/**
 *  Returns an @ token
 *
 *  @return a token
 */
+(PKToken*) at;

/**
 *  Returns a ; symbol
 *
 *  @return a token
 */
+(PKToken*) semicolon;

/**
 *  Returns a + symbol
 *
 *  @return a token
 */
+(PKToken*) plus;

/**
 *  Returns a - symbol
 *
 *  @return a token
 */
+(PKToken*) minus;

/**
 *  Returns a # symbol
 *
 *  @return a token
 */
+(PKToken*) hash;
@end
