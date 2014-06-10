//
//  MHHeaderCache.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHHeaderCache : NSObject
+ (NSArray *)frameworkHeaders;
+ (NSArray *)projectHeaders;
@end
