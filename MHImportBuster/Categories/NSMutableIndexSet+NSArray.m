//
//  NSMutableIndexSet+NSArray.m
//  MHImportBuster
//
//  Created by marko.hlebar on 01/01/14.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "NSMutableIndexSet+NSArray.h"

@implementation NSMutableIndexSet (NSArray)
/**
 *  Constructs an index set from array of values
 *
 *  @param array an array
 *
 *  @return an index set
 */
+(instancetype) indexSetWithArray:(NSArray*) array {
    NSMutableIndexSet *set = [NSMutableIndexSet indexSet];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [set addIndex:[obj integerValue]];
    }];
    return set;
}
@end
