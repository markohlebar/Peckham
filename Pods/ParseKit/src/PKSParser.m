//
//  PKSParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/26/13.
//
//

#import <ParseKit/PKSParser.h>
#import <ParseKit/PKToken.h>
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKSTokenAssembly.h>
#import <ParseKit/PKSRecognitionException.h>
#import "NSArray+ParseKitAdditions.h"

#define FAILED -1
#define NUM_DISPLAY_OBJS 6

#define LT(i) [self LT:(i)]
#define LA(i) [self LA:(i)]

@interface PKSTokenAssembly ()
- (void)consume:(PKToken *)tok;
@property (nonatomic, readwrite, retain) NSMutableArray *stack;
@end

@interface PKSParser ()
@property (nonatomic, assign) id assembler; // weak ref
@property (nonatomic, retain) PKSRecognitionException *_exception;
@property (nonatomic, retain) NSMutableArray *_lookahead;
@property (nonatomic, retain) NSMutableArray *_markers;
@property (nonatomic, assign) NSInteger _p;
@property (nonatomic, assign) NSInteger _skip;
@property (nonatomic, assign, readonly) BOOL _isSpeculating;
@property (nonatomic, retain) NSMutableDictionary *_tokenKindTab;
@property (nonatomic, retain) NSMutableArray *_tokenKindNameTab;
@property (nonatomic, retain) NSCountedSet *_resyncSet;

- (NSInteger)tokenKindForString:(NSString *)str;
- (NSString *)stringForTokenKind:(NSInteger)tokenKind;
- (BOOL)lookahead:(NSInteger)x predicts:(NSInteger)tokenKind;
- (void)fireSyntaxSelector:(SEL)sel withRuleName:(NSString *)ruleName;

- (void)_discard;

// error recovery
- (void)_attemptSingleTokenInsertionDeletion:(NSInteger)tokenKind;
- (void)pushFollow:(NSInteger)tokenKind;
- (void)popFollow:(NSInteger)tokenKind;
- (BOOL)resync;

// conenience
- (BOOL)_popBool;
- (NSInteger)_popInteger;
- (double)_popDouble;
- (PKToken *)_popToken;
- (NSString *)_popString;
- (void)_pushBool:(BOOL)yn;
- (void)_pushInteger:(NSInteger)i;
- (void)_pushDouble:(double)d;

// backtracking
- (NSInteger)_mark;
- (void)_unmark;
- (void)_seek:(NSInteger)index;
- (void)_sync:(NSInteger)i;
- (void)_fill:(NSInteger)n;

// memoization
- (BOOL)alreadyParsedRule:(NSMutableDictionary *)memoization;
- (void)memoize:(NSMutableDictionary *)memoization atIndex:(NSInteger)startTokenIndex failed:(BOOL)failed;
- (void)_clearMemo;
@end

@implementation PKSParser

- (id)init {
    self = [super init];
    if (self) {
        self.enableActions = YES;
        
        // create a single exception for reuse in control flow
        self._exception = [[[PKSRecognitionException alloc] initWithName:NSStringFromClass([PKSRecognitionException class]) reason:nil userInfo:nil] autorelease];
        
        self._tokenKindTab = [NSMutableDictionary dictionary];

        self._tokenKindNameTab = [NSMutableArray array];
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_INVALID] = @"";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_NUMBER] = @"Number";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_QUOTEDSTRING] = @"Quoted String";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_SYMBOL] = @"Symbol";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_WORD] = @"Word";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_LOWERCASEWORD] = @"Lowercase Word";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_UPPERCASEWORD] = @"Uppercase Word";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_WHITESPACE] = @"Whitespace";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_COMMENT] = @"Comment";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_DELIMITEDSTRING] = @"Delimited String";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_URL] = @"URL";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_EMAIL] = @"Email";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_TWITTER] = @"Twitter";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_HASHTAG] = @"Hashtag";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_EMPTY] = @"Empty";
        self._tokenKindNameTab[TOKEN_KIND_BUILTIN_ANY] = @"Any";
}
    return self;
}


- (void)dealloc {
    self.tokenizer = nil;
    self.assembly = nil;
    self.assembler = nil;
    self._exception = nil;
    self._lookahead = nil;
    self._markers = nil;
    self._tokenKindTab = nil;
    self._tokenKindNameTab = nil;
    self._resyncSet = nil;
    [super dealloc];
}


#pragma mark -
#pragma mark PKTokenizerDelegate

- (NSInteger)tokenizer:(PKTokenizer *)t tokenKindForStringValue:(NSString *)str {
    NSParameterAssert([str length]);
    return [self tokenKindForString:str];
}


- (NSInteger)tokenKindForString:(NSString *)str {
    NSInteger tokenKind = TOKEN_KIND_BUILTIN_INVALID;
    
    id obj = self._tokenKindTab[str];
    if (obj) {
        tokenKind = [obj integerValue];
    }
    
    return tokenKind;
}


- (NSString *)stringForTokenKind:(NSInteger)tokenKind {
    NSString *str = nil;
    
    if (TOKEN_KIND_BUILTIN_EOF == tokenKind) {
        str = [[PKToken EOFToken] stringValue];
    } else {
        str = self._tokenKindNameTab[tokenKind];
    }

    return str;
}


- (id)parseStream:(NSInputStream *)input assembler:(id)a error:(NSError **)outError {
    NSParameterAssert(input);
    
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [input open];
    
    PKTokenizer *t = [PKTokenizer tokenizerWithStream:input];

    id result = [self _parseWithTokenizer:t assembler:a error:outError];
    
    [input close];
    [input removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    return result;
}


- (id)parseString:(NSString *)input assembler:(id)a error:(NSError **)outError {
    NSParameterAssert(input);

    PKTokenizer *t = [PKTokenizer tokenizerWithString:input];
    
    id result = [self _parseWithTokenizer:t assembler:a error:outError];
    return result;
}


- (id)_parseWithTokenizer:(PKTokenizer *)t assembler:(id)a error:(NSError **)outError {
    id result = nil;
    
    // setup
    self.assembler = a;
    self.tokenizer = t;
    self.assembly = [PKSTokenAssembly assemblyWithTokenizer:_tokenizer];
    
    self.tokenizer.delegate = self;
    
    // setup speculation
    self._p = 0;
    self._lookahead = [NSMutableArray array];
    self._markers = [NSMutableArray array];

    if (_enableAutomaticErrorRecovery) {
        self._skip = 0;
        self._resyncSet = [NSCountedSet set];
    }

    [self _clearMemo];
    
    @try {

        @autoreleasepool {
            // parse
            [self _start];
            
            //NSLog(@"%@", _assembly);
            
            // get result
            if (_assembly.target) {
                result = _assembly.target;
            } else {
                result = _assembly;
            }

            [result retain]; // +1
        }
        [result autorelease]; // -1

    }
    @catch (NSException *ex) {
        if (outError) {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[ex userInfo]];
            
            // get reason
            NSString *reason = [ex reason];
            if ([reason length]) [userInfo setObject:reason forKey:NSLocalizedFailureReasonErrorKey];
            
            // get domain
            NSString *exName = [ex name];
            NSString *domain = exName ? exName : @"PKParseException";
            
            // convert to NSError
            NSError *err = [NSError errorWithDomain:domain code:47 userInfo:[[userInfo copy] autorelease]];
            *outError = err;
        } else {
            [ex raise];
        }
    }
    @finally {
        self.tokenizer.delegate = nil;
        self.tokenizer = nil;
        self.assembler = nil;
        self.assembly = nil;
        self._lookahead = nil;
        self._markers = nil;
    }
    
    return result;
}


- (void)match:(NSInteger)tokenKind discard:(BOOL)discard {
    NSParameterAssert(tokenKind != TOKEN_KIND_BUILTIN_INVALID);
    NSAssert(_lookahead, @"");
    
    // always match empty without consuming
    if (TOKEN_KIND_BUILTIN_EMPTY == tokenKind) return;

    if (_skip > 0) {
        self._skip--;
    } else {
        [self _attemptSingleTokenInsertionDeletion:tokenKind];
    }

    if (_skip > 0) {
        // skip

    } else {
        PKToken *lt = LT(1); // NSLog(@"%@", lt);
        
        BOOL matches = lt.tokenKind == tokenKind || TOKEN_KIND_BUILTIN_ANY == tokenKind;

        if (matches) {
            if (TOKEN_KIND_BUILTIN_EOF != tokenKind) {
                [self consume:lt];
                if (discard) [self _discard];
            }
        } else {
            NSString *msg = [NSString stringWithFormat:@"Expected : %@", [self stringForTokenKind:tokenKind]];
            [self raise:msg];
        }
    }
}


- (void)consume:(PKToken *)tok {
    if (!self._isSpeculating) {
        [_assembly consume:tok];
        //NSLog(@"%@", _assembly);
    }

    self._p++;
    
    // have we hit end of buffer when not backtracking?
    if (_p == [_lookahead count] && !self._isSpeculating) {
        // if so, it's an opp to start filling at index 0 again
        self._p = 0;
        [_lookahead removeAllObjects]; // size goes to 0, but retains memory on heap
        [self _clearMemo]; // clear all rule_memo dictionaries
    }
    
    [self _sync:1];
}


- (void)_discard {
    if (self._isSpeculating) return;
    
    NSAssert(![_assembly isStackEmpty], @"");
    [_assembly pop];
}


- (void)fireAssemblerSelector:(SEL)sel {
    if (self._isSpeculating) return;
    
    if (_assembler && [_assembler respondsToSelector:sel]) {
        [_assembler performSelector:sel withObject:self withObject:_assembly];
    }
}


- (void)fireSyntaxSelector:(SEL)sel withRuleName:(NSString *)ruleName {
    if (self._isSpeculating) return;
    
    if (_assembler && [_assembler respondsToSelector:sel]) {
        [_assembler performSelector:sel withObject:self withObject:ruleName];
    }
}


- (PKToken *)LT:(NSInteger)i {
    PKToken *tok = nil;
    
    for (;;) {
        [self _sync:i];

        NSUInteger idx = _p + i - 1;
        NSAssert(idx < [_lookahead count], @"");
        
        tok = _lookahead[idx];
        if (_silentlyConsumesWhitespace && tok.isWhitespace) {
            [self consume:tok];
        } else {
            //NSLog(@"LT(%ld) : %@", i, [tok debugDescription]);
            break;
        }
    }
    
    return tok;
}


- (NSInteger)LA:(NSInteger)i {
    return [LT(i) tokenKind];
}


- (double)LF:(NSInteger)i {
    return [LT(i) floatValue];
}


- (NSString *)LS:(NSInteger)i {
    return [LT(i) stringValue];
}


- (NSInteger)_mark {
    [_markers addObject:@(_p)];
    return _p;
}


- (void)_unmark {
    NSInteger marker = [[_markers lastObject] integerValue];
    [_markers removeLastObject];
    
    [self _seek:marker];
}


- (void)_seek:(NSInteger)index {
    self._p = index;
}


- (BOOL)_isSpeculating {
    return [_markers count] > 0;
}


- (void)_sync:(NSInteger)i {
    NSInteger lastNeededIndex = _p + i - 1;
    NSInteger lastFullIndex = [_lookahead count] - 1;
    
    if (lastNeededIndex > lastFullIndex) { // out of tokens ?
        NSInteger n = lastNeededIndex - lastFullIndex; // get n tokens
        [self _fill:n];
    }
}


- (void)_fill:(NSInteger)n {
    for (NSInteger i = 0; i <= n; ++i) { // <= ?? fetches an extra lookahead tok
        PKToken *tok = [_tokenizer nextToken];

        // set token kind
        if (TOKEN_KIND_BUILTIN_INVALID == tok.tokenKind) {
            tok.tokenKind = [self _tokenKindForToken:tok];
        }
        
        NSAssert(tok, @"");
        //NSLog(@"-nextToken: %@", [tok debugDescription]);

        [_lookahead addObject:tok];
    }
}


- (NSInteger)_tokenKindForToken:(PKToken *)tok {
    NSString *key = tok.stringValue;
    
    NSInteger x = tok.tokenKind;
    
    if (TOKEN_KIND_BUILTIN_INVALID == x) {
        x = [self tokenKindForString:key];
    
        if (TOKEN_KIND_BUILTIN_INVALID == x) {
            x = tok.tokenType;
        }
    }
    
    return x;
}


- (void)_raise:(NSString *)fmt, ... {
    va_list vargs;
    va_start(vargs, fmt);
    
    NSString *str = [[[NSString alloc] initWithFormat:fmt arguments:vargs] autorelease];
    _exception.currentReason = str;
    
    //NSLog(@"%@", str);

    // reuse
    @throw _exception;
    
    va_end(vargs);
}


- (void)raise:(NSString *)msg {
    NSString *fmt = nil;
    
#if defined(__LP64__)
    fmt = @"\n\n%@\nLine : %lu\nNear : %@\nFound : %@\n\n";
#else
    fmt = @"\n\n%@\nLine : %u\nNear : %@\nFound : %@\n\n";
#endif
    
    PKToken *lt = LT(1);
    
    NSUInteger lineNum = lt.lineNumber;
    //NSAssert(NSNotFound != lineNum, @"");

    NSMutableString *after = [NSMutableString string];
    NSString *delim = _silentlyConsumesWhitespace ? @"" : @" ";
    
    for (PKToken *tok in [_lookahead reverseObjectEnumerator]) {
        if (tok.lineNumber < lineNum - 1) break;
        if (tok.lineNumber == lineNum) {
            [after insertString:[NSString stringWithFormat:@"%@%@", tok.stringValue, delim] atIndex:0];
        }
    }
    
    NSString *found = lt ? lt.stringValue : @"-nothing-";
    [self _raise:fmt, msg, lineNum, after, found];
}


- (void)_attemptSingleTokenInsertionDeletion:(NSInteger)tokenKind {
    NSParameterAssert(TOKEN_KIND_BUILTIN_INVALID != tokenKind);
    
    if (TOKEN_KIND_BUILTIN_EOF == tokenKind) return; // don't insert or delete EOF

    if (_enableAutomaticErrorRecovery && LA(1) != tokenKind) {
        if (LA(2) == tokenKind) {
            [self consume:LT(1)]; // single token deletion
        } else {
            //self._skip++; // single token insertion
        }
    }
}


- (void)pushFollow:(NSInteger)tokenKind {
    NSParameterAssert(TOKEN_KIND_BUILTIN_INVALID != tokenKind);
    if (!_enableAutomaticErrorRecovery) return;
    
    NSAssert(_resyncSet, @"");
    [_resyncSet addObject:@(tokenKind)];
}


- (void)popFollow:(NSInteger)tokenKind {
    NSParameterAssert(TOKEN_KIND_BUILTIN_INVALID != tokenKind);
    if (!_enableAutomaticErrorRecovery) return;

    NSAssert(_resyncSet, @"");
    [_resyncSet removeObject:@(tokenKind)];
}


- (BOOL)resync {
    BOOL result = NO;

    if (_enableAutomaticErrorRecovery) {
        for (;;) {
            PKToken *lt = LT(1);
            //NSLog(@"LT(1) : %@", lt); NSLog(@"is %ld in %@ ?", LA(1), _resyncSet);
            
            NSAssert([_resyncSet count], @"");
            result = [_resyncSet containsObject:@(lt.tokenKind)];

            if (result) break;
            
            BOOL done = (lt == [PKToken EOFToken]);
            [self consume:lt];
            
            if (done) break;
        }
    }
    
    return result;
}


- (BOOL)predicts:(NSInteger)firstTokenKind, ... {
    NSParameterAssert(firstTokenKind != TOKEN_KIND_BUILTIN_INVALID);
    
    NSInteger la = LA(1);
    
    if ([self lookahead:la predicts:firstTokenKind]) {
        return YES;
    }
    
    BOOL result = NO;
    
    va_list vargs;
    va_start(vargs, firstTokenKind);
    
    int nextTokenKind;
    while ((nextTokenKind = va_arg(vargs, int))) {
        if ([self lookahead:la predicts:nextTokenKind]) {
            result = YES;
            break;
        }
    }
    
    va_end(vargs);
    
    return result;
}


- (BOOL)lookahead:(NSInteger)la predicts:(NSInteger)tokenKind {
    BOOL result = NO;
    
    if (TOKEN_KIND_BUILTIN_ANY == tokenKind && la != TOKEN_KIND_BUILTIN_EOF) {
        result = YES;
    } else if (la == tokenKind) {
        result = YES;
    }
    
    return result;
}


- (BOOL)speculate:(PKSSpeculateBlock)block {
    NSParameterAssert(block);
    
    BOOL success = YES;
    [self _mark];
    
    @try {
        if (block) block();
    }
    @catch (PKSRecognitionException *ex) {
        success = NO;
    }
    
    [self _unmark];
    return success;
}


- (id)execute:(PKSActionBlock)block {
    NSParameterAssert(block);
    if (self._isSpeculating || !_enableActions) return nil;

    id result = nil;
    if (block) result = block();
    return result;
}


- (void)tryAndRecover:(NSInteger)tokenKind block:(PKSResyncBlock)block completion:(PKSResyncBlock)completion {
    NSParameterAssert(block);
    NSParameterAssert(completion);
    
    [self pushFollow:tokenKind];
    @try {
        block();
    }
    @catch (PKSRecognitionException *ex) {
        if ([self resync]) {
            completion();
        } else {
            @throw ex;
        }
    }
    @finally {
        [self popFollow:tokenKind];
    }
}


- (BOOL)test:(PKSPredicateBlock)block {
    NSParameterAssert(block);
    
    BOOL result = YES;
    if (block) result = block();
    return result;
}


- (void)testAndThrow:(PKSPredicateBlock)block {
    NSParameterAssert(block);
    
    if (![self test:block]) {
        [self raise:@"Predicate Failed"];
    }
}


- (void)parseRule:(SEL)ruleSelector withMemo:(NSMutableDictionary *)memoization {
    BOOL failed = NO;
    NSInteger startTokenIndex = self._p;
    if (self._isSpeculating && [self alreadyParsedRule:memoization]) return;
                                
    @try { [self performSelector:ruleSelector]; }
    @catch (PKSRecognitionException *ex) { failed = YES; @throw ex; }
    @finally {
        if (self._isSpeculating) [self memoize:memoization atIndex:startTokenIndex failed:failed];
    }
}


- (BOOL)alreadyParsedRule:(NSMutableDictionary *)memoization {
    
    id idxKey = @(self._p);
    NSNumber *memoObj = memoization[idxKey];
    if (!memoObj) return NO;
    
    NSInteger memo = [memoObj integerValue];
    if (FAILED == memo) {
        [self _raise:@"already failed prior attempt at start token index %@", idxKey];
    }
    
    [self _seek:memo];
    return YES;
}


- (void)memoize:(NSMutableDictionary *)memoization atIndex:(NSInteger)startTokenIndex failed:(BOOL)failed {
    id idxKey = @(startTokenIndex);
    
    NSInteger stopTokenIdex = failed ? FAILED : self._p;
    id idxVal = @(stopTokenIdex);

    memoization[idxKey] = idxVal;
}


- (void)_clearMemo {
    
}


- (BOOL)_popBool {
    id obj = [self.assembly pop];
    return [obj boolValue];
}


- (NSInteger)_popInteger {
    id obj = [self.assembly pop];
    return [obj integerValue];
}


- (double)_popDouble {
    id obj = [self.assembly pop];
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        return [obj doubleValue];
    } else {
        return [(PKToken *)obj floatValue];
    }
}


- (PKToken *)_popToken {
    PKToken *tok = [self.assembly pop];
    NSAssert([tok isKindOfClass:[PKToken class]], @"");
    return tok;
}


- (NSString *)_popString {
    id obj = [self.assembly pop];
    if ([obj respondsToSelector:@selector(stringValue)]) {
        return [obj stringValue];
    } else {
        return [obj description];
    }
}


- (void)_pushBool:(BOOL)yn {
    [self.assembly push:(id)(yn ? kCFBooleanTrue : kCFBooleanFalse)];
}


- (void)_pushInteger:(NSInteger)i {
    [self.assembly push:@(i)];
}


- (void)_pushDouble:(double)d {
    [self.assembly push:@(d)];
}


- (void)_start {
    NSAssert2(0, @"%s is an abstract method and must be implemented in %@", __PRETTY_FUNCTION__, [self class]);
}


- (void)matchEOF:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_EOF discard:discard];
}


- (void)matchAny:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_ANY discard:discard];
}


- (void)matchEmpty:(BOOL)discard {
    NSParameterAssert(!discard);
}


- (void)matchWord:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_WORD discard:discard];
}


- (void)matchNumber:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_NUMBER discard:discard];
}


- (void)matchSymbol:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_SYMBOL discard:discard];
}


- (void)matchComment:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_COMMENT discard:discard];
}


- (void)matchWhitespace:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_WHITESPACE discard:discard];
}


- (void)matchQuotedString:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_QUOTEDSTRING discard:discard];
}


- (void)matchDelimitedString:(BOOL)discard {
    [self match:TOKEN_KIND_BUILTIN_DELIMITEDSTRING discard:discard];
}

@synthesize _exception = _exception;
@synthesize _lookahead = _lookahead;
@synthesize _markers = _markers;
@synthesize _p = _p;
@synthesize _skip = _skip;
@synthesize _tokenKindTab = _tokenKindTab;
@synthesize _resyncSet = _resyncSet;
@end
