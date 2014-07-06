//
//  MHHeaderCache.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHBlocks.h"

@class XCSourceFile;
typedef void(^MHHeaderLoadingBlock)(NSArray *headers, BOOL doneLoading);

@interface MHHeaderCache : NSObject
+ (instancetype)sharedCache;
- (void)loadHeaders:(MHHeaderLoadingBlock) headersBlock;
- (BOOL)isProjectHeader:(XCSourceFile *)header;
- (BOOL)isFrameworkHeader:(XCSourceFile *)header;
- (BOOL)isUserHeader:(XCSourceFile *)header;

@end
