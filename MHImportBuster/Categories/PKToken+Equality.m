//
//  PKToken+Equality.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "PKToken+Equality.h"
#import "PKToken+Factory.h"

@implementation PKToken (Equality)

- (BOOL)isEqualIgnoringPlaceholderWord:(PKToken *)token {
    BOOL isEqual = [self isEqual:token];
    if (isEqual) return YES;
    if (!(self.isWord && token.isWord)) {
        return NO;
    }
    return [self isPlaceholder] || [token isPlaceholder];
}

- (BOOL)isPlaceholder {
    return ([self->stringValue isEqualToString:kMHTokenPlaceholderValue]);
}

@end
