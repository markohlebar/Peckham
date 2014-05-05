//
//  PKParserFactory.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 12/12/08.
//  Copyright 2009 Todd Ditchendorf All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKParser;
@class PKAST;

void PKReleaseSubparserTree(PKParser *p);

typedef enum {
    PKParserFactoryAssemblerSettingBehaviorAll        = 0, // Default
    PKParserFactoryAssemblerSettingBehaviorNone       = 1,
    PKParserFactoryAssemblerSettingBehaviorTerminals  = 2,
    PKParserFactoryAssemblerSettingBehaviorExplicit   = 3,
    PKParserFactoryAssemblerSettingBehaviorSyntax     = 4,
} PKParserFactoryAssemblerSettingBehavior;

@interface PKParserFactory : NSObject

+ (PKParserFactory *)factory;

- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a error:(NSError **)outError;
- (PKParser *)parserFromGrammar:(NSString *)g assembler:(id)a preassembler:(id)pa error:(NSError **)outError;

- (PKAST *)ASTFromGrammar:(NSString *)g error:(NSError **)outError;

@property (nonatomic, assign) PKParserFactoryAssemblerSettingBehavior assemblerSettingBehavior;
@property (nonatomic, assign) BOOL collectTokenKinds;
@end
