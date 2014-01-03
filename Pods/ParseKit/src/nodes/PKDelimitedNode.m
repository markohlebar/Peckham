//
//  PKNodeDelimited.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "PKDelimitedNode.h"
#import <ParseKit/PKDelimitedString.h>

@implementation PKDelimitedNode

- (void)dealloc {
    self.startMarker = nil;
    self.endMarker = nil;
    self.tokenKind = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKDelimitedNode *that = (PKDelimitedNode *)[super copyWithZone:zone];
    that->_startMarker = [_startMarker retain];
    that->_endMarker = [_endMarker retain];
    that->_tokenKind = [_tokenKind retain];
    return that;
}


- (BOOL)isEqual:(id)obj {
    if (![super isEqual:obj]) {
        return NO;
    }
    
    PKDelimitedNode *that = (PKDelimitedNode *)obj;
    
    if (![_startMarker isEqual:that->_startMarker]) {
        return NO;
    }
    
    if (![_endMarker isEqual:that->_endMarker]) {
        return NO;
    }
    
    if (![_tokenKind isEqual:that->_tokenKind]) {
        return NO;
    }
    
    
    return YES;
}


- (NSUInteger)type {
    return PKNodeTypeDelimited;
}


- (NSString *)name {
    NSMutableString *mstr = [NSMutableString stringWithFormat:@"%%{'%@', '%@'", _startMarker, _endMarker];
    
    // TODO add charset
    
    [mstr appendString:@"}"];
    return [[mstr copy] autorelease];
}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitDelimited:self];
}


- (Class)parserClass {
    return [PKDelimitedString class];
}


- (BOOL)isTerminal {
    return YES;
}

@end
