//
//  PKNode.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKBaseNode.h"

@implementation PKBaseNode

+ (id)nodeWithToken:(PKToken *)tok {
    return [[[self alloc] initWithToken:tok] autorelease];
}


- (void)dealloc {
    self.parser = nil;
    self.actionNode = nil;
    self.semanticPredicateNode = nil;
    self.defName = nil;
    self.before = nil;
    self.after = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKBaseNode *that = (PKBaseNode *)[super copyWithZone:zone];
    that->_discard = _discard;
    that->_parser = _parser;
    that->_actionNode = [_actionNode retain];
    that->_semanticPredicateNode = [_semanticPredicateNode retain];
    that->_defName = [_defName retain];
    that->_before = [_before retain];
    that->_after = [_after retain];
    return that;
}


- (BOOL)isEqual:(id)obj {
    if (![super isEqual:obj]) {
        return NO;
    }

    PKBaseNode *that = (PKBaseNode *)obj;
    
    if (_discard != that->_discard) {
        return NO;
    }
    
    if (_parser != that->_parser) {
        return NO;
    }
    
    if (![_actionNode isEqual:that->_actionNode]) {
        return NO;
    }
    
    if (![_semanticPredicateNode isEqual:that->_semanticPredicateNode]) {
        return NO;
    }
    
    if (![_defName isEqual:that->_defName]) {
        return NO;
    }
    
    return YES;
}


- (void)replaceChild:(PKBaseNode *)oldChild withChild:(PKBaseNode *)newChild {
    NSParameterAssert(oldChild);
    NSParameterAssert(newChild);
    NSUInteger idx = [self.children indexOfObject:oldChild];
    NSAssert(NSNotFound != idx, @"");
    [self.children replaceObjectAtIndex:idx withObject:newChild];
}


- (void)replaceChild:(PKBaseNode *)oldChild withChildren:(NSArray *)newChildren {
    NSParameterAssert(oldChild);
    NSParameterAssert(newChildren);

    NSUInteger idx = [self.children indexOfObject:oldChild];
    NSAssert(NSNotFound != idx, @"");
    
    [self.children replaceObjectsInRange:NSMakeRange(idx, 1) withObjectsFromArray:newChildren];
}


- (void)visit:(id <PKNodeVisitor>)v; {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
}


- (Class)parserClass {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    return Nil;
}


- (BOOL)isTerminal {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    return NO;
}

@end
