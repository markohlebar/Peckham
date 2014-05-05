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

#import <ParseKit/PKNumberState.h>
#import <ParseKit/PKReader.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKSymbolRootNode.h>
#import <ParseKit/PKSymbolState.h>
#import <ParseKit/PKWhitespaceState.h>
#import <ParseKit/PKTypes.h>

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger offset;
@end

@interface PKTokenizerState ()
- (void)resetWithReader:(PKReader *)r;
- (PKTokenizerState *)nextTokenizerStateFor:(PKUniChar)c tokenizer:(PKTokenizer *)t;

- (PKUniChar)checkForPositiveNegativeFromReader:(PKReader *)r startingWith:(PKUniChar)cin;
- (PKUniChar)checkForPrefixFromReader:(PKReader *)r startingWith:(PKUniChar)cin;
- (PKUniChar)checkForSuffixFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t;
- (void)parseAllDigitsFromReader:(PKReader *)r startingWith:(PKUniChar)cin;
- (PKToken *)checkForErroneousMatchFromReader:(PKReader *)r tokenizer:(PKTokenizer *)t;
- (void)applySuffixFromReader:(PKReader *)r;

- (void)append:(PKUniChar)c;
- (void)appendString:(NSString *)s;
- (NSString *)bufferedString;

- (NSUInteger)radixForPrefix:(NSString *)s;
- (NSUInteger)radixForSuffix:(NSString *)s;
- (BOOL)isValidSeparator:(PKUniChar)sepChar;

@property (nonatomic, retain) PKSymbolRootNode *prefixRootNode;
@property (nonatomic, retain) PKSymbolRootNode *suffixRootNode;
@property (nonatomic, retain) NSMutableDictionary *radixForPrefix;
@property (nonatomic, retain) NSMutableDictionary *radixForSuffix;
@property (nonatomic, retain) NSMutableDictionary *separatorsForRadix;

@property (nonatomic, retain) NSString *prefix;
@property (nonatomic, retain) NSString *suffix;
@end

@interface PKNumberState ()
- (PKFloat)absorbDigitsFromReader:(PKReader *)r;
- (PKFloat)value;
- (void)parseLeftSideFromReader:(PKReader *)r;
- (void)parseRightSideFromReader:(PKReader *)r;
- (void)parseExponentFromReader:(PKReader *)r;

- (void)resetWithReader:(PKReader *)r startingWith:(PKUniChar)cin;
- (void)prepareToParseDigits:(PKUniChar)cin;
@end

@implementation PKNumberState

- (id)init {
    self = [super init];
    if (self) {
        self.prefixRootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        self.suffixRootNode = [[[PKSymbolRootNode alloc] init] autorelease];
        self.radixForPrefix = [NSMutableDictionary dictionary];
        self.radixForSuffix = [NSMutableDictionary dictionary];
        self.separatorsForRadix = [NSMutableDictionary dictionary];
        
//        [self addPrefix:@"0b" forRadix:2];
//        [self addPrefix:@"0"  forRadix:8];
//        [self addPrefix:@"0o" forRadix:8];
//        [self addPrefix:@"0x" forRadix:16];
//
//        [self addPrefix:@"%"  forRadix:2];
//        [self addPrefix:@"$"  forRadix:16];
//
//        [self addSuffix:@"b"  forRadix:2];
//        [self addSuffix:@"h"  forRadix:16];

        self.allowsFloatingPoint = YES;
        self.positivePrefix = '+';
        self.negativePrefix = '-';
        self.decimalSeparator = '.';
    }
    return self;
}


- (void)dealloc {
    self.prefixRootNode = nil;
    self.suffixRootNode = nil;
    self.radixForPrefix = nil;
    self.radixForSuffix = nil;
    self.separatorsForRadix = nil;
    self.prefix = nil;
    self.suffix = nil;
    [super dealloc];
}


- (void)addGroupingSeparator:(PKUniChar)sepChar forRadix:(NSUInteger)r {
    NSParameterAssert(NSNotFound != r);
    NSAssert(separatorsForRadix, @"");
    NSAssert(PKEOF != sepChar, @"");
    if (PKEOF == sepChar) return;

    NSNumber *radixKey = [NSNumber numberWithUnsignedInteger:r];

    NSMutableSet *vals = [separatorsForRadix objectForKey:radixKey];
    if (!vals) {
        vals = [NSMutableSet set];
        [separatorsForRadix setObject:vals forKey:radixKey];
    }

    NSNumber *sepVal = [NSNumber numberWithInteger:sepChar];
    if (sepVal) [vals addObject:sepVal];
}


- (void)removeGroupingSeparator:(PKUniChar)sepChar forRadix:(NSUInteger)r {
    NSParameterAssert(NSNotFound != r);
    NSAssert(separatorsForRadix, @"");
    NSAssert(PKEOF != sepChar, @"");
    if (PKEOF == sepChar) return;

    NSNumber *radixKey = [NSNumber numberWithUnsignedInteger:r];
    NSMutableSet *vals = [separatorsForRadix objectForKey:radixKey];

    NSNumber *sepVal = [NSNumber numberWithInteger:sepChar];
    NSAssert([vals containsObject:sepVal], @"");
    [vals removeObject:sepVal];
}


- (void)addPrefix:(NSString *)s forRadix:(NSUInteger)r {
    NSParameterAssert([s length]);
    NSParameterAssert(NSNotFound != r);
    NSAssert(radixForPrefix, @"");
    
    [prefixRootNode add:s];
    NSNumber *n = [NSNumber numberWithUnsignedInteger:r];
    [radixForPrefix setObject:n forKey:s];
}


- (void)addSuffix:(NSString *)s forRadix:(NSUInteger)r {
    NSParameterAssert([s length]);
    NSParameterAssert(NSNotFound != r);
    NSAssert(radixForSuffix, @"");
    
    [prefixRootNode add:s];
    NSNumber *n = [NSNumber numberWithUnsignedInteger:r];
    [radixForSuffix setObject:n forKey:s];
}


- (void)removePrefix:(NSString *)s {
    NSParameterAssert([s length]);
    NSAssert(radixForPrefix, @"");
    NSAssert([radixForPrefix objectForKey:s], @"");
    [radixForPrefix removeObjectForKey:s];
}


- (void)removeSuffix:(NSString *)s {
    PKAssertMainThread();
    NSParameterAssert([s length]);
    NSAssert(radixForSuffix, @"");
    NSAssert([radixForSuffix objectForKey:s], @"");
    [radixForSuffix removeObjectForKey:s];
}


- (NSUInteger)radixForPrefix:(NSString *)s {
    NSParameterAssert([s length]);
    NSAssert(radixForPrefix, @"");
    
    NSNumber *n = [radixForPrefix objectForKey:s];
    NSUInteger r = [n unsignedIntegerValue];
    return r;
}


- (NSUInteger)radixForSuffix:(NSString *)s {
    NSParameterAssert([s length]);
    NSAssert(radixForSuffix, @"");
    
    NSNumber *n = [radixForSuffix objectForKey:s];
    NSUInteger r = [n unsignedIntegerValue];
    return r;
}


- (BOOL)isValidSeparator:(PKUniChar)sepChar {
    NSAssert(base > 1, @"");
    //NSAssert(PKEOF != sepChar, @"");
    if (PKEOF == sepChar) return NO;
    
    NSNumber *radixKey = [NSNumber numberWithUnsignedInteger:base];
    NSMutableSet *vals = [separatorsForRadix objectForKey:radixKey];

    NSNumber *sepVal = [NSNumber numberWithInteger:sepChar];
    BOOL result = [vals containsObject:sepVal];
    return result;
}


- (PKUniChar)checkForPositiveNegativeFromReader:(PKReader *)r startingWith:(PKUniChar)cin {
    if (negativePrefix == cin) {
        isNegative = YES;
        cin = [r read];
        [self append:negativePrefix];
    } else if (positivePrefix == cin) {
        cin = [r read];
        [self append:positivePrefix];
    }
    return cin;
}


- (PKUniChar)checkForPrefixFromReader:(PKReader *)r startingWith:(PKUniChar)cin {
    if (PKEOF != cin) {
        self.prefix = [prefixRootNode nextSymbol:r startingWith:cin];
        NSUInteger radix = [self radixForPrefix:prefix];
        if (radix > 1 && NSNotFound != radix) {
            [self appendString:prefix];
            base = radix;
        } else {
            base = 10;
            [r unread:[prefix length]];
            self.prefix = nil;
        }
        cin = [r read];
    }
    return cin;
}


- (PKUniChar)checkForSuffixFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    if ([radixForSuffix count] && !prefix) {
        PKUniChar nextChar = cin;
        PKUniChar lastChar = PKEOF;
        NSUInteger len = 0;
        for (;;) {
            if (PKEOF == nextChar || [t.whitespaceState isWhitespaceChar:nextChar]) {
                NSAssert(PKEOF != lastChar && '\0' != lastChar, @"");
                NSString *str = [NSString stringWithCharacters:(const unichar *)&lastChar length:1];
                NSAssert(str, @"");
                NSNumber *n = [radixForSuffix objectForKey:str];
                if (n) {
                    self.suffix = str;
                    base = [n unsignedIntegerValue];
                }
                break;
            }
            ++len;
            [self append:nextChar];
            lastChar = nextChar;
            nextChar = [r read];
        }
        
        [r unread:PKEOF == nextChar ? len - 1 : len];
        [self resetWithReader:r];
    }
    return cin;
}


- (void)parseAllDigitsFromReader:(PKReader *)r startingWith:(PKUniChar)cin {
    [self prepareToParseDigits:cin];
    if (decimalSeparator == c) {
        if (10 == base && allowsFloatingPoint) {
            [self parseRightSideFromReader:r];
        }
    } else {
        [self parseLeftSideFromReader:r];
        if (10 == base && allowsFloatingPoint) {
            [self parseRightSideFromReader:r];
        }
    }
}


- (PKToken *)checkForErroneousMatchFromReader:(PKReader *)r tokenizer:(PKTokenizer *)t {
    PKToken *tok = nil;
    
    if (!gotADigit) {
        if (prefix && '0' == originalCin) {
            [r unread];
            tok = [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:@"0" floatValue:0.0];
        } else {
            if ((originalCin == positivePrefix || originalCin == negativePrefix) && PKEOF != c) { // ??
                [r unread];
            }
            tok = [[self nextTokenizerStateFor:originalCin tokenizer:t] nextTokenFromReader:r startingWith:originalCin tokenizer:t];
        }
    }

    return tok;
}


- (void)applySuffixFromReader:(PKReader *)r {
    NSParameterAssert(r);
    NSUInteger len = [suffix length];
    NSAssert(len && len != NSNotFound, @"");
    for (NSUInteger i = 0; i < len; ++i) {
        [r read];
    }
    [self appendString:suffix];
}


- (PKToken *)nextTokenFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    NSParameterAssert(r);
    NSParameterAssert(t);

    // reset first
    [self resetWithReader:r startingWith:cin];

    // then check for explicit positive, negative (e.g. `+1`, `-2`)
    cin = [self checkForPositiveNegativeFromReader:r startingWith:cin];
        
    // then check for prefix (e.g. `$`, `%`, `0x`)
    cin = [self checkForPrefixFromReader:r startingWith:cin];
    
    // then check for suffix (e.g. `h`, `b`)
    cin = [self checkForSuffixFromReader:r startingWith:cin tokenizer:t];
    
    // then absorb all digits on both sides of decimal point
    [self parseAllDigitsFromReader:r startingWith:cin];
    
    // check for erroneous `.`, `+`, `-`, `0x`, `$`, etc.
    PKToken *tok = [self checkForErroneousMatchFromReader:r tokenizer:t];
    if (!tok) {
        // unread one char
        if (PKEOF != c) [r unread];
        
        // apply negative
        if (isNegative) floatValue = -floatValue;

        // apply suffix
        if (suffix) [self applySuffixFromReader:r];
        
        tok = [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:[self bufferedString] floatValue:[self value]];
        tok.offset = offset;
    }
    
    return tok;
}


- (PKFloat)value {
    PKFloat result = floatValue;
    
    for (NSUInteger i = 0; i < exp; i++) {
        if (isNegativeExp) {
            result /= ((PKFloat)base);
        } else {
            result *= ((PKFloat)base);
        }
    }
    
    return result;
}


- (PKFloat)absorbDigitsFromReader:(PKReader *)r {
    PKFloat divideBy = 1.0;
    PKFloat v = 0.0;
    BOOL isDigit = NO;
    BOOL isHexAlpha = NO;
    
    for (;;) {
        isDigit = isdigit(c);
        isHexAlpha = (16 == base && !isDigit && ishexnumber(c));
        
        if (isDigit || isHexAlpha) {
            [self append:c];
            gotADigit = YES;

            if (isHexAlpha) {
                c = toupper(c);
                c -= 7;
            }
            v = v * base + (c - '0');
            c = [r read];
            if (isFraction) {
                divideBy *= base;
            }
        } else if (gotADigit && [self isValidSeparator:c]) {
            [self append:c];
            c = [r read];
        } else {
            break;
        }
    }
    
    if (isFraction) {
        v = v / divideBy;
    }

    return v;
}


- (void)parseLeftSideFromReader:(PKReader *)r {
    isFraction = NO;
    floatValue = [self absorbDigitsFromReader:r];
}


- (void)parseRightSideFromReader:(PKReader *)r {
    if (decimalSeparator == c) {
        PKUniChar n = [r read];
        BOOL nextIsDigit = isdigit(n);
        if (PKEOF != n) {
            [r unread];
        }

        if (nextIsDigit || allowsTrailingDecimalSeparator) {
            [self append:decimalSeparator];
            if (nextIsDigit) {
                c = [r read];
                isFraction = YES;
                floatValue += [self absorbDigitsFromReader:r];
            }
        }
    }
    
    if (allowsScientificNotation) {
        [self parseExponentFromReader:r];
    }
}


- (void)parseExponentFromReader:(PKReader *)r {
    NSParameterAssert(r);    
    if ('e' == c || 'E' == c) {
        PKUniChar e = c;
        c = [r read];
        
        BOOL hasExp = isdigit(c);
        isNegativeExp = (negativePrefix == c);
        BOOL positiveExp = (positivePrefix == c);
        
        if (!hasExp && (isNegativeExp || positiveExp)) {
            c = [r read];
            hasExp = isdigit(c);
        }
        if (PKEOF != c) {
            [r unread];
        }
        if (hasExp) {
            [self append:e];
            if (isNegativeExp) {
                [self append:negativePrefix];
            } else if (positiveExp) {
                [self append:positivePrefix];
            }
            c = [r read];
            isFraction = NO;
            exp = [self absorbDigitsFromReader:r];
        }
    }
}


- (void)resetWithReader:(PKReader *)r startingWith:(PKUniChar)cin {
    [super resetWithReader:r];
    if (prefix) self.prefix = nil;
    if (suffix) self.suffix = nil;

    base = 10;
    isNegative = NO;
    originalCin = cin;
}


- (void)prepareToParseDigits:(PKUniChar)cin {
    c = cin;
    gotADigit = NO;
    isFraction = NO;
    floatValue = (PKFloat)0.0;
    exp = 0;
    isNegativeExp = NO;
}

@synthesize allowsTrailingDecimalSeparator;
@synthesize allowsScientificNotation;
@synthesize allowsFloatingPoint;
@synthesize positivePrefix;
@synthesize negativePrefix;
@synthesize decimalSeparator;
@synthesize prefixRootNode;
@synthesize suffixRootNode;
@synthesize radixForPrefix;
@synthesize radixForSuffix;
@synthesize separatorsForRadix;
@synthesize prefix;
@synthesize suffix;
@end
