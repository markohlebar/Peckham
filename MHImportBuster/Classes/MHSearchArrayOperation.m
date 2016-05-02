//
//  MHSearchArrayOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/06/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHSearchArrayOperation.h"
#import "NSString+Extensions.h"
#import "MHSourceFile.h"
#import "NSString+FuzzySearch.h"
#import "NSString+CamelCase.h"
#import "MHHeaderCache.h"

@implementation MHSearchArrayOperation
+ (instancetype) operationWithSearchArray:(NSArray *) searchArray
                             searchString:(NSString *) searchString
                       searchResultsBlock:(MHArrayBlock) searchResultsBlock {
    return [[self alloc] initWithSearchArray:searchArray
                                searchString:searchString
                          searchResultsBlock:searchResultsBlock];
}

- (instancetype)initWithSearchArray:(NSArray *) searchArray
                       searchString:(NSString *) searchString
                 searchResultsBlock:(MHArrayBlock) searchResultsBlock
{
    self = [super init];
    if (self) {
        _searchArray = searchArray.copy;
        _searchString = searchString.copy;
        _searchResultsBlock = [searchResultsBlock copy];
    }
    return self;
}

- (void) execute {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastPathComponent LIKE[cd] %@", [self.searchString mh_fuzzifiedSearchString]];
    NSArray *results = [self.searchArray filteredArrayUsingPredicate:predicate];
    results = [self resultsSortedByCapitalizedResultsMatches:results];
    results = [self resultsSortedByFrameworksMatches:results];
    [self notifyWithResults:results];
}

- (NSArray *)resultsSortedByCapitalizedResultsMatches:(NSArray *)results {
    NSArray *sorted = [results sortedArrayUsingComparator:^NSComparisonResult(id <MHSourceFile> _Nonnull obj1, id <MHSourceFile> _Nonnull obj2) {
        BOOL matchCamelCase1 = [obj1.name.mh_camelCaseInitials.lowercaseString containsString:_searchString];
        BOOL matchCamelCase2 = [obj2.name.mh_camelCaseInitials.lowercaseString containsString:_searchString];
        
        if (matchCamelCase1 && matchCamelCase2) {
            return NSOrderedSame;
        }
        else if (matchCamelCase2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedAscending;
    }];
    return sorted;
}

- (NSArray *)resultsSortedByFrameworksMatches:(NSArray *)results {
    MHHeaderCache *cache = [MHHeaderCache sharedCache];
    
    NSArray *sorted = [results sortedArrayUsingComparator:^NSComparisonResult(id <MHSourceFile> _Nonnull obj1, id <MHSourceFile> _Nonnull obj2) {
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
    return sorted;
}

- (void) notifyWithResults:(NSArray *)results {
    if (!self.isCancelled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchResultsBlock(results);
        });
    }
}

@end
