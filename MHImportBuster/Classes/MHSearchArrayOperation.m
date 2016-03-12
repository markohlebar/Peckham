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
    if (self.isCancelled) return;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"lastPathComponent CONTAINS[cd] %@", self.searchString];
    NSArray *results = [self.searchArray filteredArrayUsingPredicate:predicate];
    [self notifyWithResults:results];
}

- (void) notifyWithResults:(NSArray *)results {
    if (!self.isCancelled) {
        MHLog(@"TRAVISCI executing notifyWithResults");
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchResultsBlock(results);
        });
    } else {
        MHLog(@"TRAVISCI notifyWithResults was cancelled");
    }
}

@end
