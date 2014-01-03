//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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
    
    if (![_children isEqualToArray:that->_children]) {
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
