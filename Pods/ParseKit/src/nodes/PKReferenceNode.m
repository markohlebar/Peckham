//
//  PKNodeReference.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKReferenceNode.h"
#import <ParseKit/PKToken.h>
#import <ParseKit/PKSequence.h>

@implementation PKReferenceNode

- (void)dealloc {
    [super dealloc];
}


- (NSUInteger)type {
    return PKNodeTypeReference;
}


- (NSString *)name {
    NSString *str = [NSString stringWithFormat:@"#%@", self.token.stringValue];
    return str;
}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitReference:self];
}


- (Class)parserClass {
    return [PKSequence class];
}


- (BOOL)isTerminal {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    return NO;
}

@end
