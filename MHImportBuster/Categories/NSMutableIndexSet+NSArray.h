//
//  NSMutableIndexSet+NSArray.h
//  MHImportBuster
//
//  Created by marko.hlebar on 01/01/14.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableIndexSet (NSArray)

/**
 *  Constructs an index set from array of values
 *
 *  @param array an array
 *
 *  @return an index set
 */
+(instancetype) indexSetWithArray:(NSArray*) array;
@end
