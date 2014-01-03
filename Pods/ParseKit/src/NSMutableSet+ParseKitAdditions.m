//
//  NSMutableSet+ParseKitAdditions.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 4/5/13.
//
//

#import "NSMutableSet+ParseKitAdditions.h"

@implementation NSMutableSet (ParseKitAdditions)

- (void)unionSetTestingEquality:(NSSet *)s {
    NSMutableSet *all = [NSMutableSet setWithSet:self];
    
    for (id a2 in s) {
        BOOL found = NO;
        for (id a1 in all) {
            if ([a1 isEqual:a2]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [all addObject:a2];
        }
    }
    
    [self removeAllObjects];
    [self unionSet:all];
}


- (void)intersectSetTestingEquality:(NSSet *)s {
    for (id a1 in [[self copy] autorelease]) {
        BOOL found = NO;
        for (id a2 in s) {
            if ([a1 isEqual:a2]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [self removeObject:a1];
        }
    }
}


- (void)minusSetTestingEquality:(NSSet *)s {
    for (id a1 in [[self copy] autorelease]) {
        for (id a2 in s) {
            if ([a1 isEqual:a2]) {
                [self removeObject:a1];
            }
        }
    }
}


- (void)exclusiveSetTestingEquality:(NSSet *)s {
    for (id a1 in self) {
        BOOL found = NO;
        for (id a2 in s) {
            if ([a1 isEqual:a2 ]) {
                found = YES;
                break;
            }
        }
        if (found) {
            [self removeObject:a1];
        }
    }
    
    for (id a2 in s) {
        BOOL found = NO;
        for (id a1 in self) {
            if ([a2 isEqual:a1]) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [self addObject:a2];
        }
    }
}

@end

