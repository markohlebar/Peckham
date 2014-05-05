//
//  PKDefinitionPhaseVisitor.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKDefinitionPhaseVisitor.h"
#import <ParseKit/PKCompositeParser.h>
#import "NSString+ParseKitAdditions.h"
#import "PKSTokenKindDescriptor.h"

@interface PKDefinitionPhaseVisitor ()
@end

@implementation PKDefinitionPhaseVisitor

- (void)dealloc {
    self.assembler = nil;
    self.preassembler = nil;
    self.tokenKinds = nil;
    self.defaultDefNameTab = nil;
    [super dealloc];
}


- (void)visitRoot:(PKRootNode *)node {
    NSParameterAssert(node);
    NSAssert(self.symbolTable, @"");
    
    if (_collectTokenKinds) {
        [PKSTokenKindDescriptor clearCache];
        self.tokenKinds = [NSMutableDictionary dictionary];
        self.defaultDefNameTab = @{
            @"~": @"TILDE",
            @"`": @"BACKTICK",
            @"!": @"BANG",
            @"@": @"AT",
            @"#": @"POUND",
            @"$": @"DOLLAR",
            @"%": @"PERCENT",
            @"^": @"CARET",
            @"^=": @"XOR_EQUALS",
            @"&": @"AMPERSAND",
            @"&=": @"AND_EQUALS",
            @"&&": @"DOUBLE_AMPERSAND",
            @"*": @"STAR",
            @"*=": @"TIMES_EQUALS",
            @"(": @"OPEN_PAREN",
            @")": @"CLOSE_PAREN",
            @"-": @"MINUS",
            @"--": @"MINUS_MINUS",
            @"-=": @"MINUS_EQUALS",
            @"_": @"UNDERSCORE",
            @"+": @"PLUS",
            @"++": @"PLUS_PLUS",
            @"+=": @"PLUS_EQUALS",
            @"=": @"EQUALS",
            @"==": @"DOUBLE_EQUALS",
            @"===": @"TRIPLE_EQUALS",
            @":=": @"ASSIGN",
            @"!=": @"NE",
            @"<>": @"NOT_EQUAL",
            @"{": @"OPEN_CURLY",
            @"}": @"CLOSE_CURLY",
            @"[": @"OPEN_BRACKET",
            @"]": @"CLOSE_BRACKET",
            @"|": @"PIPE",
            @"|=": @"OR_EQUALS",
            @"||": @"DOUBLE_PIPE",
            @"\\": @"BACK_SLASH",
            @"\\=": @"DIV_EQUALS",
            @"/": @"FORWARD_SLASH",
            @"//": @"DOUBLE_SLASH",
            @":": @"COLON",
            @"::": @"DOUBLE_COLON",
            @";": @"SEMI_COLON",
            @"\"": @"QUOTE",
            @"'": @"APOSTROPHE",
            @"<": @"LT",
            @">": @"GT",
            @"<=": @"LE",
            @"=<": @"EL",
            @">=": @"GE",
            @"=>": @"HASH_ROCKET",
            @"->": @"RIGHT_ARROW",
            @"<-": @"LEFT_ARROW",
            @",": @"COMMA",
            @".": @"DOT",
            @"?": @"QUESTION",
            @"true": @"TRUE",
            @"false": @"FALSE",
            @"TRUE": @"TRUE_UPPER",
            @"FALSE": @"FALSE_UPPER",
            @"yes": @"YES",
            @"no": @"NO",
            @"YES": @"YES_UPPER",
            @"NO": @"NO_UPPER",
            @"or": @"OR",
            @"and": @"AND",
            @"not": @"NOT",
            @"xor": @"XOR",
            @"OR": @"OR_UPPER",
            @"AND": @"AND_UPPER",
            @"NOT": @"NOT_UPPER",
            @"XOR": @"XOR_UPPER",
            @"NULL": @"NULL_UPPER",
            @"null": @"NULL",
            @"Nil": @"NIL_TITLE",
            @"nil": @"NIL",
            @"id": @"ID",
            @"undefined": @"UNDEFINED",
            @"var": @"VAR",
            @"function": @"FUNCTION",
            @"instanceof": @"INSTANCEOF",
            @"def": @"DEF",
            @"if": @"IF",
            @"else": @"ELSE",
            @"elif": @"ELIF",
            @"elseif": @"ELSEIF",
            @"return": @"RETURN",
            @"break": @"BREAK",
            @"switch": @"SWITCH",
            @"while": @"WHILE",
            @"do": @"DO",
            @"for": @"FOR",
            @"in": @"IN",
            @"static": @"STATIC",
            @"extern": @"EXTERN",
            @"inline": @"INLINE",
            @"auto": @"AUTO",
            @"struct": @"STRUCT",
            @"class": @"CLASS",
            @"extends": @"EXTENDS",
            @"self": @"SELF",
            @"super": @"SUPER",
            @"this": @"THIS",
            @"void": @"VOID",
            @"int": @"INT",
            @"unsigned": @"UNSIGNED",
            @"long": @"LONG",
            @"short": @"SHORT",
            @"BOOL": @"BOOL_UPPER",
            @"bool": @"BOOL",
            @"float": @"FLOAT",
            @"double": @"DOUBLE",
            @"goto": @"GOTO",
            @"try": @"GOTO",
            @"catch": @"GOTO",
            @"finally": @"GOTO",
            @"throw": @"THROW",
            @"throws": @"THROWS",
            @"assert": @"ASSERT",
            @"start": @"START",
            
            @"EOF" : @"EOF_TITLE",
            @"Word" : @"WORD_TITLE",
            @"LowercaseWord" : @"UPPERCASEWORD_TITLE",
            @"UppercaseWord" : @"LOWERCASEWORD_TITLE",
            @"Number" : @"NUMBER_TITLE",
            @"QuotedString" : @"QUOTEDSTRING_TITLE",
            @"Symbol" : @"SYMBOL_TITLE",
            @"Comment" : @"COMMENT_TITLE",
            @"Empty" : @"EMPTY_TITLE",
            @"Any" : @"ANY_TITLE",
            @"S" : @"S_TITLE",
            @"Digit" : @"DIGIT_TITLE",
            @"Letter" : @"LETTER_TITLE",
            @"Char" : @"CHAR_TITLE",
            @"SpecificChar": @"SPECIFICCHAR_TITLE",
        };
    }
    
    [self recurse:node];

    if (_collectTokenKinds) {
        node.tokenKinds = [[[_tokenKinds allValues] mutableCopy] autorelease];
        self.tokenKinds = nil;
    }

    self.symbolTable = nil;
}


- (void)visitDefinition:(PKDefinitionNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);

    // find only child node (which represents this parser's type)
    NSAssert(1 == [node.children count], @"");
    PKBaseNode *child = node.children[0];
    
    // create parser
    Class parserCls = [child parserClass];
    PKCompositeParser *cp = [[[parserCls alloc] init] autorelease];

    // set name
    NSString *name = node.token.stringValue;
    cp.name = name;
    
    // set assembler callback
    if (_assembler || _preassembler) {
        NSString *cbname = node.callbackName;
        [self setAssemblerForParser:cp callbackName:cbname];
    }

    // define in symbol table
    self.symbolTable[name] = cp;
        
    for (PKBaseNode *child in node.children) {
        if (_collectTokenKinds) {
            child.defName = name;
        }
        [child visit:self];
    }
}


- (void)visitReference:(PKReferenceNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);

}


- (void)visitComposite:(PKCompositeNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    [self recurse:node];
}


- (void)visitCollection:(PKCollectionNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    [self recurse:node];
}


- (void)visitAlternation:(PKAlternationNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);

    NSAssert(2 == [node.children count], @"");
    
    BOOL simplify = NO;
    
    do {
        PKBaseNode *lhs = node.children[0];
        simplify = PKNodeTypeAlternation == lhs.type;
        
        // nested Alts should always be on the lhs. never on rhs.
        NSAssert(PKNodeTypeAlternation != [(PKBaseNode *)node.children[1] type], @"");
        
        if (simplify) {
            [node replaceChild:lhs withChildren:lhs.children];
        }
    } while (simplify);

    [self recurse:node];
}


- (void)visitOptional:(PKOptionalNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);

    [self recurse:node];
}


- (void)visitMultiple:(PKMultipleNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);

    [self recurse:node];
}


- (void)visitConstant:(PKConstantNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);

    if (_collectTokenKinds) {
        NSAssert(_tokenKinds, @"");
        
        NSString *name = node.token.stringValue;
        name = [NSString stringWithFormat:@"TOKEN_KIND_BUILTIN_%@", [name uppercaseString]];
        NSAssert([name length], @"");

        PKSTokenKindDescriptor *kind = [PKSTokenKindDescriptor descriptorWithStringValue:name name:name]; // yes, use name for both
        
        //_tokenKinds[name] = kind; do not add constants here.
        node.tokenKind = kind;
    }

}


- (void)visitLiteral:(PKLiteralNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
 
    if (_collectTokenKinds) {
        NSAssert(_tokenKinds, @"");
        
        NSString *strVal = [node.token.stringValue stringByTrimmingQuotes];

        NSString *name = nil;
        
        PKSTokenKindDescriptor *desc = _tokenKinds[strVal];
        if (desc) {
            name = desc.name;
        }
        if (!name) {
            NSString *defName = node.defName;
            if (!defName) {
                if (!defName) {
                    defName = _defaultDefNameTab[strVal];
                }
            }
            name = [NSString stringWithFormat:@"TOKEN_KIND_%@", [defName uppercaseString]];
        }
        
        NSAssert([name length], @"");
        PKSTokenKindDescriptor *kind = [PKSTokenKindDescriptor descriptorWithStringValue:strVal name:name];
        
        _tokenKinds[strVal] = kind;
        node.tokenKind = kind;
    }
}


- (void)visitDelimited:(PKDelimitedNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    if (_collectTokenKinds) {
        NSAssert(_tokenKinds, @"");
        
        NSString *strVal = [NSString stringWithFormat:@"%@,%@", node.startMarker, node.endMarker];
        
        NSString *name = nil;
        
        PKSTokenKindDescriptor *desc = _tokenKinds[strVal];
        if (desc) {
            name = desc.name;
        }
        if (!name) {
            NSString *defName = node.defName;
            if (!defName) {
                if (!defName) {
                    defName = _defaultDefNameTab[strVal];
                }
            }
            name = [NSString stringWithFormat:@"TOKEN_KIND_%@", [defName uppercaseString]];
        }
        
        NSAssert([name length], @"");
        PKSTokenKindDescriptor *kind = [PKSTokenKindDescriptor descriptorWithStringValue:strVal name:name];
        
        _tokenKinds[strVal] = kind;
        node.tokenKind = kind;
    }
}


- (void)visitPattern:(PKPatternNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
}


- (void)visitAction:(PKActionNode *)node {
    NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
}


#pragma mark -
#pragma mark Assemblers

- (void)setAssemblerForParser:(PKCompositeParser *)p callbackName:(NSString *)callbackName {
    NSString *parserName = p.name;
    NSString *selName = callbackName;
    
    BOOL setOnAll = (_assemblerSettingBehavior == PKParserFactoryAssemblerSettingBehaviorAll);
    
    if (setOnAll) {
        // continue
    } else {
        BOOL setOnExplicit = (_assemblerSettingBehavior == PKParserFactoryAssemblerSettingBehaviorExplicit);
        if (setOnExplicit && selName) {
            // continue
        } else {
            BOOL isTerminal = [p isKindOfClass:[PKTerminal class]];
            if (!isTerminal && !setOnExplicit) return;
            
            BOOL setOnTerminals = (_assemblerSettingBehavior == PKParserFactoryAssemblerSettingBehaviorTerminals);
            if (setOnTerminals && isTerminal) {
                // continue
            } else {
                return;
            }
        }
    }
    
    if (!selName) {
        selName = [self defaultAssemblerSelectorNameForParserName:parserName];
    }
    
    if (selName) {
        SEL sel = NSSelectorFromString(selName);
        if (_assembler && [_assembler respondsToSelector:sel]) {
            [p setAssembler:_assembler selector:sel];
        }
        if (_preassembler && [_preassembler respondsToSelector:sel]) {
            NSString *selName = [self defaultPreassemblerSelectorNameForParserName:parserName];
            [p setPreassembler:_preassembler selector:NSSelectorFromString(selName)];
        }
    }
}


- (NSString *)defaultAssemblerSelectorNameForParserName:(NSString *)parserName {
    return [self defaultAssemblerSelectorNameForParserName:parserName pre:NO];
}


- (NSString *)defaultPreassemblerSelectorNameForParserName:(NSString *)parserName {
    return [self defaultAssemblerSelectorNameForParserName:parserName pre:YES];
}


- (NSString *)defaultAssemblerSelectorNameForParserName:(NSString *)parserName pre:(BOOL)isPre {
    NSString *prefix = nil;
    if ([parserName hasPrefix:@"@"]) {
        return nil;
    } else {
        prefix = isPre ? @"parser:willMatch" :  @"parser:didMatch";
    }
    return [NSString stringWithFormat:@"%@%C%@:", prefix, (unichar)toupper([parserName characterAtIndex:0]), [parserName substringFromIndex:1]];
}

@end
