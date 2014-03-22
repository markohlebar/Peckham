//
//  PKNode.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKAST.h"
#import "PKNodeVisitor.h" // convenience

typedef enum NSUInteger {
    PKNodeTypeRoot = 0,
    PKNodeTypeDefinition,
    PKNodeTypeReference,
    PKNodeTypeConstant,
    PKNodeTypeLiteral,
    PKNodeTypeDelimited,
    PKNodeTypePattern,
    PKNodeTypeWhitespace,
    PKNodeTypeComposite,
    PKNodeTypeCollection,
    PKNodeTypeAlternation,
    PKNodeTypeOptional,
    PKNodeTypeMultiple,
    PKNodeTypeAction,
} PKNodeType;

@class PKParser;

@interface PKBaseNode : PKAST
+ (id)nodeWithToken:(PKToken *)tok;

- (void)visit:(id <PKNodeVisitor>)v;

- (void)replaceChild:(PKBaseNode *)oldChild withChild:(PKBaseNode *)newChild;
- (void)replaceChild:(PKBaseNode *)oldChild withChildren:(NSArray *)newChildren;

@property (nonatomic, assign, readonly) BOOL isTerminal;

@property (nonatomic, assign) BOOL discard;
@property (nonatomic, retain) Class parserClass;
@property (nonatomic, retain) PKParser *parser;

@property (nonatomic, retain) PKActionNode *actionNode;
@property (nonatomic, retain) PKActionNode *semanticPredicateNode;
@property (nonatomic, retain) PKActionNode *before;
@property (nonatomic, retain) PKActionNode *after;
@property (nonatomic, retain) NSString *defName;
@end
