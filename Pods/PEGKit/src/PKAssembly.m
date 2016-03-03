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

#import <PEGKit/PKAssembly.h>
#import <PEGKit/PKTokenizer.h>
#import <PEGKit/PKToken.h>

static NSString * const PKAssemblyDefaultDelimiter = @"/";
static NSString * const PKAssemblyDefaultCursor = @"^";

@interface PKAssembly ()
- (NSString *)consumedObjectsJoinedByString:(NSString *)delimiter;
- (NSString *)lastConsumedObjects:(NSUInteger)len joinedByString:(NSString *)delimiter;

@property (nonatomic, readwrite, retain) NSMutableArray *stack;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, retain) NSString *defaultDelimiter;
@property (nonatomic, retain) NSString *defaultCursor;
@property (nonatomic, readonly) NSUInteger objectsConsumed;

- (void)consume:(PKToken *)tok;
@property (nonatomic, retain) NSMutableArray *tokens;
@end

@implementation PKAssembly

+ (PKAssembly *)assembly {
    return [[[self alloc] init] autorelease];
}


- (id)init {
    self = [super init];
    if (self) {
        self.stack = [NSMutableArray array];
#if defined(NDEBUG)
        self.gathersConsumedTokens = NO;
        self.defaultCursor = @"";
#else
        self.gathersConsumedTokens = YES;
#endif
    }
    return self;
}


- (void)dealloc {
    self.stack = nil;
    self.target = nil;
    self.defaultDelimiter = nil;
    self.defaultCursor = nil;
    self.tokens = nil;
    [super dealloc];
}


- (NSString *)description {
    NSMutableString *s = [NSMutableString stringWithString:@"["];
    
    NSUInteger i = 0;
    NSUInteger len = [_stack count];
    
    NSString *fmt = @"%@, ";
    for (id obj in _stack) {
        if (len - 1 == i++) {
            fmt = @"%@";
        }
        [s appendFormat:fmt, obj];
    }
    
    NSString *d = _defaultDelimiter ? _defaultDelimiter : PKAssemblyDefaultDelimiter;
    NSString *c = _defaultCursor ? _defaultCursor : PKAssemblyDefaultCursor;
    [s appendFormat:@"]%@%@", [self consumedObjectsJoinedByString:d], c];
    
    return [[s copy] autorelease];
}


- (void)consume:(PKToken *)tok {
    if (_preservesWhitespaceTokens || !tok.isWhitespace) {
        [self push:tok];
        ++self.index;

        if (_gathersConsumedTokens) {
            if (!_tokens) {
                self.tokens = [NSMutableArray array];
            }
            [_tokens addObject:tok];
        }
    }
}


- (id)pop {
    id result = nil;
    if (![self isStackEmpty]) {
        result = [[[_stack lastObject] retain] autorelease];
        [_stack removeLastObject];
    }
    return result;
}


- (void)push:(id)object {
    if (object) {
        [_stack addObject:object];
    }
}


- (BOOL)isStackEmpty {
    return 0 == [_stack count];
}


- (NSArray *)objectsAbove:(id)fence {
    NSMutableArray *result = [NSMutableArray array];
    
    while (![self isStackEmpty]) {        
        id obj = [self pop];
        
        if ([obj isEqual:fence]) {
            [self push:obj];
            break;
        } else {
            [result addObject:obj];
        }
    }
    
    return result;
}


- (NSUInteger)objectsConsumed {
    return self.index;
}


- (NSString *)consumedObjectsJoinedByString:(NSString *)delimiter {
    NSParameterAssert(delimiter);
    return [self objectsFrom:0 to:self.objectsConsumed separatedBy:delimiter];
}


- (NSString *)lastConsumedObjects:(NSUInteger)len joinedByString:(NSString *)delimiter {
    NSParameterAssert(delimiter);
    
    if (!_gathersConsumedTokens) return @"";

    NSUInteger end = self.objectsConsumed;

    len = MIN(end, len);
    NSUInteger loc = end - len;

    NSAssert(loc < [_tokens count], @"");
    NSAssert(len <= [_tokens count], @"");
    NSAssert(loc + len <= [_tokens count], @"");
    
    NSRange r = NSMakeRange(loc, len);
    NSArray *objs = [_tokens subarrayWithRange:r];
    
    NSString *s = [objs componentsJoinedByString:delimiter];
    return s;
}


#pragma mark -
#pragma mark Private

- (NSString *)objectsFrom:(NSUInteger)start to:(NSUInteger)end separatedBy:(NSString *)delimiter {
    NSParameterAssert(delimiter);
    NSParameterAssert(start <= end);
    
    if (!_gathersConsumedTokens) return @"";

    NSMutableString *s = [NSMutableString string];

    NSParameterAssert(end <= [_tokens count]);

    for (NSInteger i = start; i < end; i++) {
        PKToken *tok = [_tokens objectAtIndex:i];
        if (PKTokenTypeEOF != tok.tokenType) {
            [s appendString:tok.stringValue];
            if (end - 1 != i) {
                [s appendString:delimiter];
            }
        }
    }
    
    return [[s copy] autorelease];
}

@end
