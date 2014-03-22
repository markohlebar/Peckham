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

#import <ParseKit/PKDelimitState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKWhitespaceState.h>
#import <ParseKit/PKSymbolRootNode.h>
#import <ParseKit/PKTypes.h>

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
@end

@interface PKDelimitState ()
@property (nonatomic, retain) PKSymbolRootNode *rootNode;
@property (nonatomic, retain) PKDelimitDescriptorCollection *collection;
@end

@implementation PKDelimitState

- (id)init {
    self = [super init];
    if (self) {
        self.rootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        self.collection = [[[PKDelimitDescriptorCollection alloc] init] autorelease];
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
    [rootNode add:start];
    if ([end length]) {
        [rootNode add:end];
    }
    
    // add descriptor to collection
    PKDelimitDescriptor *desc = [PKDelimitDescriptor descriptorWithStartMarker:start endMarker:end characterSet:set];
    NSAssert(collection, @"");
    [collection add:desc];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);
    
    NSString *startMarker = [rootNode nextSymbol:r startingWith:cin];
    NSArray *descs = nil;
    
    if ([startMarker length]) {
        descs = [collection descriptorsForStartMarker:startMarker];
        
        if (![descs count]) {
            [r unread:[startMarker length] - 1];
            return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
        }
    }
    
    [self resetWithReader:r];
    [self appendString:startMarker];
    
    NSUInteger count = [descs count];
    BOOL hasEndMarkers = NO;
    PKUniChar endChars[count];
    PKDelimitDescriptor *selectedDesc = nil;

    NSUInteger i = 0;
    for (PKDelimitDescriptor *desc in descs) {
        NSString *endMarker = desc.endMarker;
        PKUniChar e = PKEOF;
        
        if ([endMarker length]) {
            e = [endMarker characterAtIndex:0];
            hasEndMarkers = YES;
        }
        endChars[i++] = e;
    }
    
    PKUniChar c;
    for (;;) {
        c = [r read];
        //NSLog(@"%C", (UniChar)c);
        if (PKEOF == c) {
            if (hasEndMarkers && balancesEOFTerminatedStrings) {
                [self appendString:[descs[0] endMarker]];
            } else if (hasEndMarkers) {
                [r unread:[[self bufferedString] length] - 1];
                return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
            }
            break;
        }
        
        if (!hasEndMarkers && [t.whitespaceState isWhitespaceChar:c]) {
            // if only the start marker was matched, dont return delimited string token. instead, defer tokenization
            if ([startMarker isEqualToString:[self bufferedString]]) {
                [r unread:[startMarker length] - 1];
                return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
            }
            // else, return delimited string tok
            break;
        }

        BOOL done = NO;
        NSString *endMarker = nil;
        NSCharacterSet *charSet = nil;
        
        for (NSUInteger i = 0; i < count; ++i) {
            PKUniChar e = endChars[i];
            
            if (e == c) {
                selectedDesc = descs[i];
                endMarker = [selectedDesc endMarker];
                charSet = [selectedDesc characterSet];
                
                NSString *peek = [rootNode nextSymbol:r startingWith:e];
                if (endMarker && [endMarker isEqualToString:peek]) {
                    [self appendString:endMarker];
                    c = [r read];
                    done = YES;
                    break;
                } else {
                    [r unread:[peek length] - 1];
                    if (e != [peek characterAtIndex:0]) {
                        [self append:c];
                        c = [r read];
                    }
                }
            }
        }

        if (done) {
            if (charSet) {
                NSString *contents = [self bufferedString];
                NSUInteger loc = [startMarker length];
                NSUInteger len = [contents length] - (loc + [endMarker length]);
                contents = [contents substringWithRange:NSMakeRange(loc, len)];
                
                for (NSUInteger i = 0; i < len; ++i) {
                    PKUniChar c = [contents characterAtIndex:i];

                    // check if char is not in allowed character set (if given)
                    if (![charSet characterIsMember:c]) {
                        // if not, unwind and return a symbol tok for cin
                        [r unread:[[self bufferedString] length] - 1];
                        return [[self nextTokenizerStateFor:cin tokenizer:t] nextTokenFromReader:r startingWith:cin tokenizer:t];
                    }
                }
            }

            break;
        }
        
        
        [self append:c];
    }
    
    if (PKEOF != c) {
        [r unread];
    }
    
    PKToken *tok = [PKToken tokenWithTokenType:PKTokenTypeDelimitedString stringValue:[self bufferedString] floatValue:0.0];
    tok.offset = offset;
    
    NSString *tokenKindKey = [NSString stringWithFormat:@"%@,%@", selectedDesc.startMarker, selectedDesc.endMarker];
    NSInteger tokenKind = [t tokenKindForStringValue:tokenKindKey];
    tok.tokenKind = tokenKind; //selectedDesc.tokenKind;

    return tok;
}

@synthesize rootNode;
@synthesize balancesEOFTerminatedStrings;
@synthesize collection;
@end
