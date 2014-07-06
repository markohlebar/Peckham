//
//  NSArray+Operations.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 06/07/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "NSArray+Operations.h"

@implementation NSArray (Operations)
- (NSArray *)mhFlattenedArray {
    NSMutableArray *flattenedArray = [NSMutableArray arrayWithCapacity:self.count];
    for (id object in self) {
        if ([object isKindOfClass:[NSArray class]]) {
            [flattenedArray addObjectsFromArray:[(NSArray*)object mhFlattenedArray]];
        } else {
            [flattenedArray addObject:object];
        }
    }
    return flattenedArray.copy;
}
@end
