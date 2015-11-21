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

#import <PEGKit/PKQuoteState.h>
#import <PEGKit/PKReader.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKTypes.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (NSString *)bufferedString;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
@property (nonatomic) NSUInteger offset;
@end

@implementation PKQuoteState

- (id)init {
    self = [super init];
    if (self) {
        self.allowsEOFTerminatedQuotes = YES;
    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    [self resetWithReader:r];
    
    [self append:cin];
    PKUniChar c;
    do {
        c = [r read];
        if (PKEOF == c) {
            if (_allowsEOFTerminatedQuotes) {
                c = cin;
                if (_balancesEOFTerminatedQuotes) {
                    [self append:c];
                }
            } else {
                [r unread:[[self bufferedString] length] - 1];
                return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
            }
        } else if ((!_usesCSVStyleEscaping && c == '\\') || (_usesCSVStyleEscaping && c == cin)) {
            PKUniChar peek = [r read];
            if (peek == '\\') { // escaped backslash found
                // discard `c`
                [self append:c];
                [self append:peek];
                c = PKEOF;	// Just to get past the while() condition
            } else if (peek == cin) {
                [self append:c];
                [self append:peek];
                c = PKEOF;	// Just to get past the while() condition
            } else {
                if (peek != PKEOF) {
                    [r unread:1];
                }
                [self append:c];
            }
        } else {
            [self append:c];
        }
    } while (c != cin);
    
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeQuotedString stringValue:[self bufferedString] doubleValue:0.0];
    tok.offset = self.offset;
    return tok;
}

@end
