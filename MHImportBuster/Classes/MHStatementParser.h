//
//  MHLOCParser.h
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MHStatementParser : NSObject

@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly, strong) NSArray *statementClasses;

+ (instancetype)parseFileAtPath:(NSString *)filePath
                        success:(MHArrayBlock)successBlock
                          error:(MHErrorBlock)errorBlock;
- (NSArray*)parseText:(NSString *)text error:(NSError **)error statementClasses:(NSArray *)statementClasses;
- (NSArray*)parseText:(NSString *)text error:(NSError **)error;
@end
