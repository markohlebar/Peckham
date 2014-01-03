//
//  PKSTokenKindDescriptor.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/27/13.
//
//

#import "PKSTokenKindDescriptor.h"
#import <ParseKit/PKSParser.h>

static NSMutableDictionary *sCache = nil;

@implementation PKSTokenKindDescriptor

+ (void)initialize {
    if ([PKSTokenKindDescriptor class] == self) {
        sCache = [[NSMutableDictionary alloc] init];
    }
}


+ (PKSTokenKindDescriptor *)descriptorWithStringValue:(NSString *)s name:(NSString *)name {
    PKSTokenKindDescriptor *desc = sCache[name];
    
    if (!desc) {
        desc = [[[PKSTokenKindDescriptor alloc] init] autorelease];
        desc.stringValue = s;
        desc.name = name;
        
        sCache[name] = desc;
    }
    
    return desc;
}


+ (PKSTokenKindDescriptor *)anyDescriptor {
    return [PKSTokenKindDescriptor descriptorWithStringValue:@"TOKEN_KIND_BUILTIN_ANY" name:@"TOKEN_KIND_BUILTIN_ANY"];
}


+ (PKSTokenKindDescriptor *)eofDescriptor {
    return [PKSTokenKindDescriptor descriptorWithStringValue:@"TOKEN_KIND_BUILTIN_EOR" name:@"TOKEN_KIND_BUILTIN_EOF"];
}


+ (void)clearCache {
    [sCache removeAllObjects];
}


- (void)dealloc {
    self.stringValue = nil;
    self.name = nil;
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p '%@' %@>", [self class], self, _stringValue, _name];
}


- (BOOL)isEqual:(id)obj {
    if (![obj isMemberOfClass:[self class]]) {
        return NO;
    }
    
    PKSTokenKindDescriptor *that = (PKSTokenKindDescriptor *)obj;
    
    if (![_stringValue isEqualToString:that->_stringValue]) {
        return NO;
    }
    
    NSAssert([_name isEqualToString:that->_name], @"if the stringValues match, so should the names");
    
    return YES;
}

@end
