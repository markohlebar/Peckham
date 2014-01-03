//
//  PKDelimitDescriptor.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/20/13.
//
//

#import "PKDelimitDescriptor.h"

@implementation PKDelimitDescriptor

+ (PKDelimitDescriptor *)descriptorWithStartMarker:(NSString *)start endMarker:(NSString *)end characterSet:(NSCharacterSet *)cs {
    PKDelimitDescriptor *desc = [[[[self class] alloc] init] autorelease];
    desc.startMarker = start;
    desc.endMarker = end;
    desc.characterSet = cs;
    return desc;
}


- (void)dealloc {
    self.startMarker = nil;
    self.endMarker = nil;
    self.characterSet = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKDelimitDescriptor *desc = NSAllocateObject([self class], 0, zone);
    desc->_startMarker = [_startMarker retain];
    desc->_endMarker = [_endMarker retain];
    desc->_characterSet = [_characterSet retain];
    return desc;
}


- (BOOL)isEqual:(id)obj {
    if (![obj isMemberOfClass:[self class]]) {
        return NO;
    }
    
    PKDelimitDescriptor *desc = (PKDelimitDescriptor *)obj;

    if (![_startMarker isEqualToString:desc->_startMarker]) {
        return NO;
    }

    if (![_endMarker isEqualToString:desc->_endMarker]) {
        return NO;
    }

    if (![_characterSet isEqual:desc->_characterSet]) {
        return NO;
    }
    
    return YES;
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ %p %@ %@>", [self class], self, _startMarker, _endMarker];
}

@end
