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

#import <PEGKit/PKWhitespaceState.h>
#import <PEGKit/PKReader.h>
#import <PEGKit/PKTokenizer.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKTypes.h>

#define PKTRUE (id)kCFBooleanTrue
#define PKFALSE (id)kCFBooleanFalse

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizer ()
@property (nonatomic, readwrite) NSUInteger lineNumber;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
@property (nonatomic) NSUInteger offset;
@end

@interface PKWhitespaceState ()
@property (nonatomic, retain) NSMutableArray *whitespaceChars;
@end

@implementation PKWhitespaceState

- (id)init {
    self = [super init];
    if (self) {
        const NSUInteger len = 255;
        self.whitespaceChars = [NSMutableArray arrayWithCapacity:len];
        for (NSUInteger i = 0; i <= len; i++) {
            [_whitespaceChars addObject:PKFALSE];
        }
        
        [self setWhitespaceChars:YES from:0 to:' '];
    }
    return self;
}


- (void)dealloc {
    self.whitespaceChars = nil;
    [super dealloc];
}


- (void)setWhitespaceChars:(BOOL)yn from:(PKUniChar)start to:(PKUniChar)end {
    NSUInteger len = [_whitespaceChars count];
    if (start > len || end > len || start < 0 || end < 0) {
        [NSException raise:@"PKWhitespaceStateNotSupportedException" format:@"PKWhitespaceState only supports setting word chars for chars in the latin1 set (under 256)"];
    }

    id obj = yn ? PKTRUE : PKFALSE;
    for (NSUInteger i = start; i <= end; i++) {
        [_whitespaceChars replaceObjectAtIndex:i withObject:obj];
    }
}


- (BOOL)isWhitespaceChar:(PKUniChar)cin {
    if (cin < 0 || cin > [_whitespaceChars count] - 1) {
        return NO;
    }
    return PKTRUE == [_whitespaceChars objectAtIndex:cin];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    if (_reportsWhitespaceTokens) {
        [self resetWithReader:r];
    }
    
    PKUniChar c = cin;
    while ([self isWhitespaceChar:c]) {
        if ('\n' == c) {
            t.lineNumber++;
        }
        if (_reportsWhitespaceTokens) {
            [self append:c];
        }
        c = [r read];
    }
    if (PKEOF != c) {
        [r unread];
    }
    
    if (_reportsWhitespaceTokens) {
        PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeWhitespace stringValue:[self bufferedString] doubleValue:0.0];
        tok.offset = self.offset;
        return tok;
    } else {
        return [t nextToken];
    }
}

@end

