//
//  PKRootNode.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKBaseNode.h"

@interface PKRootNode : PKBaseNode

@property (nonatomic, retain) NSString *grammarName;
@property (nonatomic, retain) NSMutableArray *tokenKinds;
@end
