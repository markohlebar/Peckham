//
//  PKReferencePhaseVisitor.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/16/13.
//
//

#import "PKResolutionPhaseVisitor.h"
#import <ParseKit/ParseKit.h>
#import "NSString+ParseKitAdditions.h"

@interface PKTerminal ()
@property (nonatomic, readwrite, copy) NSString *string;
@end

@interface PKDelimitedString ()
@property (nonatomic, retain) NSString *startMarker;
@property (nonatomic, retain) NSString *endMarker;
@end

@interface PKPattern ()
@property (nonatomic, assign) PKPatternOptions options;
@end

@implementation PKResolutionPhaseVisitor

- (void)dealloc {
    self.currentParser = nil;
    [super dealloc];
}


- (id)parserFromNode:(PKBaseNode *)node {
    PKParser *cp = node.parser;
    if (!cp) {
        Class parserCls = [node parserClass];
        cp = [[[parserCls alloc] init] autorelease];
    }
    NSAssert([cp isKindOfClass:[PKParser class]], @"");
    
    return cp;
}


- (void)visitRoot:(PKRootNode *)node {
    NSParameterAssert(node);
    NSAssert(self.symbolTable, @"");

    [self recurse:node];
    
    self.symbolTable = nil;
}


- (void)visitDefinition:(PKDefinitionNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);

    NSString *name = node.token.stringValue;
    PKParser *p = self.symbolTable[name];
    NSAssert([p isKindOfClass:[PKParser class]], @"");
    
    PKBaseNode *parent = node;
    
    NSAssert(1 == [parent.children count], @"");
    PKBaseNode *child = parent.children[0];
    if (PKNodeTypeReference == child.type) {
        self.currentParser = p;
    } else {
        self.currentParser = nil;
        child.parser = p;
    }
    
    [child visit:self];        
}


- (void)visitReference:(PKReferenceNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    NSString *name = node.token.stringValue;
    
    PKParser *p = self.symbolTable[name];
    NSAssert([p isKindOfClass:[PKParser class]], @"");
    
    [self.currentParser add:p];
}


- (void)visitComposite:(PKCompositeNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    PKCompositeParser *cp = [self parserFromNode:node];
    NSAssert([cp isKindOfClass:[PKCompositeParser class]], @"");
    
    [self.currentParser add:cp];
    
    PKCompositeParser *oldParser = _currentParser;
    
    for (PKBaseNode *child in node.children) {
        self.currentParser = cp;
        [child visit:self];
    }
    
    self.currentParser = oldParser;
}


- (void)visitCollection:(PKCollectionNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    PKCompositeParser *cp = [self parserFromNode:node];
    NSAssert([cp isKindOfClass:[PKCollectionParser class]], @"");
    
    [self.currentParser add:cp];
    
    PKCompositeParser *oldParser = _currentParser;
    
    for (PKBaseNode *child in node.children) {
        self.currentParser = cp;
        [child visit:self];
    }
    
    self.currentParser = oldParser;
}


- (void)visitAlternation:(PKAlternationNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    [self visitCollection:node];
}


- (void)visitOptional:(PKOptionalNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    PKAlternation *alt = [self parserFromNode:node];
    NSAssert([alt isKindOfClass:[PKAlternation class]], @"");
    
    [self.currentParser add:alt];
    
    PKCompositeParser *oldParser = _currentParser;
    
    NSAssert(1 == [node.children count], @"");
    
    for (PKBaseNode *child in node.children) {
        self.currentParser = alt;
        [child visit:self];
    }
    
    [alt add:[PKEmpty empty]];
    
    self.currentParser = oldParser;
}


- (void)visitMultiple:(PKMultipleNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    PKSequence *seq = [self parserFromNode:node];
    NSAssert([seq isKindOfClass:[PKSequence class]], @"");
    
    [self.currentParser add:seq];
    
    PKCompositeParser *oldParser = _currentParser;
    
    NSAssert(1 == [node.children count], @"");
    PKBaseNode *child = node.children[0];
    self.currentParser = seq;
    [child visit:self];
    
    NSAssert(1 == [seq.subparsers count], @"");
    PKParser *sub = seq.subparsers[0];
    [seq add:[PKRepetition repetitionWithSubparser:sub]];
    
    self.currentParser = oldParser;
}


- (void)visitConstant:(PKConstantNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    PKTerminal *p = [self parserFromNode:node];
    NSAssert([p isKindOfClass:[PKTerminal class]], @"");

    NSString *literal = node.literal;
    if (literal) {
        p.string = literal;
    }
 
    if (node.discard) [p discard];
    
    NSAssert(!literal || [p.string isEqualToString:literal], @"");
    
    [self.currentParser add:p];
}


- (void)visitLiteral:(PKLiteralNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    PKLiteral *p = [self parserFromNode:node];
    NSAssert([p isKindOfClass:[PKLiteral class]] || [p isKindOfClass:[PKSpecificChar class]], @"");

    NSAssert(node.token.isQuotedString, @"");
    NSString *literal = [node.token.stringValue stringByTrimmingQuotes];
    NSAssert([literal length], @"");
    if (literal) {
        p.string = literal;
    }
    NSAssert(!literal || [p.string isEqualToString:literal], @"");
    
    if (node.discard) [p discard];

    [self.currentParser add:p];
}


- (void)visitDelimited:(PKDelimitedNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);

    PKDelimitedString *p = [self parserFromNode:node];
    NSAssert([p isKindOfClass:[PKDelimitedString class]], @"");

    p.startMarker = node.startMarker;
    p.endMarker = node.endMarker;
    
    if (node.discard) [p discard];

    [self.currentParser add:p];
}


- (void)visitPattern:(PKPatternNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
    PKPattern *p = [self parserFromNode:node];
    NSAssert([p isKindOfClass:[PKPattern class]], @"");
    NSAssert(node.token.isDelimitedString, @"");
    
    PKPatternOptions opts = node.options;
    
    NSString *regex = node.string;
    NSAssert(![regex hasPrefix:@"/"], @"");
    NSAssert(![regex hasSuffix:@"/"], @"");
    
    p.string = regex;
    p.options = opts;
    
    if (node.discard) [p discard];
    
    [self.currentParser add:p];
}


- (void)visitAction:(PKActionNode *)node {
    //NSLog(@"%s %@", __PRETTY_FUNCTION__, node);
    
}

@end
