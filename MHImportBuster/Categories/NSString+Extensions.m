//
//  NSString+Extensions.m
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)
-(BOOL) containsString:(NSString*) string {
    return [self rangeOfString:string].location != NSNotFound;
}

-(NSString*) stringByRemovingWhitespaces {
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (BOOL) isAlphaNumeric {
    NSCharacterSet *unwantedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    return [self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound;
}

-(BOOL)isWhitespaceOrNewline {
    NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return string.length == 0;
}

@end
