#import "ParseKitParser.h"
#import <ParseKit/ParseKit.h>

#define LT(i) [self LT:(i)]
#define LA(i) [self LA:(i)]
#define LS(i) [self LS:(i)]
#define LF(i) [self LF:(i)]

#define POP()       [self.assembly pop]
#define POP_STR()   [self _popString]
#define POP_TOK()   [self _popToken]
#define POP_BOOL()  [self _popBool]
#define POP_INT()   [self _popInteger]
#define POP_FLOAT() [self _popDouble]

#define PUSH(obj)     [self.assembly push:(id)(obj)]
#define PUSH_BOOL(yn) [self _pushBool:(BOOL)(yn)]
#define PUSH_INT(i)   [self _pushInteger:(NSInteger)(i)]
#define PUSH_FLOAT(f) [self _pushDouble:(double)(f)]

#define EQ(a, b) [(a) isEqual:(b)]
#define NE(a, b) (![(a) isEqual:(b)])
#define EQ_IGNORE_CASE(a, b) (NSOrderedSame == [(a) compare:(b)])

#define ABOVE(fence) [self.assembly objectsAbove:(fence)]

#define LOG(obj) do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);

@interface PKSParser ()
@property (nonatomic, retain) NSMutableDictionary *_tokenKindTab;
@property (nonatomic, retain) NSMutableArray *_tokenKindNameTab;

- (BOOL)_popBool;
- (NSInteger)_popInteger;
- (double)_popDouble;
- (PKToken *)_popToken;
- (NSString *)_popString;

- (void)_pushBool:(BOOL)yn;
- (void)_pushInteger:(NSInteger)i;
- (void)_pushDouble:(double)d;
@end

@interface ParseKitParser ()
@property (nonatomic, retain) NSMutableDictionary *statement_memo;
@property (nonatomic, retain) NSMutableDictionary *tokenizerDirective_memo;
@property (nonatomic, retain) NSMutableDictionary *decl_memo;
@property (nonatomic, retain) NSMutableDictionary *production_memo;
@property (nonatomic, retain) NSMutableDictionary *startProduction_memo;
@property (nonatomic, retain) NSMutableDictionary *namedAction_memo;
@property (nonatomic, retain) NSMutableDictionary *beforeKey_memo;
@property (nonatomic, retain) NSMutableDictionary *afterKey_memo;
@property (nonatomic, retain) NSMutableDictionary *varProduction_memo;
@property (nonatomic, retain) NSMutableDictionary *expr_memo;
@property (nonatomic, retain) NSMutableDictionary *term_memo;
@property (nonatomic, retain) NSMutableDictionary *orTerm_memo;
@property (nonatomic, retain) NSMutableDictionary *factor_memo;
@property (nonatomic, retain) NSMutableDictionary *nextFactor_memo;
@property (nonatomic, retain) NSMutableDictionary *phrase_memo;
@property (nonatomic, retain) NSMutableDictionary *phraseStar_memo;
@property (nonatomic, retain) NSMutableDictionary *phrasePlus_memo;
@property (nonatomic, retain) NSMutableDictionary *phraseQuestion_memo;
@property (nonatomic, retain) NSMutableDictionary *action_memo;
@property (nonatomic, retain) NSMutableDictionary *semanticPredicate_memo;
@property (nonatomic, retain) NSMutableDictionary *predicate_memo;
@property (nonatomic, retain) NSMutableDictionary *intersection_memo;
@property (nonatomic, retain) NSMutableDictionary *difference_memo;
@property (nonatomic, retain) NSMutableDictionary *primaryExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *negatedPrimaryExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *barePrimaryExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *subSeqExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *subTrackExpr_memo;
@property (nonatomic, retain) NSMutableDictionary *atomicValue_memo;
@property (nonatomic, retain) NSMutableDictionary *parser_memo;
@property (nonatomic, retain) NSMutableDictionary *discard_memo;
@property (nonatomic, retain) NSMutableDictionary *pattern_memo;
@property (nonatomic, retain) NSMutableDictionary *patternNoOpts_memo;
@property (nonatomic, retain) NSMutableDictionary *patternIgnoreCase_memo;
@property (nonatomic, retain) NSMutableDictionary *delimitedString_memo;
@property (nonatomic, retain) NSMutableDictionary *literal_memo;
@property (nonatomic, retain) NSMutableDictionary *constant_memo;
@property (nonatomic, retain) NSMutableDictionary *variable_memo;
@property (nonatomic, retain) NSMutableDictionary *delimOpen_memo;
@end

@implementation ParseKitParser

- (id)init {
    self = [super init];
    if (self) {
        self._tokenKindTab[@"Symbol"] = @(PARSEKIT_TOKEN_KIND_SYMBOL_TITLE);
        self._tokenKindTab[@"{,}?"] = @(PARSEKIT_TOKEN_KIND_SEMANTICPREDICATE);
        self._tokenKindTab[@"|"] = @(PARSEKIT_TOKEN_KIND_PIPE);
        self._tokenKindTab[@"after"] = @(PARSEKIT_TOKEN_KIND_AFTERKEY);
        self._tokenKindTab[@"}"] = @(PARSEKIT_TOKEN_KIND_CLOSE_CURLY);
        self._tokenKindTab[@"~"] = @(PARSEKIT_TOKEN_KIND_TILDE);
        self._tokenKindTab[@"start"] = @(PARSEKIT_TOKEN_KIND_START);
        self._tokenKindTab[@"Comment"] = @(PARSEKIT_TOKEN_KIND_COMMENT_TITLE);
        self._tokenKindTab[@"!"] = @(PARSEKIT_TOKEN_KIND_DISCARD);
        self._tokenKindTab[@"Number"] = @(PARSEKIT_TOKEN_KIND_NUMBER_TITLE);
        self._tokenKindTab[@"Any"] = @(PARSEKIT_TOKEN_KIND_ANY_TITLE);
        self._tokenKindTab[@";"] = @(PARSEKIT_TOKEN_KIND_SEMI_COLON);
        self._tokenKindTab[@"S"] = @(PARSEKIT_TOKEN_KIND_S_TITLE);
        self._tokenKindTab[@"{,}"] = @(PARSEKIT_TOKEN_KIND_ACTION);
        self._tokenKindTab[@"="] = @(PARSEKIT_TOKEN_KIND_EQUALS);
        self._tokenKindTab[@"&"] = @(PARSEKIT_TOKEN_KIND_AMPERSAND);
        self._tokenKindTab[@"/,/"] = @(PARSEKIT_TOKEN_KIND_PATTERNNOOPTS);
        self._tokenKindTab[@"?"] = @(PARSEKIT_TOKEN_KIND_PHRASEQUESTION);
        self._tokenKindTab[@"QuotedString"] = @(PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE);
        self._tokenKindTab[@"("] = @(PARSEKIT_TOKEN_KIND_OPEN_PAREN);
        self._tokenKindTab[@"@"] = @(PARSEKIT_TOKEN_KIND_AT);
        self._tokenKindTab[@"/,/i"] = @(PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE);
        self._tokenKindTab[@"before"] = @(PARSEKIT_TOKEN_KIND_BEFOREKEY);
        self._tokenKindTab[@"EOF"] = @(PARSEKIT_TOKEN_KIND_EOF_TITLE);
        self._tokenKindTab[@")"] = @(PARSEKIT_TOKEN_KIND_CLOSE_PAREN);
        self._tokenKindTab[@"*"] = @(PARSEKIT_TOKEN_KIND_PHRASESTAR);
        self._tokenKindTab[@"Letter"] = @(PARSEKIT_TOKEN_KIND_LETTER_TITLE);
        self._tokenKindTab[@"Empty"] = @(PARSEKIT_TOKEN_KIND_EMPTY_TITLE);
        self._tokenKindTab[@"+"] = @(PARSEKIT_TOKEN_KIND_PHRASEPLUS);
        self._tokenKindTab[@"["] = @(PARSEKIT_TOKEN_KIND_OPEN_BRACKET);
        self._tokenKindTab[@","] = @(PARSEKIT_TOKEN_KIND_COMMA);
        self._tokenKindTab[@"SpecificChar"] = @(PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE);
        self._tokenKindTab[@"-"] = @(PARSEKIT_TOKEN_KIND_MINUS);
        self._tokenKindTab[@"Word"] = @(PARSEKIT_TOKEN_KIND_WORD_TITLE);
        self._tokenKindTab[@"]"] = @(PARSEKIT_TOKEN_KIND_CLOSE_BRACKET);
        self._tokenKindTab[@"Char"] = @(PARSEKIT_TOKEN_KIND_CHAR_TITLE);
        self._tokenKindTab[@"Digit"] = @(PARSEKIT_TOKEN_KIND_DIGIT_TITLE);
        self._tokenKindTab[@"%{"] = @(PARSEKIT_TOKEN_KIND_DELIMOPEN);

        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_SYMBOL_TITLE] = @"Symbol";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_SEMANTICPREDICATE] = @"{,}?";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_PIPE] = @"|";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_AFTERKEY] = @"after";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_CLOSE_CURLY] = @"}";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_TILDE] = @"~";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_START] = @"start";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_COMMENT_TITLE] = @"Comment";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_DISCARD] = @"!";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_NUMBER_TITLE] = @"Number";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_ANY_TITLE] = @"Any";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_SEMI_COLON] = @";";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_S_TITLE] = @"S";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_ACTION] = @"{,}";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_EQUALS] = @"=";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_AMPERSAND] = @"&";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_PATTERNNOOPTS] = @"/,/";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_PHRASEQUESTION] = @"?";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE] = @"QuotedString";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_OPEN_PAREN] = @"(";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_AT] = @"@";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE] = @"/,/i";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_BEFOREKEY] = @"before";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_EOF_TITLE] = @"EOF";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_CLOSE_PAREN] = @")";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_PHRASESTAR] = @"*";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_LETTER_TITLE] = @"Letter";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_EMPTY_TITLE] = @"Empty";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_PHRASEPLUS] = @"+";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_OPEN_BRACKET] = @"[";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_COMMA] = @",";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE] = @"SpecificChar";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_MINUS] = @"-";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_WORD_TITLE] = @"Word";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_CLOSE_BRACKET] = @"]";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_CHAR_TITLE] = @"Char";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_DIGIT_TITLE] = @"Digit";
        self._tokenKindNameTab[PARSEKIT_TOKEN_KIND_DELIMOPEN] = @"%{";

        self.statement_memo = [NSMutableDictionary dictionary];
        self.tokenizerDirective_memo = [NSMutableDictionary dictionary];
        self.decl_memo = [NSMutableDictionary dictionary];
        self.production_memo = [NSMutableDictionary dictionary];
        self.startProduction_memo = [NSMutableDictionary dictionary];
        self.namedAction_memo = [NSMutableDictionary dictionary];
        self.beforeKey_memo = [NSMutableDictionary dictionary];
        self.afterKey_memo = [NSMutableDictionary dictionary];
        self.varProduction_memo = [NSMutableDictionary dictionary];
        self.expr_memo = [NSMutableDictionary dictionary];
        self.term_memo = [NSMutableDictionary dictionary];
        self.orTerm_memo = [NSMutableDictionary dictionary];
        self.factor_memo = [NSMutableDictionary dictionary];
        self.nextFactor_memo = [NSMutableDictionary dictionary];
        self.phrase_memo = [NSMutableDictionary dictionary];
        self.phraseStar_memo = [NSMutableDictionary dictionary];
        self.phrasePlus_memo = [NSMutableDictionary dictionary];
        self.phraseQuestion_memo = [NSMutableDictionary dictionary];
        self.action_memo = [NSMutableDictionary dictionary];
        self.semanticPredicate_memo = [NSMutableDictionary dictionary];
        self.predicate_memo = [NSMutableDictionary dictionary];
        self.intersection_memo = [NSMutableDictionary dictionary];
        self.difference_memo = [NSMutableDictionary dictionary];
        self.primaryExpr_memo = [NSMutableDictionary dictionary];
        self.negatedPrimaryExpr_memo = [NSMutableDictionary dictionary];
        self.barePrimaryExpr_memo = [NSMutableDictionary dictionary];
        self.subSeqExpr_memo = [NSMutableDictionary dictionary];
        self.subTrackExpr_memo = [NSMutableDictionary dictionary];
        self.atomicValue_memo = [NSMutableDictionary dictionary];
        self.parser_memo = [NSMutableDictionary dictionary];
        self.discard_memo = [NSMutableDictionary dictionary];
        self.pattern_memo = [NSMutableDictionary dictionary];
        self.patternNoOpts_memo = [NSMutableDictionary dictionary];
        self.patternIgnoreCase_memo = [NSMutableDictionary dictionary];
        self.delimitedString_memo = [NSMutableDictionary dictionary];
        self.literal_memo = [NSMutableDictionary dictionary];
        self.constant_memo = [NSMutableDictionary dictionary];
        self.variable_memo = [NSMutableDictionary dictionary];
        self.delimOpen_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    self.statement_memo = nil;
    self.tokenizerDirective_memo = nil;
    self.decl_memo = nil;
    self.production_memo = nil;
    self.startProduction_memo = nil;
    self.namedAction_memo = nil;
    self.beforeKey_memo = nil;
    self.afterKey_memo = nil;
    self.varProduction_memo = nil;
    self.expr_memo = nil;
    self.term_memo = nil;
    self.orTerm_memo = nil;
    self.factor_memo = nil;
    self.nextFactor_memo = nil;
    self.phrase_memo = nil;
    self.phraseStar_memo = nil;
    self.phrasePlus_memo = nil;
    self.phraseQuestion_memo = nil;
    self.action_memo = nil;
    self.semanticPredicate_memo = nil;
    self.predicate_memo = nil;
    self.intersection_memo = nil;
    self.difference_memo = nil;
    self.primaryExpr_memo = nil;
    self.negatedPrimaryExpr_memo = nil;
    self.barePrimaryExpr_memo = nil;
    self.subSeqExpr_memo = nil;
    self.subTrackExpr_memo = nil;
    self.atomicValue_memo = nil;
    self.parser_memo = nil;
    self.discard_memo = nil;
    self.pattern_memo = nil;
    self.patternNoOpts_memo = nil;
    self.patternIgnoreCase_memo = nil;
    self.delimitedString_memo = nil;
    self.literal_memo = nil;
    self.constant_memo = nil;
    self.variable_memo = nil;
    self.delimOpen_memo = nil;

    [super dealloc];
}

- (void)_clearMemo {
    [_statement_memo removeAllObjects];
    [_tokenizerDirective_memo removeAllObjects];
    [_decl_memo removeAllObjects];
    [_production_memo removeAllObjects];
    [_startProduction_memo removeAllObjects];
    [_namedAction_memo removeAllObjects];
    [_beforeKey_memo removeAllObjects];
    [_afterKey_memo removeAllObjects];
    [_varProduction_memo removeAllObjects];
    [_expr_memo removeAllObjects];
    [_term_memo removeAllObjects];
    [_orTerm_memo removeAllObjects];
    [_factor_memo removeAllObjects];
    [_nextFactor_memo removeAllObjects];
    [_phrase_memo removeAllObjects];
    [_phraseStar_memo removeAllObjects];
    [_phrasePlus_memo removeAllObjects];
    [_phraseQuestion_memo removeAllObjects];
    [_action_memo removeAllObjects];
    [_semanticPredicate_memo removeAllObjects];
    [_predicate_memo removeAllObjects];
    [_intersection_memo removeAllObjects];
    [_difference_memo removeAllObjects];
    [_primaryExpr_memo removeAllObjects];
    [_negatedPrimaryExpr_memo removeAllObjects];
    [_barePrimaryExpr_memo removeAllObjects];
    [_subSeqExpr_memo removeAllObjects];
    [_subTrackExpr_memo removeAllObjects];
    [_atomicValue_memo removeAllObjects];
    [_parser_memo removeAllObjects];
    [_discard_memo removeAllObjects];
    [_pattern_memo removeAllObjects];
    [_patternNoOpts_memo removeAllObjects];
    [_patternIgnoreCase_memo removeAllObjects];
    [_delimitedString_memo removeAllObjects];
    [_literal_memo removeAllObjects];
    [_constant_memo removeAllObjects];
    [_variable_memo removeAllObjects];
    [_delimOpen_memo removeAllObjects];
}

- (void)_start {
    
    do {
        [self statement]; 
    } while ([self speculate:^{ [self statement]; }]);
    [self matchEOF:YES]; 

}

- (void)__statement {
    
    if ([self speculate:^{ [self decl]; }]) {
        [self decl]; 
    } else if ([self speculate:^{ [self tokenizerDirective]; }]) {
        [self tokenizerDirective]; 
    } else {
        [self raise:@"No viable alternative found in rule 'statement'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchStatement:)];
}

- (void)statement {
    [self parseRule:@selector(__statement) withMemo:_statement_memo];
}

- (void)__tokenizerDirective {
    
    [self match:PARSEKIT_TOKEN_KIND_AT discard:YES]; 
    [self matchWord:NO]; 
    [self match:PARSEKIT_TOKEN_KIND_EQUALS discard:NO]; 
    do {
        if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
            [self matchWord:NO]; 
        } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
            [self matchQuotedString:NO]; 
        } else {
            [self raise:@"No viable alternative found in rule 'tokenizerDirective'."];
        }
    } while ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]);
    [self match:PARSEKIT_TOKEN_KIND_SEMI_COLON discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchTokenizerDirective:)];
}

- (void)tokenizerDirective {
    [self parseRule:@selector(__tokenizerDirective) withMemo:_tokenizerDirective_memo];
}

- (void)__decl {
    
    [self production]; 
    while ([self predicts:PARSEKIT_TOKEN_KIND_AT, 0]) {
        if ([self speculate:^{ [self namedAction]; }]) {
            [self namedAction]; 
        } else {
            break;
        }
    }
    [self match:PARSEKIT_TOKEN_KIND_EQUALS discard:NO]; 
    if ([self predicts:PARSEKIT_TOKEN_KIND_ACTION, 0]) {
        [self action]; 
    }
    [self expr]; 
    [self match:PARSEKIT_TOKEN_KIND_SEMI_COLON discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDecl:)];
}

- (void)decl {
    [self parseRule:@selector(__decl) withMemo:_decl_memo];
}

- (void)__production {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_AT, 0]) {
        [self startProduction]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self varProduction]; 
    } else {
        [self raise:@"No viable alternative found in rule 'production'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchProduction:)];
}

- (void)production {
    [self parseRule:@selector(__production) withMemo:_production_memo];
}

- (void)__startProduction {
    
    [self match:PARSEKIT_TOKEN_KIND_AT discard:YES]; 
    [self match:PARSEKIT_TOKEN_KIND_START discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchStartProduction:)];
}

- (void)startProduction {
    [self parseRule:@selector(__startProduction) withMemo:_startProduction_memo];
}

- (void)__namedAction {
    
    [self match:PARSEKIT_TOKEN_KIND_AT discard:YES]; 
    if ([self predicts:PARSEKIT_TOKEN_KIND_BEFOREKEY, 0]) {
        [self beforeKey]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_AFTERKEY, 0]) {
        [self afterKey]; 
    } else {
        [self raise:@"No viable alternative found in rule 'namedAction'."];
    }
    [self action]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNamedAction:)];
}

- (void)namedAction {
    [self parseRule:@selector(__namedAction) withMemo:_namedAction_memo];
}

- (void)__beforeKey {
    
    [self match:PARSEKIT_TOKEN_KIND_BEFOREKEY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchBeforeKey:)];
}

- (void)beforeKey {
    [self parseRule:@selector(__beforeKey) withMemo:_beforeKey_memo];
}

- (void)__afterKey {
    
    [self match:PARSEKIT_TOKEN_KIND_AFTERKEY discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAfterKey:)];
}

- (void)afterKey {
    [self parseRule:@selector(__afterKey) withMemo:_afterKey_memo];
}

- (void)__varProduction {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVarProduction:)];
}

- (void)varProduction {
    [self parseRule:@selector(__varProduction) withMemo:_varProduction_memo];
}

- (void)__expr {
    
    [self term]; 
    while ([self predicts:PARSEKIT_TOKEN_KIND_PIPE, 0]) {
        if ([self speculate:^{ [self orTerm]; }]) {
            [self orTerm]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchExpr:)];
}

- (void)expr {
    [self parseRule:@selector(__expr) withMemo:_expr_memo];
}

- (void)__term {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_SEMANTICPREDICATE, 0]) {
        [self semanticPredicate]; 
    }
    [self factor]; 
    while ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, PARSEKIT_TOKEN_KIND_CHAR_TITLE, PARSEKIT_TOKEN_KIND_COMMENT_TITLE, PARSEKIT_TOKEN_KIND_DELIMOPEN, PARSEKIT_TOKEN_KIND_DIGIT_TITLE, PARSEKIT_TOKEN_KIND_EMPTY_TITLE, PARSEKIT_TOKEN_KIND_EOF_TITLE, PARSEKIT_TOKEN_KIND_LETTER_TITLE, PARSEKIT_TOKEN_KIND_NUMBER_TITLE, PARSEKIT_TOKEN_KIND_OPEN_BRACKET, PARSEKIT_TOKEN_KIND_OPEN_PAREN, PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, PARSEKIT_TOKEN_KIND_S_TITLE, PARSEKIT_TOKEN_KIND_TILDE, PARSEKIT_TOKEN_KIND_WORD_TITLE, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        if ([self speculate:^{ [self nextFactor]; }]) {
            [self nextFactor]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchTerm:)];
}

- (void)term {
    [self parseRule:@selector(__term) withMemo:_term_memo];
}

- (void)__orTerm {
    
    [self match:PARSEKIT_TOKEN_KIND_PIPE discard:NO]; 
    [self term]; 

    [self fireAssemblerSelector:@selector(parser:didMatchOrTerm:)];
}

- (void)orTerm {
    [self parseRule:@selector(__orTerm) withMemo:_orTerm_memo];
}

- (void)__factor {
    
    [self phrase]; 
    if ([self predicts:PARSEKIT_TOKEN_KIND_PHRASEPLUS, PARSEKIT_TOKEN_KIND_PHRASEQUESTION, PARSEKIT_TOKEN_KIND_PHRASESTAR, 0]) {
        if ([self predicts:PARSEKIT_TOKEN_KIND_PHRASESTAR, 0]) {
            [self phraseStar]; 
        } else if ([self predicts:PARSEKIT_TOKEN_KIND_PHRASEPLUS, 0]) {
            [self phrasePlus]; 
        } else if ([self predicts:PARSEKIT_TOKEN_KIND_PHRASEQUESTION, 0]) {
            [self phraseQuestion]; 
        } else {
            [self raise:@"No viable alternative found in rule 'factor'."];
        }
    }
    if ([self predicts:PARSEKIT_TOKEN_KIND_ACTION, 0]) {
        [self action]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchFactor:)];
}

- (void)factor {
    [self parseRule:@selector(__factor) withMemo:_factor_memo];
}

- (void)__nextFactor {
    
    [self factor]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNextFactor:)];
}

- (void)nextFactor {
    [self parseRule:@selector(__nextFactor) withMemo:_nextFactor_memo];
}

- (void)__phrase {
    
    [self primaryExpr]; 
    while ([self predicts:PARSEKIT_TOKEN_KIND_AMPERSAND, PARSEKIT_TOKEN_KIND_MINUS, 0]) {
        if ([self speculate:^{ [self predicate]; }]) {
            [self predicate]; 
        } else {
            break;
        }
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPhrase:)];
}

- (void)phrase {
    [self parseRule:@selector(__phrase) withMemo:_phrase_memo];
}

- (void)__phraseStar {
    
    [self match:PARSEKIT_TOKEN_KIND_PHRASESTAR discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPhraseStar:)];
}

- (void)phraseStar {
    [self parseRule:@selector(__phraseStar) withMemo:_phraseStar_memo];
}

- (void)__phrasePlus {
    
    [self match:PARSEKIT_TOKEN_KIND_PHRASEPLUS discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPhrasePlus:)];
}

- (void)phrasePlus {
    [self parseRule:@selector(__phrasePlus) withMemo:_phrasePlus_memo];
}

- (void)__phraseQuestion {
    
    [self match:PARSEKIT_TOKEN_KIND_PHRASEQUESTION discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPhraseQuestion:)];
}

- (void)phraseQuestion {
    [self parseRule:@selector(__phraseQuestion) withMemo:_phraseQuestion_memo];
}

- (void)__action {
    
    [self match:PARSEKIT_TOKEN_KIND_ACTION discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchAction:)];
}

- (void)action {
    [self parseRule:@selector(__action) withMemo:_action_memo];
}

- (void)__semanticPredicate {
    
    [self match:PARSEKIT_TOKEN_KIND_SEMANTICPREDICATE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSemanticPredicate:)];
}

- (void)semanticPredicate {
    [self parseRule:@selector(__semanticPredicate) withMemo:_semanticPredicate_memo];
}

- (void)__predicate {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_AMPERSAND, 0]) {
        [self intersection]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_MINUS, 0]) {
        [self difference]; 
    } else {
        [self raise:@"No viable alternative found in rule 'predicate'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPredicate:)];
}

- (void)predicate {
    [self parseRule:@selector(__predicate) withMemo:_predicate_memo];
}

- (void)__intersection {
    
    [self match:PARSEKIT_TOKEN_KIND_AMPERSAND discard:YES]; 
    [self primaryExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchIntersection:)];
}

- (void)intersection {
    [self parseRule:@selector(__intersection) withMemo:_intersection_memo];
}

- (void)__difference {
    
    [self match:PARSEKIT_TOKEN_KIND_MINUS discard:YES]; 
    [self primaryExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDifference:)];
}

- (void)difference {
    [self parseRule:@selector(__difference) withMemo:_difference_memo];
}

- (void)__primaryExpr {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_TILDE, 0]) {
        [self negatedPrimaryExpr]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, PARSEKIT_TOKEN_KIND_CHAR_TITLE, PARSEKIT_TOKEN_KIND_COMMENT_TITLE, PARSEKIT_TOKEN_KIND_DELIMOPEN, PARSEKIT_TOKEN_KIND_DIGIT_TITLE, PARSEKIT_TOKEN_KIND_EMPTY_TITLE, PARSEKIT_TOKEN_KIND_EOF_TITLE, PARSEKIT_TOKEN_KIND_LETTER_TITLE, PARSEKIT_TOKEN_KIND_NUMBER_TITLE, PARSEKIT_TOKEN_KIND_OPEN_BRACKET, PARSEKIT_TOKEN_KIND_OPEN_PAREN, PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, PARSEKIT_TOKEN_KIND_S_TITLE, PARSEKIT_TOKEN_KIND_WORD_TITLE, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self barePrimaryExpr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'primaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPrimaryExpr:)];
}

- (void)primaryExpr {
    [self parseRule:@selector(__primaryExpr) withMemo:_primaryExpr_memo];
}

- (void)__negatedPrimaryExpr {
    
    [self match:PARSEKIT_TOKEN_KIND_TILDE discard:YES]; 
    [self barePrimaryExpr]; 

    [self fireAssemblerSelector:@selector(parser:didMatchNegatedPrimaryExpr:)];
}

- (void)negatedPrimaryExpr {
    [self parseRule:@selector(__negatedPrimaryExpr) withMemo:_negatedPrimaryExpr_memo];
}

- (void)__barePrimaryExpr {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, PARSEKIT_TOKEN_KIND_CHAR_TITLE, PARSEKIT_TOKEN_KIND_COMMENT_TITLE, PARSEKIT_TOKEN_KIND_DELIMOPEN, PARSEKIT_TOKEN_KIND_DIGIT_TITLE, PARSEKIT_TOKEN_KIND_EMPTY_TITLE, PARSEKIT_TOKEN_KIND_EOF_TITLE, PARSEKIT_TOKEN_KIND_LETTER_TITLE, PARSEKIT_TOKEN_KIND_NUMBER_TITLE, PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, PARSEKIT_TOKEN_KIND_S_TITLE, PARSEKIT_TOKEN_KIND_WORD_TITLE, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self atomicValue]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_OPEN_PAREN, 0]) {
        [self subSeqExpr]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self subTrackExpr]; 
    } else {
        [self raise:@"No viable alternative found in rule 'barePrimaryExpr'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchBarePrimaryExpr:)];
}

- (void)barePrimaryExpr {
    [self parseRule:@selector(__barePrimaryExpr) withMemo:_barePrimaryExpr_memo];
}

- (void)__subSeqExpr {
    
    [self match:PARSEKIT_TOKEN_KIND_OPEN_PAREN discard:NO]; 
    [self expr]; 
    [self match:PARSEKIT_TOKEN_KIND_CLOSE_PAREN discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSubSeqExpr:)];
}

- (void)subSeqExpr {
    [self parseRule:@selector(__subSeqExpr) withMemo:_subSeqExpr_memo];
}

- (void)__subTrackExpr {
    
    [self match:PARSEKIT_TOKEN_KIND_OPEN_BRACKET discard:NO]; 
    [self expr]; 
    [self match:PARSEKIT_TOKEN_KIND_CLOSE_BRACKET discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchSubTrackExpr:)];
}

- (void)subTrackExpr {
    [self parseRule:@selector(__subTrackExpr) withMemo:_subTrackExpr_memo];
}

- (void)__atomicValue {
    
    [self parser]; 
    if ([self predicts:PARSEKIT_TOKEN_KIND_DISCARD, 0]) {
        [self discard]; 
    }

    [self fireAssemblerSelector:@selector(parser:didMatchAtomicValue:)];
}

- (void)atomicValue {
    [self parseRule:@selector(__atomicValue) withMemo:_atomicValue_memo];
}

- (void)__parser {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self variable]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self literal]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, 0]) {
        [self pattern]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_DELIMOPEN, 0]) {
        [self delimitedString]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, PARSEKIT_TOKEN_KIND_CHAR_TITLE, PARSEKIT_TOKEN_KIND_COMMENT_TITLE, PARSEKIT_TOKEN_KIND_DIGIT_TITLE, PARSEKIT_TOKEN_KIND_EMPTY_TITLE, PARSEKIT_TOKEN_KIND_EOF_TITLE, PARSEKIT_TOKEN_KIND_LETTER_TITLE, PARSEKIT_TOKEN_KIND_NUMBER_TITLE, PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, PARSEKIT_TOKEN_KIND_S_TITLE, PARSEKIT_TOKEN_KIND_WORD_TITLE, 0]) {
        [self constant]; 
    } else {
        [self raise:@"No viable alternative found in rule 'parser'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchParser:)];
}

- (void)parser {
    [self parseRule:@selector(__parser) withMemo:_parser_memo];
}

- (void)__discard {
    
    [self match:PARSEKIT_TOKEN_KIND_DISCARD discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDiscard:)];
}

- (void)discard {
    [self parseRule:@selector(__discard) withMemo:_discard_memo];
}

- (void)__pattern {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_PATTERNNOOPTS, 0]) {
        [self patternNoOpts]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE, 0]) {
        [self patternIgnoreCase]; 
    } else {
        [self raise:@"No viable alternative found in rule 'pattern'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchPattern:)];
}

- (void)pattern {
    [self parseRule:@selector(__pattern) withMemo:_pattern_memo];
}

- (void)__patternNoOpts {
    
    [self match:PARSEKIT_TOKEN_KIND_PATTERNNOOPTS discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPatternNoOpts:)];
}

- (void)patternNoOpts {
    [self parseRule:@selector(__patternNoOpts) withMemo:_patternNoOpts_memo];
}

- (void)__patternIgnoreCase {
    
    [self match:PARSEKIT_TOKEN_KIND_PATTERNIGNORECASE discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchPatternIgnoreCase:)];
}

- (void)patternIgnoreCase {
    [self parseRule:@selector(__patternIgnoreCase) withMemo:_patternIgnoreCase_memo];
}

- (void)__delimitedString {
    
    [self delimOpen]; 
    [self matchQuotedString:NO]; 
    if ([self speculate:^{ [self match:PARSEKIT_TOKEN_KIND_COMMA discard:YES]; [self matchQuotedString:NO]; }]) {
        [self match:PARSEKIT_TOKEN_KIND_COMMA discard:YES]; 
        [self matchQuotedString:NO]; 
    }
    [self match:PARSEKIT_TOKEN_KIND_CLOSE_CURLY discard:YES]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDelimitedString:)];
}

- (void)delimitedString {
    [self parseRule:@selector(__delimitedString) withMemo:_delimitedString_memo];
}

- (void)__literal {
    
    [self matchQuotedString:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchLiteral:)];
}

- (void)literal {
    [self parseRule:@selector(__literal) withMemo:_literal_memo];
}

- (void)__constant {
    
    if ([self predicts:PARSEKIT_TOKEN_KIND_EOF_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_EOF_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_WORD_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_WORD_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_NUMBER_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_NUMBER_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_QUOTEDSTRING_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_SYMBOL_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_SYMBOL_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_COMMENT_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_COMMENT_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_EMPTY_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_EMPTY_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_ANY_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_ANY_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_S_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_S_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_DIGIT_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_DIGIT_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_LETTER_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_LETTER_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_CHAR_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_CHAR_TITLE discard:NO]; 
    } else if ([self predicts:PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE, 0]) {
        [self match:PARSEKIT_TOKEN_KIND_SPECIFICCHAR_TITLE discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'constant'."];
    }

    [self fireAssemblerSelector:@selector(parser:didMatchConstant:)];
}

- (void)constant {
    [self parseRule:@selector(__constant) withMemo:_constant_memo];
}

- (void)__variable {
    
    [self matchWord:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchVariable:)];
}

- (void)variable {
    [self parseRule:@selector(__variable) withMemo:_variable_memo];
}

- (void)__delimOpen {
    
    [self match:PARSEKIT_TOKEN_KIND_DELIMOPEN discard:NO]; 

    [self fireAssemblerSelector:@selector(parser:didMatchDelimOpen:)];
}

- (void)delimOpen {
    [self parseRule:@selector(__delimOpen) withMemo:_delimOpen_memo];
}

@end