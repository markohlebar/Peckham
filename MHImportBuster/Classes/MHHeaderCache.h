//
//  MHHeaderCache.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const MHHeaderCacheFrameworkHeaders;
extern NSString *const MHHeaderCacheProjectHeaders;

@interface MHHeaderCache : NSObject
/**
 *  Returns a dictionary with arrays for project and framework header file paths.
 *  The values can be accessed with respective MHHeaderCacheFrameworkHeaders and
 *  MHHeaderCacheProjectHeaders keys.
 *
 *  @return a dictionary
 */
+ (NSDictionary *)headersInCurrentWorkspace;
@end
