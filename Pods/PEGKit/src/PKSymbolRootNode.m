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

#import <PEGKit/PKReader.h>
#import "PKSymbolRootNode.h"

@interface PKSymbolNode ()
@property (nonatomic, retain) NSMutableDictionary *children;
@end

@interface PKSymbolRootNode ()
- (void)addWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p;
- (void)removeWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p;
- (NSString *)nextWithFirst:(PKUniChar)c rest:(PKReader *)r parent:(PKSymbolNode *)p;
@end

@implementation PKSymbolRootNode

- (id)init {
    if (self = [super initWithParent:nil character:PKEOF]) {
        
    }
    return self;
}


- (void)add:(NSString *)s {
    NSParameterAssert(s);
    if (![s length]) return;
    
    [self addWithFirst:[s characterAtIndex:0] rest:[s substringFromIndex:1] parent:self];
}


- (void)remove:(NSString *)s {
    NSParameterAssert(s);
    if (![s length]) return;
    
    [self removeWithFirst:[s characterAtIndex:0] rest:[s substringFromIndex:1] parent:self];
}


- (void)addWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p {
    NSParameterAssert(p);
    NSString *key = [[[NSString alloc] initWithCharacters:(const unichar *)&c length:1] autorelease];
    PKSymbolNode *child = [p.children objectForKey:key];
    if (!child) {
        child = [[[PKSymbolNode alloc] initWithParent:p character:c] autorelease];
        child.reportsAddedSymbolsOnly = self.reportsAddedSymbolsOnly;
        [p.children setObject:child forKey:key];
    }
    
    NSUInteger len = [s length];

    if (len) {
        NSString *rest = nil;

        if (len > 1) {
            rest = [s substringFromIndex:1];
        }
        
        [self addWithFirst:[s characterAtIndex:0] rest:rest parent:child];
    }
}


- (void)removeWithFirst:(PKUniChar)c rest:(NSString *)s parent:(PKSymbolNode *)p {
    NSParameterAssert(p);
    NSString *key = [[[NSString alloc] initWithCharacters:(const unichar *)&c length:1] autorelease];
    PKSymbolNode *child = [p.children objectForKey:key];
    if (child) {
        NSString *rest = nil;
        
        NSUInteger len = [s length];
        if (0 == len) {
            return;
        } else if (len > 1) {
            rest = [s substringFromIndex:1];
            [self removeWithFirst:[s characterAtIndex:0] rest:rest parent:child];
        }
        
        [p.children removeObjectForKey:key];
    }
}


- (NSString *)nextSymbol:(PKReader *)r startingWith:(PKUniChar)cin {
    NSParameterAssert(r);
    return [self nextWithFirst:cin rest:r parent:self];
}


- (NSString *)nextWithFirst:(PKUniChar)c rest:(PKReader *)r parent:(PKSymbolNode *)p {
    NSParameterAssert(p);
    NSString *result = [[[NSString alloc] initWithCharacters:(const unichar *)&c length:1] autorelease];
    
    PKSymbolNode *child = [p.children objectForKey:result];
    
    if (!child) {
        if (p == self) {
            result = self.reportsAddedSymbolsOnly ? @"" : result;
        } else {
            [r unread];
            result = @"";
        }
        return result;
    }
    
    c = [r read];
    if (PKEOF == c) {
        return result;
    }
    
    return [result stringByAppendingString:[self nextWithFirst:c rest:r parent:child]];
}

@end
