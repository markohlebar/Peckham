//
//  PKNodeTerminal.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKConstantNode.h"
#import <ParseKit/ParseKit.h>

static NSDictionary *sClassTab = nil;

@implementation PKConstantNode

+ (void)initialize {
    if ([PKConstantNode class] == self) {
        sClassTab = [@{
            @"EOF"              : [PKAny class], // TODO
            @"Word"             : [PKWord class],
            @"LowercaseWord"    : [PKLowercaseWord class],
            @"UppercaseWord"    : [PKUppercaseWord class],
            @"Number"           : [PKNumber class],
            @"QuotedString"     : [PKQuotedString class],
            @"Symbol"           : [PKSymbol class],
            @"Comment"          : [PKComment class],
            @"Empty"            : [PKEmpty class],
            @"Any"              : [PKAny class],
            @"S"                : [PKWhitespace class],
                     
            @"Digit"            : [PKDigit class],
            @"Letter"           : [PKLetter class],
            @"Char"             : [PKChar class],
            @"SpecificChar"     : [PKSpecificChar class],
        } retain];
    }
}


- (void)dealloc {
    self.literal = nil;
    self.tokenKind = nil;
    [super dealloc];
}


- (NSUInteger)type {
    return PKNodeTypeConstant;
}


- (NSString *)name {
    NSString *res = nil;
    
    if (_literal) {
        res = [NSString stringWithFormat:@"%@('%@')", self.token.stringValue, _literal];
    } else {
        res = [super name];
    }

    return  res;
}


- (void)visit:(id <PKNodeVisitor>)v; {
    [v visitConstant:self];
}


- (Class)parserClass {
    NSString *typeName = self.token.stringValue;
    Class cls = sClassTab[typeName];
    NSAssert1(cls, @"missing constant class for token %@", typeName);
    return cls;
}


- (BOOL)isTerminal {
    return YES;
}

@end
