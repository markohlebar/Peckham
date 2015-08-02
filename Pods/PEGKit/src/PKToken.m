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

#import <PEGKit/PKToken.h>
#import <PEGKit/PKTypes.h>
#import "NSString+PEGKitAdditions.h"

@interface PKTokenEOF : PKToken {}
+ (PKTokenEOF *)instance;
@end

@implementation PKTokenEOF

static PKTokenEOF *EOFToken = nil;

+ (PKTokenEOF *)instance {
    @synchronized(self) {
        if (!EOFToken) { 
            EOFToken = [[self alloc] initWithTokenType:PKTokenTypeEOF stringValue:@"«EOF»" doubleValue:0.0];
        }
    }
    return EOFToken;
}


- (BOOL)isEOF {
    return YES;
}


- (NSString *)description {
    return [self stringValue];
}


- (NSString *)debugDescription {
    return [self description];
}

@end

@interface PKToken ()
- (BOOL)isEqual:(id)obj ignoringCase:(BOOL)ignoringCase;

@property (nonatomic, readwrite) BOOL isNumber;
@property (nonatomic, readwrite) BOOL isQuotedString;
@property (nonatomic, readwrite) BOOL isSymbol;
@property (nonatomic, readwrite) BOOL isWord;
@property (nonatomic, readwrite) BOOL isWhitespace;
@property (nonatomic, readwrite) BOOL isComment;
@property (nonatomic, readwrite) BOOL isDelimitedString;
@property (nonatomic, readwrite) BOOL isURL;
@property (nonatomic, readwrite) BOOL isEmail;
#if PK_PLATFORM_TWITTER_STATE
@property (nonatomic, readwrite) BOOL isTwitter;
@property (nonatomic, readwrite) BOOL isHashtag;
#endif

@property (nonatomic, readwrite) double doubleValue;
@property (nonatomic, readwrite, copy) NSString *stringValue;
@property (nonatomic, readwrite) PKTokenType tokenType;
@property (nonatomic, readwrite, copy) id value;

@property (nonatomic, readwrite) NSUInteger offset;
@property (nonatomic, readwrite) NSUInteger lineNumber;
@end

@implementation PKToken

+ (PKToken *)EOFToken {
    return [PKTokenEOF instance];
}


+ (instancetype)tokenWithTokenType:(PKTokenType)t stringValue:(NSString *)s doubleValue:(double)n {
    return [[[self alloc] initWithTokenType:t stringValue:s doubleValue:n] autorelease];
}


// designated initializer
- (instancetype)initWithTokenType:(PKTokenType)t stringValue:(NSString *)s doubleValue:(double)n {
    //NSParameterAssert(s);
    self = [super init];
    if (self) {
        self.tokenType = t;
        self.stringValue = s;
        self.doubleValue = n;
        self.offset = NSNotFound;
        self.lineNumber = NSNotFound;
        
        self.isNumber = (PKTokenTypeNumber == t);
        self.isQuotedString = (PKTokenTypeQuotedString == t);
        self.isSymbol = (PKTokenTypeSymbol == t);
        self.isWord = (PKTokenTypeWord == t);
        self.isWhitespace = (PKTokenTypeWhitespace == t);
        self.isComment = (PKTokenTypeComment == t);
        self.isDelimitedString = (PKTokenTypeDelimitedString == t);
        self.isURL = (PKTokenTypeURL == t);
        self.isEmail = (PKTokenTypeEmail == t);
#if PK_PLATFORM_TWITTER_STATE
        self.isTwitter = (PKTokenTypeTwitter == t);
        self.isHashtag = (PKTokenTypeHashtag == t);
#endif
    }
    return self;
}


- (void)dealloc {
    self.stringValue = nil;
    self.value = nil;
    [super dealloc];
}


- (id)copyWithZone:(NSZone *)zone {
    return [self retain]; // tokens are immutable
}


- (NSUInteger)hash {
    return [_stringValue hash];
}


- (BOOL)isEqual:(id)obj {
    return [self isEqual:obj ignoringCase:NO];
}


- (BOOL)isEqualIgnoringCase:(id)obj {
    return [self isEqual:obj ignoringCase:YES];
}


- (BOOL)isEqual:(id)obj ignoringCase:(BOOL)ignoringCase {
    if (![obj isMemberOfClass:[PKToken class]]) {
        return NO;
    }
    
    PKToken *tok = (PKToken *)obj;
    if (_tokenType != tok->_tokenType) {
        return NO;
    }
    
    if (_isNumber) {
        return _doubleValue == tok->_doubleValue;
    } else {
        if (ignoringCase) {
            return (NSOrderedSame == [_stringValue caseInsensitiveCompare:tok->_stringValue]);
        } else {
            return [_stringValue isEqualToString:tok->_stringValue];
        }
    }
}


- (BOOL)isEOF {
    return NO;
}


- (id)value {
    if (!_value) {
        id v = nil;
        if (_isNumber) {
            v = [NSNumber numberWithDouble:_doubleValue];
        } else {
            v = _stringValue;
        }
        self.value = v;
    }
    return _value;
}


- (NSString *)quotedStringValue {
    return [_stringValue stringByTrimmingQuotes];
}


- (NSString *)debugDescription {
    NSString *typeString = nil;
    if (_isNumber) {
        typeString = @"Number";
    } else if (_isQuotedString) {
        typeString = @"Quoted String";
    } else if (_isSymbol) {
        typeString = @"Symbol";
    } else if (_isWord) {
        typeString = @"Word";
    } else if (_isWhitespace) {
        typeString = @"Whitespace";
    } else if (_isComment) {
        typeString = @"Comment";
    } else if (_isDelimitedString) {
        typeString = @"Delimited String";
    } else if (_isURL) {
        typeString = @"URL";
    } else if (_isEmail) {
        typeString = @"Email";
#if PK_PLATFORM_TWITTER_STATE
    } else if (_isTwitter) {
        typeString = @"Twitter";
    } else if (_isHashtag) {
        typeString = @"Hashtag";
#endif
    }
    return [NSString stringWithFormat:@"<%@ %C%@%C>", typeString, (unichar)0x00AB, self.value, (unichar)0x00BB];
}


- (NSString *)description {
    return _stringValue;
}

@end
