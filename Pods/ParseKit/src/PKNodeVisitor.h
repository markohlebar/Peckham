//
//  PKNodeVisitor.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/7/12.
//
//

#import <Foundation/Foundation.h>

@class PKBaseNode;
@class PKRootNode;
@class PKDefinitionNode;
@class PKReferenceNode;
@class PKConstantNode;
@class PKLiteralNode;
@class PKDelimitedNode;
@class PKPatternNode;
@class PKCompositeNode;
@class PKCollectionNode;
@class PKAlternationNode;
@class PKOptionalNode;
@class PKMultipleNode;
@class PKActionNode;

@protocol PKNodeVisitor <NSObject>
- (void)visitRoot:(PKRootNode *)node;
- (void)visitDefinition:(PKDefinitionNode *)node;
- (void)visitReference:(PKReferenceNode *)node;
- (void)visitConstant:(PKConstantNode *)node;
- (void)visitLiteral:(PKLiteralNode *)node;
- (void)visitDelimited:(PKDelimitedNode *)node;
- (void)visitPattern:(PKPatternNode *)node;
- (void)visitComposite:(PKCompositeNode *)node;
- (void)visitCollection:(PKCollectionNode *)node;
- (void)visitAlternation:(PKAlternationNode *)node;
- (void)visitOptional:(PKOptionalNode *)node;
- (void)visitMultiple:(PKMultipleNode *)node;
- (void)visitAction:(PKActionNode *)node;

@property (nonatomic, retain) PKBaseNode *rootNode;
@end
