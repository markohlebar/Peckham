//
//  NSString+Extensions.h
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)
- (BOOL)mh_containsString:(NSString *)string;
- (NSString *)mh_stringByRemovingWhitespacesAndNewlines;
- (BOOL)mh_isAlphaNumeric;
- (BOOL)mh_isWhitespaceOrNewline;
@end
