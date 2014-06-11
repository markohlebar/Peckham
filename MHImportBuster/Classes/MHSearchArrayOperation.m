//
//  MHSearchArrayOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/06/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHSearchArrayOperation.h"
#import "NSString+Extensions.h"

const NSUInteger MHSearchArrayOperationProgression = 2;

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
    __block NSUInteger resultTarget = MHSearchArrayOperationProgression;
    __block NSMutableArray *results = NSMutableArray.new;
    NSString *searchString = self.searchString;
    [_searchArray enumerateObjectsUsingBlock:^(NSString *string, NSUInteger idx, BOOL *stop) {
        if (self.isCancelled) {
            *stop = YES;
            return;
        }
        
        if ([string rangeOfString:searchString options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [results addObject:string];
        }
        
        if (results.count >= resultTarget) {
            [self notifyWithResults:results];
            resultTarget *= MHSearchArrayOperationProgression;
        }
    }];
    
    [self notifyWithResults:results];
}

- (void) notifyWithResults:(NSArray *)results {
    if (!self.isCancelled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searchResultsBlock(results);
        });
    }
}

@end
