//
//  MHLOCParser.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <ParseKit/PKToken.h>
#import <ParseKit/PKTokenizer.h>
#import "MHInterfaceStatement.h"
#import "MHStatementParser.h"
#import "MHStatements.h"
#import "NSFileManager+Headers.h"
#import "NSString+Files.h"
#import "PKTokenizer+Factory.h"
#import "MHPropertyStatement.h"
#import "MHStringLiteralStatement.h"

@interface MHStatementParser ()
@property (nonatomic, strong) NSArray *registeredStatementClasses;
@end

@implementation MHStatementParser

+ (instancetype)parseFileAtPath:(NSString *)filePath
                        success:(MHArrayBlock)successBlock
                          error:(MHErrorBlock)errorBlock {
	if ([filePath isValidFilePath]) {
		NSData *data = [NSData dataWithContentsOfFile:filePath];
		NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		return [MHStatementParser parseText:text
		                            success:successBlock
		                              error:errorBlock];
	}
	else {
		if (errorBlock) {
			errorBlock(MHImportBusterError(MHImportBusterFileDoesntExistAtPath, nil));
		}        
        
	}
	return nil;
}

+ (instancetype)parseText:(NSString *)text
                  success:(MHArrayBlock)successBlock
                    error:(MHErrorBlock)errorBlock {
	MHStatementParser *parser = [[MHStatementParser alloc] init];
    NSError *error = nil;
    NSArray *statements = [parser parseText:text error:&error];
    if (!error) {
        successBlock(statements);
    }
    else {
        errorBlock(error);
    }
	return parser;
}

- (id)init {
	self = [super init];
	if (self) {
        
	}
	return self;
}

- (void) setRegisteredStatementClasses:(NSArray *)registeredStatementClasses {
    _registeredStatementClasses = registeredStatementClasses;
    
    if (![_registeredStatementClasses containsObject:[MHStringLiteralStatement class]]) {
        _registeredStatementClasses = [_registeredStatementClasses arrayByAddingObject:[MHStringLiteralStatement class]];
    }
}

- (NSArray*)parseText:(NSString *)text error:(NSError **)error statementClasses:(NSArray *)statementClasses {
    self.registeredStatementClasses = statementClasses;
    
    __block PKTokenizer *tokenizer = [PKTokenizer defaultTokenizer];
	NSMutableArray *statements = [NSMutableArray array];
    
	__block NSInteger lineNumber = 0;
    
    __block NSArray *candidateStatements = nil;
	[text enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop) {
	    tokenizer.string = line;
	    [tokenizer enumerateTokensUsingBlock: ^(PKToken *token, BOOL *stop) {
	        //if this is the first token in the list or there is more than 1.
            if (candidateStatements.count == 0) {
                candidateStatements = [self statementsForPrimaryToken:token];
            }
            
            [candidateStatements enumerateObjectsUsingBlock:^(MHStatement *statement, NSUInteger idx, BOOL *stop) {
                [statement addLineNumber:lineNumber];
                [statement feedToken:token];
                
                if ([statement containsCannonicalTokens]) {
                    [statements addObject:statement];
                    candidateStatements = nil;
                    *stop = YES;
                }
            }];
   
		}];
	    lineNumber++;
	}];
    
    return statements;
    
}

- (NSArray*)parseText:(NSString *)text error:(NSError **)error {
   return [self parseText:text
                    error:error
         statementClasses:[MHStatementParser rootStatementClasses]];
}

+ (NSArray*) rootStatementClasses {
    return @[
             [MHFrameworkImportStatement class],
             [MHProjectImportStatement class],
             [MHInterfaceStatement class]
             ];
}

- (NSArray *)statementsForPrimaryToken:(PKToken *)token {
    NSArray *classes = [self classesForPrimaryToken:token];
    NSMutableArray *statements = [NSMutableArray array];
    [classes enumerateObjectsUsingBlock:^(Class class, NSUInteger idx, BOOL *stop) {
        [statements addObject:[class statement]];
    }];
    return statements.copy;
}

- (NSArray *)classesForPrimaryToken:(PKToken *)token {
    NSMutableArray *classes = [NSMutableArray array];
    for (Class registeredClass in _registeredStatementClasses) {
		if ([registeredClass isPrimaryCannonicalToken:token]) {
			[classes addObject:registeredClass];
		}
	}
	return classes.copy;
}

@end
