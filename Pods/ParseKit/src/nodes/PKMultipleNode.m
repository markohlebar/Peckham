//
//  PKNodeMultiple.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "PKMultipleNode.h"
#import <ParseKit/PKSequence.h>

@implementation PKMultipleNode

- (NSUInteger)type {
    return PKNodeTypeMultiple;
}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitMultiple:self];
}


- (Class)parserClass {
    return [PKSequence class];
}

@end
