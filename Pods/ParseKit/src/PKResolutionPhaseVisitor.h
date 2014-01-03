//
//  PKReferencePhaseVisitor.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/16/13.
//
//

#import "PKBaseVisitor.h"

@interface PKResolutionPhaseVisitor : PKBaseVisitor

@property (nonatomic, retain) id currentParser;
@end
