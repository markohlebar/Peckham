//
//  MHHeaderCache.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHBlocks.h"

typedef void(^MHHeaderLoadingBlock)(NSArray *headers, BOOL doneLoading);

@protocol MHSourceFile;
@interface MHHeaderCache : NSObject
+ (instancetype)sharedCache;
- (void)loadHeaders:(MHHeaderLoadingBlock) headersBlock;
- (BOOL)isProjectHeader:(id <MHSourceFile> )header;
- (BOOL)isFrameworkHeader:(id <MHSourceFile> )header;
- (BOOL)isUserHeader:(id <MHSourceFile> )header;
- (BOOL)isLoading;

@end
