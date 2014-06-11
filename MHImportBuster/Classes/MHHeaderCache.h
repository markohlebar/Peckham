//
//  MHHeaderCache.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHBlocks.h"

@interface MHHeaderCache : NSObject
+ (instancetype)sharedCache;
- (void)loadHeaders:(MHArrayBlock) headersBlock;
- (BOOL)isProjectHeader:(NSString *)header;
- (BOOL)isFrameworkHeader:(NSString *)header;
@end
