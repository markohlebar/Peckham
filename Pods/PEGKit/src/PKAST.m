// The MIT License (MIT)
// 
// Copyright (c) 2014 Todd Ditchendorf
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "PKAST.h"

@interface PKAST ()
@end

@implementation PKAST

+ (PKAST *)ASTWithToken:(PKToken *)tok {
    return [[[self alloc] initWithToken:tok] autorelease];
}


- (id)init {
    return [self initWithToken:nil];
}


- (id)initWithToken:(PKToken *)tok {
    self = [super init];
    if (self) {
        self.token = tok;
    }
    return self;
}


- (void)dealloc {
    self.token = nil;
    self.children = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    PKAST *that = [[[self class] alloc] initWithToken:_token];
    that->_children = [_children mutableCopyWithZone:zone];
    return that;
}


- (BOOL)isEqual:(id)obj {
    if (![obj isMemberOfClass:[self class]]) {
        return NO;
    }
    
    PKAST *that = (PKAST *)obj;
    
    if (![_token isEqual:that->_token]) {
        return NO;
    }
    
    if (_children && that->_children && ![_children isEqualToArray:that->_children]) {
        return NO;
    }
    
    return YES;
}


- (NSString *)description {
    return [self treeDescription];
}


- (NSString *)treeDescription {
    if (![_children count]) {
        return self.name;
    }
    
    NSMutableString *ms = [NSMutableString string];
    
    if (![self isNil]) {
        [ms appendFormat:@"(%@ ", self.name];
    }

    NSInteger i = 0;
    for (PKAST *child in _children) {
        NSString *fmt = 0 == i++ ? @"%@" : @" %@";
        [ms appendFormat:fmt, [child treeDescription]];
    }
    
    if (![self isNil]) {
        [ms appendString:@")"];
    }
    
    return [[ms copy] autorelease];
}


- (NSUInteger)type {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
    return NSNotFound;
}


- (void)addChild:(PKAST *)a {
    NSParameterAssert(a);
    if (!_children) {
        self.children = [NSMutableArray array];
    }
    [_children addObject:a];
}


- (BOOL)isNil {
    return !_token;
}


- (NSString *)name {
    return [_token stringValue];
}

@end
