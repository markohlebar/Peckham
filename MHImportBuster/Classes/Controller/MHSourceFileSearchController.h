//
//  MHSourceFileSearchController.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/07/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHSourceFileSearchController : NSObject
@property (nonatomic, copy, readonly) NSArray *sourceFiles;

//Contains the files after applying search
@property (nonatomic, readonly) NSArray *filteredSourceFiles;
@property (nonatomic, copy, readonly) NSString *searchString;

+ (instancetype)searchControllerWithSourceFiles:(NSArray *)sourceFiles;

/**
 *  Performs search on the source files and returns results on the main queue
 *
 *  @param searchString  a string to search
 *  @param searchResults search results
 */
- (void)search:(NSString *)searchString
   searchBlock:(MHArrayBlock)searchResults;

/**
 *  Resets the search string to empty and filteredSourceFiles to sourceFiles
 */
- (void)reset;
@end
