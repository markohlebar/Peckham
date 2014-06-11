//
//  MHSearchArrayOperation.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/06/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHOperation.h"

@interface MHSearchArrayOperation : MHOperation
@property (nonatomic, copy, readonly) NSArray *searchArray;
@property (nonatomic, copy, readonly) NSString *searchString;
@property (nonatomic, copy, readonly) MHArrayBlock searchResultsBlock;

+ (instancetype) operationWithSearchArray:(NSArray *) searchArray
                             searchString:(NSString *) searchString
                       searchResultsBlock:(MHArrayBlock) searchResultsBlock;
@end
