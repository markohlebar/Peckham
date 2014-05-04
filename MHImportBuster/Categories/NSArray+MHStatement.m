//
//  NSArray+MHStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 15/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "NSArray+MHStatement.h"
#import "MHInterfaceStatement.h"
#import "MHMethodStatement.h"

@implementation NSArray (MHStatement)

- (NSArray *)interfaceStatements {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF isKindOfClass:%@", [MHInterfaceStatement class]];
    return [self filteredArrayUsingPredicate:predicate];
}

- (NSArray *)methodStatements {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF isKindOfClass:%@", [MHMethodStatement class]];
    return [self filteredArrayUsingPredicate:predicate];
}
@end
