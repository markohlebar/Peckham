//
//  PKCollectionNode.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKCollectionNode.h"
#import <ParseKit/ParseKit.h>

static NSDictionary *sClassTab = nil;

@implementation PKCollectionNode

+ (void)initialize {
    if ([PKCollectionNode class] == self) {
        sClassTab = [@{
            @"." : [PKSequence class],
            @"[" : [PKTrack class],
            @"%" : [PKDelimitedString class],
            @"&" : [PKIntersection class],
            @"|" : [PKAlternation class],
            @"{" : [PKSequence class],
        } retain];
    }
}


- (NSUInteger)type {
    return PKNodeTypeCollection;
}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitCollection:self];
}


- (Class)parserClass {
    NSString *typeName = self.token.stringValue;
    Class cls = sClassTab[typeName];
    NSAssert1(cls, @"missing collection class for token %@", typeName);
    return cls;
}

@end
