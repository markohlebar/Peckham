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

#import <PEGKit/PKSymbolState.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKReader.h>
#import <PEGKit/PKTokenizer.h>
#import "PKSymbolRootNode.h"

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@property (nonatomic) NSUInteger offset;
@end

@interface PKSymbolState ()
- (PKToken *)symbolTokenWith:(PKUniChar)cin;
- (PKToken *)symbolTokenWithSymbol:(NSString *)s;

@property (nonatomic, retain) PKSymbolRootNode *rootNode;
@property (nonatomic, retain) NSMutableSet *addedSymbols;
@end

@implementation PKSymbolState {
    BOOL *_prevented;
}

- (id)init {
    self = [super init];
    if (self) {
        self.rootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        self.addedSymbols = [NSMutableSet set];
        _prevented = (void *)calloc(128, sizeof(BOOL));
    }
    return self;
}


- (void)dealloc {
    self.rootNode = nil;
    self.addedSymbols = nil;
    if (_prevented) {
        free(_prevented);
    }
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    NSString *symbol = [_rootNode nextSymbol:r startingWith:cin];
    NSUInteger len = [symbol length];

    while (len > 1) {
        if ([_addedSymbols containsObject:symbol]) {
            return [self symbolTokenWithSymbol:symbol];
        }

        symbol = [symbol substringToIndex:[symbol length] - 1];
        len = [symbol length];
        [r unread:1];
    }
    
    if (1 == len) {
        BOOL isPrevented = NO;
        if (_prevented[cin]) {
            PKUniChar peek = [r read];
            if (peek != EOF) {
                isPrevented = YES;
                [r unread:1];
            }
        }
        
        if (!isPrevented) {
            return [self symbolTokenWith:cin];
        }
    }

    PKTokenizerState *state = [self nextTokenizerStateFor:cin tokenizer:t];
    if (!state || state == self) {
        return [self symbolTokenWith:cin];
    } else {
        return [state nextTokenFromReader:r startingWith:cin tokenizer:t];
    }
}


- (void)add:(NSString *)s {
    NSParameterAssert(s);
    [_rootNode add:s];
    [_addedSymbols addObject:s];
}


- (void)remove:(NSString *)s {
    NSParameterAssert(s);
    [_rootNode remove:s];
    [_addedSymbols removeObject:s];
}


- (void)prevent:(PKUniChar)c {
    PKAssertMainThread();
    NSParameterAssert(c > 0);
    _prevented[c] = YES;
}


- (PKToken *)symbolTokenWith:(PKUniChar)cin {
    return [self symbolTokenWithSymbol:[NSString stringWithFormat:@"%C", (unichar)cin]];
}


- (PKToken *)symbolTokenWithSymbol:(NSString *)s {
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:s doubleValue:0.0];
    tok.offset = self.offset;
    return tok;
}

@end
