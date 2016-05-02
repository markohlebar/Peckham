//
//  NSString+CamelCase.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 02/05/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import "NSString+CamelCase.h"

@implementation NSString (CamelCase)

- (NSString *)mh_camelCaseInitials {
    NSMutableString *output = [NSMutableString string];
    NSCharacterSet *uppercase = [self mh_uppercaseSet];
    for (NSInteger idx = 0; idx < [self length]; idx += 1) {
        unichar c = [self characterAtIndex:idx];
        if ([uppercase characterIsMember:c]) {
            [output appendFormat:@"%C", c];
        }
    }
    return output.copy;
}

- (NSCharacterSet *)mh_uppercaseSet {
    static NSCharacterSet *_uppercaseSet = nil;
    if (!_uppercaseSet) {
        _uppercaseSet = [NSCharacterSet uppercaseLetterCharacterSet];
    }
    return _uppercaseSet;
}

@end
