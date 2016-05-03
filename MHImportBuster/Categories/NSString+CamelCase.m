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

- (NSArray *)mh_componentsSeparatedByCamelCase {
    NSMutableArray *components = [NSMutableArray new];
    NSCharacterSet *uppercase = [self mh_uppercaseSet];
    NSMutableString *word = nil;

    NSUInteger length = [self length];
    for (NSInteger idx = 0; idx < length; idx += 1) {
        unichar currentCharacter = [self characterAtIndex:idx];
        
        //Always create a new word for the first letter
        if (idx == 0) {
            word = [NSMutableString new];
            [components addObject:word];
        }
        else if (idx + 1 != length && [uppercase characterIsMember:currentCharacter]) {
            
            //Create subsequent words only if the next letter is lowercase
            unichar nextCharacter = [self characterAtIndex:idx + 1];
            if (![uppercase characterIsMember:nextCharacter]) {
                word = [NSMutableString new];
                [components addObject:word];
            }
        }
        
        [word appendFormat:@"%C", currentCharacter];
    }
    return components.copy;
}

@end
