//
//  MHLOCParser.h
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHStatementParser : NSObject
@property (nonatomic, copy, readonly) NSString *filePath;
@property (nonatomic, copy, readonly) MHArrayBlock successBlock;
@property (nonatomic, copy, readonly) MHErrorBlock errorBlock;

+(instancetype) parseFileAtPath:(NSString*) filePath
                        success:(MHArrayBlock) successBlock
                          error:(MHErrorBlock) errorBlock;
@end
