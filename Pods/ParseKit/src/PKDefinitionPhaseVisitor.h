//
//  PKDefinitionPhaseVisitor.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/4/12.
//
//

#import "PKBaseVisitor.h"
#import "PKParserFactory.h"

@interface PKDefinitionPhaseVisitor : PKBaseVisitor

@property (nonatomic, retain) id assembler;
@property (nonatomic, retain) id preassembler;
@property (nonatomic, assign) PKParserFactoryAssemblerSettingBehavior assemblerSettingBehavior;

@property (nonatomic, retain) NSMutableDictionary *tokenKinds;
@property (nonatomic, assign) BOOL collectTokenKinds;
@property (nonatomic, retain) NSDictionary *defaultDefNameTab;
@end
