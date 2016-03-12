//
//  MHSourceFileSearchController.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/07/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHSourceFileSearchController.h"
#import "MHSearchArrayOperation.h"
#import "NSString+Extensions.h"
#import "MHSourceFile.h"

@interface MHSourceFileSearchController ()
@property (nonatomic, strong) NSOperationQueue *searchQueue;
@property (nonatomic, strong) NSArray *filteredSourceFiles;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, copy) MHArrayBlock searchBlock;
@end

@implementation MHSourceFileSearchController

+ (instancetype)searchControllerWithSourceFiles:(NSArray *)sourceFiles {
    return [[self alloc] initWithSourceFiles:sourceFiles];
}

- (instancetype)initWithSourceFiles:(NSArray *)sourceFiles {
    self = [super init];
    if (self) {
        _sourceFiles = sourceFiles.copy;
        [self reset];
    }
    return self;
}

- (void)search:(NSString *)searchString
   searchBlock:(MHArrayBlock)searchBlock {

	MHLog(@"TRAVISCI searching for %@", searchBlock);

    self.searchBlock = searchBlock;
    [self.searchQueue cancelAllOperations];
    
    self.filteredSourceFiles = [self searchArrayForSearchString:searchString];
    self.searchString = searchString;
    
    if (![self.searchString mh_isWhitespaceOrNewline]) {

	    MHLog(@"TRAVISCI performing concurrent search");

        [self performConcurrentSearchWithSourceFiles:self.filteredSourceFiles
                                        searchString:self.searchString];
    }
    else {

	    MHLog(@"TRAVISCI else search");

        [self notifySearchResults:self.sourceFiles];
    }
}

- (void)performConcurrentSearchWithSourceFiles:(NSArray *)sourceFiles
                                  searchString:(NSString *)searchString{
    __weak typeof(self) weakSelf = self;
    MHSearchArrayOperation *searchOperation =
    [MHSearchArrayOperation operationWithSearchArray:sourceFiles
                                        searchString:searchString
                                  searchResultsBlock:^(NSArray *results){

							    MHLog(@"TRAVISCI done searching, will notify");

                                      [weakSelf notifySearchResults:results];
                                  }];
    [self.searchQueue addOperation:searchOperation];
}

- (void)reset {

	MHLog(@"TRAVISCI resetting the search controller");

    self.searchString = @"";
    self.filteredSourceFiles = self.sourceFiles;
    [self.searchQueue cancelAllOperations];
}

#pragma mark - Private

- (void)notifySearchResults:(NSArray *)searchResults {
    self.filteredSourceFiles = searchResults;

	MHLog(@"TRAVISCI reaching out to the search block");

    self.searchBlock(self.filteredSourceFiles);
}

- (NSString *)searchString {
    return _searchString ? _searchString : @"";
}

- (NSArray *)searchArrayForSearchString:(NSString *)searchString {
    BOOL shouldUseCompleteDataset = [searchString rangeOfString:self.searchString].location == NSNotFound;
    return shouldUseCompleteDataset ? self.sourceFiles : self.filteredSourceFiles;
}

- (NSOperationQueue *)searchQueue {
    if(!_searchQueue) {
        _searchQueue = [NSOperationQueue new];
        _searchQueue.maxConcurrentOperationCount = 1;
    }
    return _searchQueue;
}

@end
