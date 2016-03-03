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

#import <PEGKit/PKTokenizerState.h>
#import <PEGKit/PKTokenizer.h>
#import <PEGKit/PKReader.h>

#define STATE_COUNT 256

@interface PKTokenizer ()
- (PKTokenizerState *)defaultTokenizerStateFor:(PKUniChar)c;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (void)appendString:(NSString *)s;
- (NSString *)bufferedString;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;

@property (nonatomic, retain) NSMutableString *stringbuf;
@property (nonatomic) NSUInteger offset;
@property (nonatomic, retain) NSMutableArray *fallbackStates;
@end

@implementation PKTokenizerState

- (void)dealloc {
    self.stringbuf = nil;
    self.fallbackState = nil;
    self.fallbackStates = nil;
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSAssert1(0, @"%s must be overriden", __PRETTY_FUNCTION__);
    return nil;
}


- (void)setFallbackState:(PKTokenizerState *)state from:(PKUniChar)start to:(PKUniChar)end {
    NSParameterAssert(start >= 0 && start < STATE_COUNT);
    NSParameterAssert(end >= 0 && end < STATE_COUNT);
    
    if (!_fallbackStates) {
        self.fallbackStates = [NSMutableArray arrayWithCapacity:STATE_COUNT];

        for (NSInteger i = 0; i < STATE_COUNT; i++) {
            [_fallbackStates addObject:[NSNull null]];
        }
        
    }

    for (NSInteger i = start; i <= end; i++) {
        [_fallbackStates replaceObjectAtIndex:i withObject:state];
    }
}


- (void)resetWithReader:(PKReader *)r {
    self.stringbuf = [NSMutableString string];
    self.offset = r.offset - 1;
}


- (void)append:(PKUniChar)c {
    NSParameterAssert(c != PKEOF);
    NSAssert(_stringbuf, @"");
    [_stringbuf appendFormat:@"%C", (unichar)c];
}


- (void)appendString:(NSString *)s {
    NSParameterAssert(s);
    NSAssert(_stringbuf, @"");
    [_stringbuf appendString:s];
}


- (NSString *)bufferedString {
    return [[_stringbuf copy] autorelease];
}


- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t {
    NSParameterAssert(c < STATE_COUNT);
    
    if (_fallbackStates) {
        id obj = [_fallbackStates objectAtIndex:c];
        if ([NSNull null] != obj) {
            return obj;
        }
    }
    
    if (_fallbackState) {
        return _fallbackState;
    } else {
        return [t defaultTokenizerStateFor:c];
    }
}

@end
