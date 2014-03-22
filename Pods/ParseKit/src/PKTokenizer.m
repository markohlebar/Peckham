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

#import <ParseKit/PKTokenizer.h>
#import <ParseKit/ParseKit.h>

#define STATE_COUNT 256

@interface PKToken ()
@property (nonatomic, readwrite) NSUInteger lineNumber;
@end

@interface PKTokenizer ()
- (id)initWithString:(NSString *)str stream:(NSInputStream *)stm;
- (PKTokenizerState *)tokenizerStateFor:(PKUniChar)c;
- (PKTokenizerState *)defaultTokenizerStateFor:(PKUniChar)c;
- (NSInteger)tokenKindForStringValue:(NSString *)str;
@property (nonatomic, retain) PKReader *reader;
@property (nonatomic, retain) NSMutableArray *tokenizerStates;
@property (nonatomic, readwrite) NSUInteger lineNumber;
@end

@implementation PKTokenizer

+ (PKTokenizer *)tokenizer {
    return [self tokenizerWithString:nil];
}


+ (PKTokenizer *)tokenizerWithString:(NSString *)s {
    return [[[self alloc] initWithString:s] autorelease];
}


+ (PKTokenizer *)tokenizerWithStream:(NSInputStream *)s {
    return [[[self alloc] initWithStream:s] autorelease];
}


- (id)init {
    return [self initWithString:nil stream:nil];
}


- (id)initWithString:(NSString *)s {
    self = [self initWithString:s stream:nil];
    return self;
}


- (id)initWithStream:(NSInputStream *)s {
    self = [self initWithString:nil stream:s];
    return self;
}


- (id)initWithString:(NSString *)str stream:(NSInputStream *)stm {
    self = [super init];
    if (self) {
        self.string = str;
        self.stream = stm;
        self.reader = [[[PKReader alloc] init] autorelease];
        
        self.numberState     = [[[PKNumberState alloc] init] autorelease];
        self.quoteState      = [[[PKQuoteState alloc] init] autorelease];
        self.commentState    = [[[PKCommentState alloc] init] autorelease];
        self.symbolState     = [[[PKSymbolState alloc] init] autorelease];
        self.whitespaceState = [[[PKWhitespaceState alloc] init] autorelease];
        self.wordState       = [[[PKWordState alloc] init] autorelease];
        self.delimitState    = [[[PKDelimitState alloc] init] autorelease];
        self.URLState        = [[[PKURLState alloc] init] autorelease];
#if PK_PLATFORM_EMAIL_STATE
        self.emailState      = [[[PKEmailState alloc] init] autorelease];
#endif
        numberState.fallbackState = symbolState;
        quoteState.fallbackState = symbolState;
#if PK_PLATFORM_EMAIL_STATE
        URLState.fallbackState = emailState;
        emailState.fallbackState = wordState;
#else
        URLState.fallbackState = wordState;
#endif
        
#if PK_PLATFORM_TWITTER_STATE
        self.twitterState    = [[[PKTwitterState alloc] init] autorelease];
        twitterState.fallbackState = symbolState;

        self.hashtagState    = [[[PKHashtagState alloc] init] autorelease];
        hashtagState.fallbackState = symbolState;
#endif

        self.tokenizerStates = [NSMutableArray arrayWithCapacity:STATE_COUNT];
        
        for (NSInteger i = 0; i < STATE_COUNT; i++) {
            [tokenizerStates addObject:[self defaultTokenizerStateFor:(PKUniChar)i]];
        }

        [symbolState add:@"<="];
        [symbolState add:@">="];
        [symbolState add:@"!="];
        [symbolState add:@"=="];
        
        [commentState addSingleLineStartMarker:@"//"];
        [commentState addMultiLineStartMarker:@"/*" endMarker:@"*/"];
        [self setTokenizerState:commentState from:'/' to:'/'];

//        
//        // Twitter handles
//        NSMutableCharacterSet *set = [NSMutableCharacterSet characterSetWithCharactersInString:@"_"];
//        [set formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]];
//        [self setTokenizerState:delimitState from:'@' to:'@'];
//        [delimitState addStartMarker:@"@" endMarker:nil allowedCharacterSet:[[set copy] autorelease]];
//
//        // Hashtags
//        [set addCharactersInString:@"%"];
//        [self setTokenizerState:delimitState from:'#' to:'#'];
//        [delimitState addStartMarker:@"#" endMarker:nil allowedCharacterSet:set];
//
//        delimitState.allowsUnbalancedStrings = YES;
    }
    return self;
}


- (void)dealloc {
    self.string = nil;
    self.stream = nil;
    self.reader = nil;
    self.tokenizerStates = nil;
    self.numberState = nil;
    self.quoteState = nil;
    self.commentState = nil;
    self.symbolState = nil;
    self.whitespaceState = nil;
    self.wordState = nil;
    self.delimitState = nil;
    self.URLState = nil;
#if PK_PLATFORM_EMAIL_STATE
    self.emailState = nil;
#endif
#if PK_PLATFORM_TWITTER_STATE
    self.twitterState = nil;
    self.hashtagState = nil;
#endif
    self.delegate = nil;
    [super dealloc];
}


- (PKToken *)nextToken {
    PKUniChar c = [reader read];
    
    PKToken *result = nil;
    
    if (PKEOF == c) {
        result = [PKToken EOFToken];
    } else {
        PKTokenizerState *state = [self tokenizerStateFor:c];
        if (state) {
            result = [state nextTokenFromReader:reader startingWith:c tokenizer:self];
            result.lineNumber = lineNumber;
        } else {
            result = [PKToken EOFToken];
        }
    }
    
    return result;
}


- (void)enumerateTokensUsingBlock:(void (^)(PKToken *tok, BOOL *stop))block {
    PKToken *eof = [PKToken EOFToken];

    PKToken *tok = nil;
    BOOL stop = NO;
    
    while ((tok = [self nextToken]) != eof) {
        block(tok, &stop);
        if (stop) break;
    }
}


- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    NSUInteger count = 0;

    if (0 == state->state) {
        state->mutationsPtr = &state->extra[0];
    }
    
    PKToken *eof = [PKToken EOFToken];
    PKToken *tok = [self nextToken];

    if (eof != tok) {
        state->itemsPtr = stackbuf;

        do  {
            stackbuf[count] = tok;
            state->state++;
            count++;
        } while (eof != (tok = [self nextToken]) && (count < len));

    } else {
        count = 0;
    }

    return count;
}


- (void)setTokenizerState:(PKTokenizerState *)state from:(PKUniChar)start to:(PKUniChar)end {
    NSParameterAssert(state);

    for (NSInteger i = start; i <= end; i++) {
        [tokenizerStates replaceObjectAtIndex:i withObject:state];
    }
}


- (void)setReader:(PKReader *)r {
    if (reader != r) {
        [reader autorelease];
        reader = [r retain];
        
        if (string) {
            reader.string = string;
        } else {
            reader.stream = stream;
        }
    }
}


- (void)setString:(NSString *)s {
    if (string != s) {
        [string autorelease];
        string = [s copy];
    }
    reader.string = string;
    self.lineNumber = 1;
}


- (void)setStream:(NSInputStream *)s {
    if (stream != s) {
        [stream autorelease];
        stream = [s retain];
    }
    reader.stream = stream;
    self.lineNumber = 1;
}


#pragma mark -

- (PKTokenizerState *)tokenizerStateFor:(PKUniChar)c {
    if (c < 0 || c >= STATE_COUNT) {
        // customization above 255 is not supported, so fetch default.
        return [self defaultTokenizerStateFor:c];
    } else {
        // customization below 255 is supported, so be sure to get the (possibly) customized state from `tokenizerStates`
        return [tokenizerStates objectAtIndex:c];
    }
}


- (PKTokenizerState *)defaultTokenizerStateFor:(PKUniChar)c {
    if (c >= 0 && c <= ' ') {            // From:  0 to: 32    From:0x00 to:0x20
        return whitespaceState;
    } else if (c == 33) {
        return symbolState;
    } else if (c == '"') {               // From: 34 to: 34    From:0x22 to:0x22
        return quoteState;
    } else if (c == '#') {               // From: 35 to: 35    From:0x23 to:0x23
#if PK_PLATFORM_TWITTER_STATE
        return hashtagState;
#else
        return symbolState;
#endif
    } else if (c >= 36 && c <= 38) {
        return symbolState;
    } else if (c == '\'') {              // From: 39 to: 39    From:0x27 to:0x27
        return quoteState;
    } else if (c >= 40 && c <= 42) {
        return symbolState;
    } else if (c == '+') {               // From: 43 to: 43    From:0x2B to:0x2B
        return symbolState;
    } else if (c == 44) {
        return symbolState;
    } else if (c == '-') {               // From: 45 to: 45    From:0x2D to:0x2D
        return numberState;
    } else if (c == '.') {               // From: 46 to: 46    From:0x2E to:0x2E
        return numberState;
    } else if (c == '/') {               // From: 47 to: 47    From:0x2F to:0x2F
        return symbolState;
    } else if (c >= '0' && c <= '9') {   // From: 48 to: 57    From:0x30 to:0x39
        return numberState;
    } else if (c >= 58 && c <= 63) {
        return symbolState;
    } else if (c == '@') {               // From: 64 to: 64    From:0x40 to:0x40
#if PK_PLATFORM_TWITTER_STATE
        return twitterState;
#else
        return symbolState;
#endif
    } else if (c >= 'A' && c <= 'Z') {   // From: 65 to: 90    From:0x41 to:0x5A
        return URLState;
    } else if (c >= 91 && c <= 96) {
        return symbolState;
    } else if (c >= 'a' && c <= 'z') {   // From: 97 to:122    From:0x61 to:0x7A
        return URLState;
    } else if (c >= 123 && c <= 191) {
        return symbolState;
    } else if (c >= 0xC0 && c <= 0xFF) { // From:192 to:255    From:0xC0 to:0xFF
        return wordState;
    } else if (c >= 0x19E0 && c <= 0x19FF) { // khmer symbols
        return symbolState;
    } else if (c >= 0x2000 && c <= 0x2BFF) { // various symbols
        return symbolState;
    } else if (c >= 0x2E00 && c <= 0x2E7F) { // supplemental punctuation
        return symbolState;
    } else if (c >= 0x3000 && c <= 0x303F) { // cjk symbols & punctuation
        return symbolState;
    } else if (c >= 0x3200 && c <= 0x33FF) { // enclosed cjk letters and months, cjk compatibility
        return symbolState;
    } else if (c >= 0x4DC0 && c <= 0x4DFF) { // yijing hexagram symbols
        return symbolState;
    } else if (c >= 0xFE30 && c <= 0xFE6F) { // cjk compatibility forms, small form variants
        return symbolState;
    } else if (c >= 0xFF00 && c <= 0xFFFF) { // hiragana & katakana halfwitdh & fullwidth forms, Specials
        return symbolState;
    } else {
        return wordState;
    }
}


- (NSInteger)tokenKindForStringValue:(NSString *)str {
    NSInteger x = 0;
    if (delegate) {
        x = [delegate tokenizer:self tokenKindForStringValue:str];
    }
    return x;
}

@synthesize numberState;
@synthesize quoteState;
@synthesize commentState;
@synthesize symbolState;
@synthesize whitespaceState;
@synthesize wordState;
@synthesize delimitState;
@synthesize URLState;
#if PK_PLATFORM_EMAIL_STATE
@synthesize emailState;
#endif
#if PK_PLATFORM_TWITTER_STATE
@synthesize twitterState;
@synthesize hashtagState;
#endif
@synthesize string;
@synthesize stream;
@synthesize reader;
@synthesize tokenizerStates;
@synthesize lineNumber;
@synthesize delegate;
@end
