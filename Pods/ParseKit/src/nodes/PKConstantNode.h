//
//  PKNodeTerminal.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKBaseNode.h"

@class PKSTokenKindDescriptor;

@interface PKConstantNode : PKBaseNode

@property (nonatomic, copy) NSString *literal;
@property (nonatomic, retain) PKSTokenKindDescriptor *tokenKind;
@end
