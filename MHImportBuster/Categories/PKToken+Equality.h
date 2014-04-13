//
//  PKToken+Equality.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "PKToken.h"

@interface PKToken (Equality)

-(BOOL) isEqualIgnoringPlaceholderWord:(PKToken *)token;

@end
