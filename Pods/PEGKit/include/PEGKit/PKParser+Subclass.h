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

@class PKToken;

@interface PKParser ()

// lookahead
- (PKToken *)LT:(NSInteger)i;
- (NSInteger)LA:(NSInteger)i;
- (double)LD:(NSInteger)i;
- (NSString *)LS:(NSInteger)i;

// parsing control flow
- (void)consume:(PKToken *)tok;
- (BOOL)predicts:(NSInteger)tokenKind, ...;
- (BOOL)speculate:(PKSSpeculateBlock)block;
- (void)match:(NSInteger)tokenKind discard:(BOOL)discard;

// error reporting
- (void)raise:(NSString *)msg;

// builtin token types
- (void)matchEOF:(BOOL)discard;
- (void)matchAny:(BOOL)discard;
- (void)matchEmpty:(BOOL)discard;
- (void)matchWord:(BOOL)discard;
- (void)matchNumber:(BOOL)discard;
- (void)matchSymbol:(BOOL)discard;
- (void)matchComment:(BOOL)discard;
- (void)matchWhitespace:(BOOL)discard;
- (void)matchQuotedString:(BOOL)discard;
- (void)matchDelimitedString:(BOOL)discard;
- (void)matchURL:(BOOL)discard;
- (void)matchEmail:(BOOL)discard;

// semantic predicates
- (BOOL)test:(PKSPredicateBlock)block;
- (void)testAndThrow:(PKSPredicateBlock)block;

// actions
- (void)execute:(PKSActionBlock)block;

// delegate callbacks
- (void)fireDelegateSelector:(SEL)sel;
- (void)fireSyntaxSelector:(SEL)sel withRuleName:(NSString *)ruleName;

// memoization
- (void)parseRule:(SEL)ruleSelector withMemo:(NSMutableDictionary *)memoization;

// error recovery
- (void)tryAndRecover:(NSInteger)tokenKind block:(PKSRecoverBlock)block completion:(PKSRecoverBlock)completion;

// convenience
- (BOOL)popBool;
- (NSInteger)popInteger;
- (NSUInteger)popUnsignedInteger;
- (float)popFloat;
- (double)popDouble;
- (PKToken *)popToken;
- (NSString *)popString;
- (NSString *)popQuotedString;

- (void)pushBool:(BOOL)yn;
- (void)pushInteger:(NSInteger)i;
- (void)pushUnsignedInteger:(NSUInteger)u;
- (void)pushFloat:(float)f;
- (void)pushDouble:(double)d;
- (void)pushAll:(NSArray *)a;

- (NSArray *)reversedArray:(NSArray *)a;

@property (nonatomic, retain) NSMutableDictionary *tokenKindTab;
@property (nonatomic, retain) NSMutableArray *tokenKindNameTab;
@property (nonatomic, retain) NSString *startRuleName;
@property (nonatomic, retain) NSString *statementTerminator;
@property (nonatomic, retain) NSString *singleLineCommentMarker;
@property (nonatomic, retain) NSString *blockStartMarker;
@property (nonatomic, retain) NSString *blockEndMarker;
@property (nonatomic, retain) NSString *braces;
@end

#define LT(i) [self LT:(i)]
#define LA(i) [self LA:(i)]
#define LS(i) [self LS:(i)]
#define LF(i) [self LD:(i)]

#define POP()            [self.assembly pop]
#define POP_STR()        [self popString]
#define POP_QUOTED_STR() [self popQuotedString]
#define POP_TOK()        [self popToken]
#define POP_BOOL()       [self popBool]
#define POP_INT()        [self popInteger]
#define POP_UINT()       [self popUnsignedInteger]
#define POP_FLOAT()      [self popFloat]
#define POP_DOUBLE()     [self popDouble]

#define PUSH(obj)      [self.assembly push:(id)(obj)]
#define PUSH_BOOL(yn)  [self pushBool:(BOOL)(yn)]
#define PUSH_INT(i)    [self pushInteger:(NSInteger)(i)]
#define PUSH_UINT(u)   [self pushUnsignedInteger:(NSUInteger)(u)]
#define PUSH_FLOAT(f)  [self pushFloat:(float)(f)]
#define PUSH_DOUBLE(d) [self pushDouble:(double)(d)]
#define PUSH_ALL(a)    [self pushAll:(a)]

#define REV(a) [self reversedArray:a]

#define EQ(a, b) [(a) isEqual:(b)]
#define NE(a, b) (![(a) isEqual:(b)])
#define EQ_IGNORE_CASE(a, b) (NSOrderedSame == [(a) compare:(b)])

#define MATCHES(pattern, str)               ([[NSRegularExpression regularExpressionWithPattern:(pattern) options:0                                  error:nil] numberOfMatchesInString:(str) options:0 range:NSMakeRange(0, [(str) length])] > 0)
#define MATCHES_IGNORE_CASE(pattern, str)   ([[NSRegularExpression regularExpressionWithPattern:(pattern) options:NSRegularExpressionCaseInsensitive error:nil] numberOfMatchesInString:(str) options:0 range:NSMakeRange(0, [(str) length])] > 0)

#define ABOVE(fence) [self.assembly objectsAbove:(fence)]
#define EMPTY() [self.assembly isStackEmpty]

#define LOG(obj) do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);
#define ASSERT(x) do { NSAssert((x), @""); } while (0);
