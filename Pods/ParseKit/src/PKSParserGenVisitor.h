//
//  PKSParserGenVisitor.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/16/13.
//
//

#import "PKBaseVisitor.h"
#import "PKParserFactory.h"
#import "MGTemplateEngine.h"

@interface PKSParserGenVisitor : PKBaseVisitor <MGTemplateEngineDelegate>

@property (nonatomic, retain) MGTemplateEngine *engine;
@property (nonatomic, retain) NSString *interfaceOutputString;
@property (nonatomic, retain) NSString *implementationOutputString;
@property (nonatomic, retain) NSMutableArray *ruleMethodNames;
@property (nonatomic, assign) NSUInteger depth;
@property (nonatomic, assign) BOOL needsBacktracking;
@property (nonatomic, assign) BOOL isSpeculating;

@property (nonatomic, assign) BOOL enableARC;
@property (nonatomic, assign) BOOL enableHybridDFA;
@property (nonatomic, assign) BOOL enableMemoization;
@property (nonatomic, assign) BOOL enableAutomaticErrorRecovery;
@property (nonatomic, assign) PKParserFactoryAssemblerSettingBehavior preassemblerSettingBehavior;
@property (nonatomic, assign) PKParserFactoryAssemblerSettingBehavior assemblerSettingBehavior;
@end
