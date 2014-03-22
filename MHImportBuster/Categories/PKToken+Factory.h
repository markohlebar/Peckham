//
//  PKToken+Factory.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "PKToken.h"

@interface PKToken (Factory)
/**
 *  Returns a forward slash token
 *
 *  @return a token
 */
+(PKToken*) forwardSlash;

/**
 *  Returns a dot token
 *
 *  @return a token
 */
+(PKToken*) dot;
@end
