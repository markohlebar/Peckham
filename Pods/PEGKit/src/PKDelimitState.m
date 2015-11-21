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

#import <PEGKit/PKDelimitState.h>
#import <PEGKit/PKReader.h>
#import <PEGKit/PKTokenizer.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKWhitespaceState.h>
#import <PEGKit/PKTypes.h>
#import "PKSymbolRootNode.h"

#import "PKDelimitDescriptorCollection.h"
#import "PKDelimitDescriptor.h"

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizer ()
- (NSInteger)tokenKindForStringValue:(NSString *)str;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (void)append:(PKUniChar)c;
- (void)appendString:(NSString *)s;
- (NSString *)bufferedString;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;
- (void)addStartMarker:(NSString *)start endMarker:(NSString *)end allowedCharacterSet:(NSCharacterSet *)set tokenKind:(NSInteger)kind;
@property (nonatomic) NSUInteger offset;
@end

@interface PKDelimitState ()
@property (nonatomic, retain) PKSymbolRootNode *rootNode;
@property (nonatomic, retain) PKDelimitDescriptorCollection *collection;

@end

@implementation PKDelimitState {
    NSInteger _nestedCount;
}

- (id)init {
    self = [super init];
    if (self) {
        self.rootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        _rootNode.reportsAddedSymbolsOnly = YES;
        self.collection = [[[PKDelimitDescriptorCollection alloc] init] autorelease];
        self.allowsNestedMarkers = YES;
    }
    return self;
}


- (void)dealloc {
    self.rootNode = nil;
    self.collection = nil;
    [super dealloc];
}


- (void)addStartMarker:(NSString *)start endMarker:(NSString *)end allowedCharacterSet:(NSCharacterSet *)set {
    NSParameterAssert([start length]);

    // add markers to root node
    [_rootNode add:start];
    if ([end length]) {
        [_rootNode add:end];
    }
    
    // add descriptor to collection
    PKDelimitDescriptor *desc = [PKDelimitDescriptor descriptorWithStartMarker:start endMarker:end characterSet:set];
    NSAssert(_collection, @"");
    [_collection add:desc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    NSString *startMarker = [_rootNode nextSymbol:r startingWith:cin];
    NSMutableArray *matchingDescs = nil;
    
    // check for false match
    if ([startMarker length]) {
        matchingDescs = [[[_collection descriptorsForStartMarker:startMarker] mutableCopy] autorelease];
        
        if (![matchingDescs count]) {
            [r unread:[startMarker length] - 1];
            return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
        }
    }
    
    // reset
    [self resetWithReader:r];
    self.offset = r.offset - [startMarker length];
    [self appendString:startMarker];
    
    NSUInteger stackCount = 0;
    
    // setup a temp root node with current start and end markers
    PKSymbolRootNode *currRootNode = [[[PKSymbolRootNode alloc] init] autorelease];
    currRootNode.reportsAddedSymbolsOnly = YES;
    
    for (PKDelimitDescriptor *desc in matchingDescs) {
        [currRootNode add:desc.startMarker];
        if (desc.endMarker) {
            [currRootNode add:desc.endMarker];
        }
    }

    PKUniChar c;
    PKDelimitDescriptor *matchedDesc = nil;
    
    for (;;) {
        c = [r read];
        if ('\\' == c) {
            c = [r read];
            [self append:c];
            continue;
        }
        
        if (PKEOF == c) {
            if (!_balancesEOFTerminatedStrings) {
                for (PKDelimitDescriptor *desc in [[matchingDescs copy] autorelease]) {
                    if (desc.endMarker) {
                        [matchingDescs removeObject:desc];
                    }
                }
            }
            break;
        }

        NSString *marker = [currRootNode nextSymbol:r startingWith:c];
        if ([marker length]) {
            for (PKDelimitDescriptor *desc in matchingDescs) {
                if (_allowsNestedMarkers && [marker isEqualToString:desc.startMarker] && ![desc.startMarker isEqualToString:desc.endMarker]) {
                    ++stackCount;
                    break;
                } else if ([marker isEqualToString:desc.endMarker]) {
                    if (_allowsNestedMarkers && stackCount > 0 && ![desc.startMarker isEqualToString:desc.endMarker]) {
                        --stackCount;
                        break;
                    } else {
                        matchedDesc = desc;
                        [self appendString:desc.endMarker];
                        break;
                    }
                }
            }
            if (matchedDesc) {
                break;
            }
        }
        
        for (PKDelimitDescriptor *desc in [[matchingDescs copy] autorelease]) {
            if (desc.characterSet && ![desc.characterSet characterIsMember:c]) {
                [matchingDescs removeObject:desc];
            }
        }
        
        // no remaining matches. bail
        if (![matchingDescs count]) {
            break;
        }
        
        [self append:c];
    }
    
    if (!matchedDesc && [matchingDescs count]) {
        matchedDesc = matchingDescs[0];

        if (PKEOF == c && _balancesEOFTerminatedStrings && matchedDesc.endMarker) {
            [self appendString:matchedDesc.endMarker];
        }
    }
    
    PKToken *tok = nil;
    
    if (matchedDesc) {
        tok = [PKToken tokenWithTokenType:PKTokenTypeDelimitedString stringValue:[self bufferedString] doubleValue:0.0];
        tok.offset = self.offset;
        
        NSString *tokenKindKey = [NSString stringWithFormat:@"%@,%@", matchedDesc.startMarker, matchedDesc.endMarker];
        NSInteger tokenKind = [t tokenKindForStringValue:tokenKindKey];
        tok.tokenKind = tokenKind; //selectedDesc.tokenKind;
    } else {
        if (PKEOF != c) {
            [r unread];
        }
        
        NSUInteger buffLen = [[self bufferedString] length];
        [r unread:buffLen - 1];
        
        tok = [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
    }

    return tok;
}

@end
