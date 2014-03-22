//
//  PKNodeDelimited.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "PKBaseNode.h"

@class PKSTokenKindDescriptor;

@interface PKDelimitedNode : PKBaseNode
@property (nonatomic, retain) NSString *startMarker;
@property (nonatomic, retain) NSString *endMarker;
@property (nonatomic, retain) PKSTokenKindDescriptor *tokenKind;
@end
