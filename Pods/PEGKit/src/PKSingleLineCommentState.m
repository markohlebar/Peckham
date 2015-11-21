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

#import <PEGKit/PKSingleLineCommentState.h>
#import <PEGKit/PKCommentState.h>
#import <PEGKit/PKReader.h>
#import <PEGKit/PKTokenizer.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKTypes.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (void)appendString:(NSString *)s;
- (NSString *)bufferedString;
@property (nonatomic) NSUInteger offset;
@end

@interface PKSingleLineCommentState ()
- (void)addStartMarker:(NSString *)start;
- (void)removeStartMarker:(NSString *)start;
@property (nonatomic, retain) NSMutableArray *startMarkers;
@property (nonatomic, retain) NSString *currentStartMarker;
@end

@implementation PKSingleLineCommentState

- (id)init {
    self = [super init];
    if (self) {
        self.startMarkers = [NSMutableArray array];
    }
    return self;
}


- (void)dealloc {
    self.startMarkers = nil;
    self.currentStartMarker = nil;
    [super dealloc];
}


- (void)addStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    [_startMarkers addObject:start];
}


- (void)removeStartMarker:(NSString *)start {
    NSParameterAssert([start length]);
    [_startMarkers removeObject:start];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    BOOL reportTokens = t.commentState.reportsCommentTokens;
    if (reportTokens) {
        [self resetWithReader:r];
        [self appendString:_currentStartMarker];
    }
    
    PKUniChar c;
    for (;;) {
        c = [r read];
        if ('\n' == c || '\r' == c || PKEOF == c) {
            break;
        }
        if (reportTokens) {
            [self append:c];
        }
    }
    
    if (PKEOF != c) {
        [r unread];
    }
    
    self.currentStartMarker = nil;
    
    if (reportTokens) {
        PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeComment stringValue:[self bufferedString] doubleValue:0.0];
        tok.offset = self.offset;
        return tok;
    } else {
        return [t nextToken];
    }
}

@end
