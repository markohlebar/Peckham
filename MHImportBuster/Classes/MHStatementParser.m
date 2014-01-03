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
    NSArray *_registeredLOCClasses;
}

+(instancetype) parseFileAtPath:(NSString *)filePath
                        success:(MHArrayBlock)successBlock
                          error:(MHErrorBlock)errorBlock {
    MHStatementParser *parser = [[MHStatementParser alloc] initWithFilePath:filePath];
    [parser parse:successBlock
            error:errorBlock];
    return parser;
}

-(id) initWithFilePath:(NSString*) filePath {
    NSParameterAssert(filePath);
    self = [super init];
    if (self) {
        _filePath = filePath.copy;
        
        _registeredLOCClasses = @[
                                  [MHFrameworkImportStatement class],
                                  [MHProjectImportStatement class]
                                  ];
    }
    return self;
}

-(void) parse:(MHArrayBlock) successBlock
        error:(MHErrorBlock) errorBlock {
    NSParameterAssert(successBlock);
    NSParameterAssert(errorBlock);
    
    _successBlock = [successBlock copy];
    _errorBlock = [errorBlock copy];
    
    if ([_filePath isValidFilePath]) {
        [self tryParsingFile];
    }
    else {
        if(_errorBlock) {
            _errorBlock(MHImportBusterError(MHImportBusterFileDoesntExistAtPath, nil));
        }
    }
}

-(void) tryParsingFile {    
    //TODO: This will probably work OK for small files, consider reading line by line with NSFileHandle
    NSData *data = [NSData dataWithContentsOfFile:_filePath];
    NSString *interface = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *linesOfCode = [interface componentsSeparatedByString:@"\n"];
    
    PKTokenizer *tokenizer = [self tokenizer];
    NSMutableArray *statements = [NSMutableArray array];
    NSMutableArray *tokens = [NSMutableArray array];
    NSMutableSet *lineNumbers = [NSMutableSet set];
    
    NSInteger lineNumber = 0;
    for (NSString *line in linesOfCode) {
        tokenizer.string = line;
        [tokenizer enumerateTokensUsingBlock:^(PKToken *token, BOOL *stop) {
    
            //if this is the first token in the list or there is more than 1. 
            if ([self isCannonicalToken:token] || tokens.count >= 1) {
                [tokens addObject:token];
                [lineNumbers addObject:[NSNumber numberWithInteger:lineNumber]];
                
                for (Class class in _registeredLOCClasses) {
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
    }
    
    if (_successBlock) {
        _successBlock(statements);
    }
}

-(PKTokenizer *) tokenizer {
    PKTokenizer *tokenizer = [PKTokenizer tokenizer];
    //sets the parsing of #import "header.h" not to behave as quoted string
    [tokenizer setTokenizerState:(PKTokenizerState*)tokenizer.symbolState
                            from:'"'
                              to:'"'];
    //sets the parsing of anything that starts with a # as a word
    [tokenizer setTokenizerState:(PKTokenizerState*)tokenizer.wordState
                            from:'#'
                              to:'#'];
    return tokenizer;
}

-(BOOL) isCannonicalToken:(PKToken*) token {
    for (Class registeredClass in _registeredLOCClasses) {
        if([registeredClass isPrimaryCannonicalToken:token]) {
            return YES;
        }
    }
    return NO;
}

-(Class) LOCClassForToken:(PKToken*) token {
    Class class = nil;
    for (Class registeredClass in _registeredLOCClasses) {
        if([registeredClass isPrimaryCannonicalToken:token]) {
            class = registeredClass;
        }
    }
    return class;
}

@end
