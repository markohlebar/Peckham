//
//  PKActionNode.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKActionNode.h"

@implementation PKActionNode

- (id)copyWithZone:(NSZone *)zone {
    PKActionNode *that = (PKActionNode *)[super copyWithZone:zone];
    that->_source = [_source retain];
    return that;
}


- (BOOL)isEqual:(id)obj {
    if (![super isEqual:obj]) {
        return NO;
    }
    
    PKActionNode *that = (PKActionNode *)obj;
    
    if (![_source isEqualToString:that->_source]) {
        return NO;
    }
    
    return YES;
}


- (NSUInteger)type {
    return PKNodeTypeAction;
}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitAction:self];
}


- (Class)parserClass {
    return nil;
}

@end
