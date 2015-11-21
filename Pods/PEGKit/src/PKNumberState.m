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

#import <PEGKit/PKNumberState.h>
#import <PEGKit/PKReader.h>
#import <PEGKit/PKToken.h>
#import <PEGKit/PKTokenizer.h>
#import <PEGKit/PKSymbolState.h>
#import <PEGKit/PKWhitespaceState.h>
#import <PEGKit/PKTypes.h>
#import "PKSymbolRootNode.h"

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
@end

@interface PKNumberState ()
- (double)absorbDigitsFromReader:(PKReader *)r;
- (double)value;
- (void)parseLeftSideFromReader:(PKReader *)r;
- (void)parseRightSideFromReader:(PKReader *)r;
- (void)parseExponentFromReader:(PKReader *)r;

- (void)resetWithReader:(PKReader *)r startingWith:(PKUniChar)cin;
- (void)prepareToParseDigits:(PKUniChar)cin;

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
@property (nonatomic) NSUInteger offset;
@end

@implementation PKNumberState {
    BOOL _allowsTrailingDecimalSeparator;
    BOOL _allowsScientificNotation;
    BOOL _allowsOctalNotation;
    BOOL _allowsFloatingPoint;
    
    PKUniChar _positivePrefix;
    PKUniChar _negativePrefix;
    PKUniChar _decimalSeparator;
    
    BOOL _isFraction;
    BOOL _isNegative;
    BOOL _gotADigit;
    NSUInteger _base;
    PKUniChar _originalCin;
    PKUniChar _c;
    double _doubleValue;
    
    NSUInteger _exp;
    BOOL _isNegativeExp;
}


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
    NSAssert(_separatorsForRadix, @"");
    NSAssert(PKEOF != sepChar, @"");
    if (PKEOF == sepChar) return;

    NSNumber *radixKey = [NSNumber numberWithUnsignedInteger:r];

    NSMutableSet *vals = [_separatorsForRadix objectForKey:radixKey];
    if (!vals) {
        vals = [NSMutableSet set];
        [_separatorsForRadix setObject:vals forKey:radixKey];
    }

    NSNumber *sepVal = [NSNumber numberWithInteger:sepChar];
    if (sepVal) [vals addObject:sepVal];
}


- (void)removeGroupingSeparator:(PKUniChar)sepChar forRadix:(NSUInteger)r {
    NSParameterAssert(NSNotFound != r);
    NSAssert(_separatorsForRadix, @"");
    NSAssert(PKEOF != sepChar, @"");
    if (PKEOF == sepChar) return;

    NSNumber *radixKey = [NSNumber numberWithUnsignedInteger:r];
    NSMutableSet *vals = [_separatorsForRadix objectForKey:radixKey];

    NSNumber *sepVal = [NSNumber numberWithInteger:sepChar];
    NSAssert([vals containsObject:sepVal], @"");
    [vals removeObject:sepVal];
}


- (void)addPrefix:(NSString *)s forRadix:(NSUInteger)r {
    NSParameterAssert([s length]);
    NSParameterAssert(NSNotFound != r);
    NSAssert(_radixForPrefix, @"");
    
    [_prefixRootNode add:s];
    NSNumber *n = [NSNumber numberWithUnsignedInteger:r];
    [_radixForPrefix setObject:n forKey:s];
}


- (void)addSuffix:(NSString *)s forRadix:(NSUInteger)r {
    NSParameterAssert([s length]);
    NSParameterAssert(NSNotFound != r);
    NSAssert(_radixForSuffix, @"");
    
    [_prefixRootNode add:s];
    NSNumber *n = [NSNumber numberWithUnsignedInteger:r];
    [_radixForSuffix setObject:n forKey:s];
}


- (void)removePrefix:(NSString *)s {
    NSParameterAssert([s length]);
    NSAssert(_radixForPrefix, @"");
    NSAssert([_radixForPrefix objectForKey:s], @"");
    [_radixForPrefix removeObjectForKey:s];
}


- (void)removeSuffix:(NSString *)s {
    PKAssertMainThread();
    NSParameterAssert([s length]);
    NSAssert(_radixForSuffix, @"");
    NSAssert([_radixForSuffix objectForKey:s], @"");
    [_radixForSuffix removeObjectForKey:s];
}


- (NSUInteger)radixForPrefix:(NSString *)s {
    NSParameterAssert([s length]);
    NSAssert(_radixForPrefix, @"");
    
    NSNumber *n = [_radixForPrefix objectForKey:s];
    NSUInteger r = [n unsignedIntegerValue];
    return r;
}


- (NSUInteger)radixForSuffix:(NSString *)s {
    NSParameterAssert([s length]);
    NSAssert(_radixForSuffix, @"");
    
    NSNumber *n = [_radixForSuffix objectForKey:s];
    NSUInteger r = [n unsignedIntegerValue];
    return r;
}


- (BOOL)isValidSeparator:(PKUniChar)sepChar {
    NSAssert(_base > 1, @"");
    //NSAssert(PKEOF != sepChar, @"");
    if (PKEOF == sepChar) return NO;
    
    NSNumber *radixKey = [NSNumber numberWithUnsignedInteger:_base];
    NSMutableSet *vals = [_separatorsForRadix objectForKey:radixKey];

    NSNumber *sepVal = [NSNumber numberWithInteger:sepChar];
    BOOL result = [vals containsObject:sepVal];
    return result;
}


- (PKUniChar)checkForPositiveNegativeFromReader:(PKReader *)r startingWith:(PKUniChar)cin {
    if (_negativePrefix == cin) {
        _isNegative = YES;
        cin = [r read];
        [self append:_negativePrefix];
    } else if (_positivePrefix == cin) {
        cin = [r read];
        [self append:_positivePrefix];
    }
    return cin;
}


- (PKUniChar)checkForPrefixFromReader:(PKReader *)r startingWith:(PKUniChar)cin {
    if (PKEOF != cin) {
        self.prefix = [_prefixRootNode nextSymbol:r startingWith:cin];
        NSUInteger radix = [self radixForPrefix:_prefix];
        if (radix > 1 && NSNotFound != radix) {
            [self appendString:_prefix];
            _base = radix;
        } else {
            _base = 10;
            [r unread:[_prefix length]];
            self.prefix = nil;
        }
        cin = [r read];
    }
    return cin;
}


- (PKUniChar)checkForSuffixFromReader:(PKReader *)r startingWith:(PKUniChar)cin tokenizer:(PKTokenizer *)t {
    if ([_radixForSuffix count] && !_prefix) {
        PKUniChar nextChar = cin;
        PKUniChar lastChar = PKEOF;
        NSUInteger len = 0;
        for (;;) {
            if (PKEOF == nextChar || [t.whitespaceState isWhitespaceChar:nextChar]) {
                NSAssert(PKEOF != lastChar && '\0' != lastChar, @"");
                NSString *str = [NSString stringWithCharacters:(const unichar *)&lastChar length:1];
                NSAssert(str, @"");
                NSNumber *n = [_radixForSuffix objectForKey:str];
                if (n) {
                    self.suffix = str;
                    _base = [n unsignedIntegerValue];
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
    if (_decimalSeparator == _c) {
        if (10 == _base && _allowsFloatingPoint) {
            [self parseRightSideFromReader:r];
        }
    } else {
        [self parseLeftSideFromReader:r];
        if (10 == _base && _allowsFloatingPoint) {
            [self parseRightSideFromReader:r];
        }
    }
}


- (PKToken *)checkForErroneousMatchFromReader:(PKReader *)r tokenizer:(PKTokenizer *)t {
    PKToken *tok = nil;
    
    if (!_gotADigit) {
        if (_prefix && '0' == _originalCin) {
            [r unread];
            tok = [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:@"0" doubleValue:0.0];
        } else {
            if ((_originalCin == _positivePrefix || _originalCin == _negativePrefix) && PKEOF != _c) { // ??
                [r unread];
            }
            tok = [[self nextTokenizerStateFor:_originalCin tokenizer:t] nextTokenFromReader:r startingWith:_originalCin tokenizer:t];
        }
    }

    return tok;
}


- (void)applySuffixFromReader:(PKReader *)r {
    NSParameterAssert(r);
    NSUInteger len = [_suffix length];
    NSAssert(len && len != NSNotFound, @"");
    for (NSUInteger i = 0; i < len; ++i) {
        [r read];
    }
    [self appendString:_suffix];
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
        if (PKEOF != _c) [r unread];
        
        // apply negative
        if (_isNegative) _doubleValue = -_doubleValue;

        // apply suffix
        if (_suffix) [self applySuffixFromReader:r];
        
        tok = [PKToken tokenWithTokenType:PKTokenTypeNumber stringValue:[self bufferedString] doubleValue:[self value]];
    }
    tok.offset = self.offset;
    
    return tok;
}


- (double)value {
    double result = _doubleValue;
    
    for (NSUInteger i = 0; i < _exp; i++) {
        if (_isNegativeExp) {
            result /= _base;
        } else {
            result *= _base;
        }
    }
    
    return result;
}


- (double)absorbDigitsFromReader:(PKReader *)r {
    double divideBy = 1.0;
    double v = 0.0;
    BOOL isDigit = NO;
    BOOL isHexAlpha = NO;
    
    for (;;) {
        isDigit = isdigit(_c);
        isHexAlpha = (16 == _base && !isDigit && ishexnumber(_c));
        
        if (isDigit || isHexAlpha) {
            [self append:_c];
            _gotADigit = YES;

            if (isHexAlpha) {
                _c = toupper(_c);
                _c -= 7;
            }
            v = v * _base + (_c - '0');
            _c = [r read];
            if (_isFraction) {
                divideBy *= _base;
            }
        } else if (_gotADigit && [self isValidSeparator:_c]) {
            [self append:_c];
            _c = [r read];
        } else {
            break;
        }
    }
    
    if (_isFraction) {
        v = v / divideBy;
    }

    return v;
}


- (void)parseLeftSideFromReader:(PKReader *)r {
    _isFraction = NO;
    _doubleValue = [self absorbDigitsFromReader:r];
}


- (void)parseRightSideFromReader:(PKReader *)r {
    if (_decimalSeparator == _c) {
        PKUniChar n = [r read];
        BOOL nextIsDigit = isdigit(n);
        if (PKEOF != n) {
            [r unread];
        }

        if (nextIsDigit || _allowsTrailingDecimalSeparator) {
            [self append:_decimalSeparator];
            if (nextIsDigit) {
                _c = [r read];
                _isFraction = YES;
                _doubleValue += [self absorbDigitsFromReader:r];
            }
        }
    }
    
    if (_allowsScientificNotation) {
        [self parseExponentFromReader:r];
    }
}


- (void)parseExponentFromReader:(PKReader *)r {
    NSParameterAssert(r);    
    if ('e' == _c || 'E' == _c) {
        PKUniChar e = _c;
        _c = [r read];
        
        BOOL hasExp = isdigit(_c);
        _isNegativeExp = (_negativePrefix == _c);
        BOOL positiveExp = (_positivePrefix == _c);
        
        if (!hasExp && (_isNegativeExp || positiveExp)) {
            _c = [r read];
            hasExp = isdigit(_c);
        }
        if (PKEOF != _c) {
            [r unread];
        }
        if (hasExp) {
            [self append:e];
            if (_isNegativeExp) {
                [self append:_negativePrefix];
            } else if (positiveExp) {
                [self append:_positivePrefix];
            }
            _c = [r read];
            _isFraction = NO;
            _exp = [self absorbDigitsFromReader:r];
        }
    }
}


- (void)resetWithReader:(PKReader *)r startingWith:(PKUniChar)cin {
    [super resetWithReader:r];
    self.prefix = nil;
    self.suffix = nil;

    _base = 10;
    _isNegative = NO;
    _originalCin = cin;
}


- (void)prepareToParseDigits:(PKUniChar)cin {
    _c = cin;
    _gotADigit = NO;
    _isFraction = NO;
    _doubleValue = 0.0;
    _exp = 0;
    _isNegativeExp = NO;
}

@end
