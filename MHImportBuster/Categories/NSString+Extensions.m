//
//  NSString+Extensions.m
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "NSString+Extensions.h"

@implementation NSString (Extensions)
- (BOOL)mh_containsString:(NSString *)string {
	return [self rangeOfString:string].location != NSNotFound;
}

- (NSString *)mh_stringByRemovingWhitespacesAndNewlines {
	NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
	return [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}

- (BOOL)mh_isAlphaNumeric {
	NSCharacterSet *unwantedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
	return [self rangeOfCharacterFromSet:unwantedCharacters].location == NSNotFound;
}

- (BOOL)mh_isWhitespaceOrNewline {
	NSString *string = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
	string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	return string.length == 0;
}

@end
