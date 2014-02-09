//
//  MHLOCParser.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import "MHStatementParser.h"
#import <ParseKit/PKTokenizer.h>
#import <ParseKit/PKToken.h>
#import "NSString+Files.h"
#import "MHStatements.h"

@implementation MHStatementParser
{
    NSArray *_registeredStatementClasses;
}

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

- (NSArray*)parseText:(NSString *)text error:(NSError **)error statementClasses:(NSArray *)statementClasses {
    _registeredStatementClasses = statementClasses;
    
    __block PKTokenizer *tokenizer = [MHStatementParser tokenizer];
	NSMutableArray *statements = [NSMutableArray array];
	NSMutableArray *tokens = [NSMutableArray array];
	NSMutableSet *lineNumbers = [NSMutableSet set];
    
	__block NSInteger lineNumber = 0;
    
	[text enumerateLinesUsingBlock: ^(NSString *line, BOOL *stop) {
	    tokenizer.string = line;
	    [tokenizer enumerateTokensUsingBlock: ^(PKToken *token, BOOL *stop) {
	        //if this is the first token in the list or there is more than 1.
	        if ([self isCannonicalToken:token] || tokens.count >= 1) {
	            [tokens addObject:token];
	            [lineNumbers addObject:[NSNumber numberWithInteger:lineNumber]];
                
	            for (Class class in _registeredStatementClasses) {
	                if ([class containsCannonicalTokens:tokens]) {
	                    MHStatement *statement = [class statement];
	                    [statement feedTokens:tokens];
	                    [statement addLineNumber:lineNumber];
                        
	                    [statements addObject:statement];
	                    //clear tokens
	                    [tokens removeAllObjects];
	                    [lineNumbers removeAllObjects];
					}
				}
			}
		}];
	    lineNumber++;
	}];
    
    return statements;
    
}

- (NSArray*)parseText:(NSString *)text error:(NSError **)error {
   return [self parseText:text
                    error:error
         statementClasses:[MHStatementParser allStatementClasses]];
}

+ (NSArray*) allStatementClasses {
    return @[
             [MHFrameworkImportStatement class],
             [MHProjectImportStatement class],
             [MHClassMethodStatement class],
             [MHInstanceMethodStatement class]
             ];
}

+ (PKTokenizer *)tokenizer {
	PKTokenizer *tokenizer = [PKTokenizer tokenizer];
	//sets the parsing of #import "header.h" not to behave as quoted string
	[tokenizer setTokenizerState:(PKTokenizerState *)tokenizer.symbolState
	                        from:'"'
	                          to:'"'];
	//sets the parsing of anything that starts with a # as a word
	[tokenizer setTokenizerState:(PKTokenizerState *)tokenizer.wordState
	                        from:'#'
	                          to:'#'];
	return tokenizer;
}

- (BOOL)isCannonicalToken:(PKToken *)token {
	for (Class registeredClass in _registeredStatementClasses) {
		if ([registeredClass isPrimaryCannonicalToken:token]) {
			return YES;
		}
	}
	return NO;
}

- (Class)LOCClassForToken:(PKToken *)token {
	Class class = nil;
	for (Class registeredClass in _registeredStatementClasses) {
		if ([registeredClass isPrimaryCannonicalToken:token]) {
			class = registeredClass;
		}
	}
	return class;
}

@end
