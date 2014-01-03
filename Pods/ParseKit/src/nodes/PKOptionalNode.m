//
//  PKNodeOptional.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "PKOptionalNode.h"

@implementation PKOptionalNode

- (NSUInteger)type {
    return PKNodeTypeOptional;
}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitOptional:self];
}

@end
