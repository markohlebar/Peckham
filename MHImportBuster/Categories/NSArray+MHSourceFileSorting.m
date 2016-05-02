//
//  NSArray+MHSourceFileSorting.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 02/05/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import "NSArray+MHSourceFileSorting.h"
#import "MHHeaderCache.h"
#import "MHSourceFile.h"
#import "NSString+CamelCase.h"

@implementation NSArray (MHSourceFileSorting)

- (NSArray *)mh_sortedResultsForSearchString:(NSString *)string; {
    //TODO: this implicit dependency is not great.
    MHHeaderCache *cache = [MHHeaderCache sharedCache];
    
    return [self sortedArrayUsingComparator:^NSComparisonResult(id <MHSourceFile> _Nonnull obj1, id <MHSourceFile> _Nonnull obj2) {
        BOOL matchCamelCase1 = [obj1.name.mh_camelCaseInitials.lowercaseString containsString:string];
        BOOL matchCamelCase2 = [obj2.name.mh_camelCaseInitials.lowercaseString containsString:string];
        
        if (matchCamelCase1 && matchCamelCase2) {
            return NSOrderedSame;
        }
        else if (matchCamelCase2) {
            return NSOrderedDescending;
        }
        
        BOOL isFramework1 = [cache isFrameworkHeader:obj1];
        BOOL isFramework2 = [cache isFrameworkHeader:obj2];
        
        if (isFramework1 && isFramework2) {
            return NSOrderedSame;
        }
        else if (isFramework1) {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
}

@end
