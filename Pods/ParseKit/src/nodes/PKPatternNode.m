//
//  PKPatternNode.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKPatternNode.h"
#import <ParseKit/PKPattern.h>

@implementation PKPatternNode

- (id)copyWithZone:(NSZone *)zone {
    PKPatternNode *that = (PKPatternNode *)[super copyWithZone:zone];
    that->_string = [_string retain];
    that->_options = _options;
    return that;
}


- (BOOL)isEqual:(id)obj {
    if (![super isEqual:obj]) {
        return NO;
    }
    
    PKPatternNode *that = (PKPatternNode *)obj;
    
    if (_options != that->_options) {
        return NO;
    }
    
    return YES;
}


- (NSUInteger)type {
    return PKNodeTypePattern;
}


//- (NSString *)name {
//    NSMutableString *optsString = [NSMutableString string];
//    
//    PKPatternOptions opts = _options;
//    if (opts & PKPatternOptionsIgnoreCase) {
//        [optsString appendString:@"i"];
//    }
//    if (opts & PKPatternOptionsMultiline) {
//        [optsString appendString:@"m"];
//    }
//    if (opts & PKPatternOptionsComments) {
//        [optsString appendString:@"x"];
//    }
//    if (opts & PKPatternOptionsDotAll) {
//        [optsString appendString:@"s"];
//    }
//    if (opts & PKPatternOptionsUnicodeWordBoundaries) {
//        [optsString appendString:@"w"];
//    }
//    
//    return [NSString stringWithFormat:@"%@%@", self.token.stringValue];
//}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitPattern:self];
}


- (Class)parserClass {
    return [PKPattern class];
}


- (BOOL)isTerminal {
    return YES;
}

@end
