//
//  NSString+Extensions.h
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extensions)
-(BOOL) containsString:(NSString*) string;
-(NSString*) stringByRemovingWhitespacesAndNewlines;
-(BOOL)isAlphaNumeric;
-(BOOL)isWhitespaceOrNewline;
@end
