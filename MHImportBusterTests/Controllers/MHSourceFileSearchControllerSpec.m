//
//  MHSourceFileSearchControllerSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/07/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHSourceFileSearchController.h"
#import "MHConcreteSourceFile.h"


SPEC_BEGIN(MHSourceFileSearchControllerSpec)

describe(@"MHSourceFileSearchController", ^{
    
    __block MHSourceFileSearchController *searchController = nil;
    
    NSArray *sourceFiles = @[
                             [MHConcreteSourceFile sourceFileWithName:@"ABImport.h"],
                             [MHConcreteSourceFile sourceFileWithName:@"ABImportA.h"],
                             [MHConcreteSourceFile sourceFileWithName:@"ABImportExportA.h"],
                             [MHConcreteSourceFile sourceFileWithName:@"ABImportB.h"],
                             [MHConcreteSourceFile sourceFileWithName:@"ABExportA.h"]
                             ];
    
    beforeEach(^{
        searchController = [MHSourceFileSearchController searchControllerWithSourceFiles:sourceFiles];
    });
    
    specify(^{
        [[searchController shouldNot] beNil];
        [[searchController.sourceFiles should] equal:sourceFiles];
        [[searchController.filteredSourceFiles should] equal:sourceFiles];
    });
    
    it(@"takes a string and eventually returns an array of search results", ^{
        __block NSArray *searchArray = nil;
        [searchController search:@"export"
                     searchBlock:^(NSArray *array) {
                         searchArray = array;
                     }];
        
        [[expectFutureValue(searchArray) shouldEventually] haveCountOf:2];
    });
    
    it(@"takes 2 subsequent strings with second string containing the first", ^{
        __block NSArray *searchArray = nil;
        [searchController search:@"import"
                     searchBlock:^(NSArray *array) {
                         searchArray = array;
                     }];
        
        [searchController search:@"importB"
                     searchBlock:^(NSArray *array) {
                         searchArray = array;
                     }];
        
        [[expectFutureValue(searchArray) shouldEventually] haveCountOf:1];
        [[expectFutureValue([[searchArray firstObject] name]) shouldEventually] equal:@"ABImportB.h"];
    });
    
    it(@"takes 2 subsequent string with second string not containing the first", ^{
        __block NSArray *searchArray = nil;
        [searchController search:@"importB"
                     searchBlock:^(NSArray *array) {
                         searchArray = array;
                     }];
        
        [searchController search:@"import"
                     searchBlock:^(NSArray *array) {
                         searchArray = array;
                     }];
        
        [searchController search:@"importA"
                     searchBlock:^(NSArray *array) {
                         searchArray = array;
                     }];
        
        [[expectFutureValue(searchArray) shouldEventually] haveCountOf:1];
        [[expectFutureValue([[searchArray firstObject] name]) shouldEventually] equal:@"ABImportA.h"];
    });
    
    xit(@"will return a whole array if search string is empty string", ^{
        __block NSArray *searchArray = nil;
        [searchController search:@"importB"
                     searchBlock:^(NSArray *array) {
                         searchArray = array;
                     }];
        
        [searchController search:@""
                     searchBlock:^(NSArray *array) {
                         searchArray = array;
                     }];
        [[expectFutureValue(searchArray) shouldEventually] equal:sourceFiles];
    });

	it(@"resets the search contents", ^{
		__block NSArray *searchArray = nil;
		[searchController search:@"importB"
				   searchBlock:^(NSArray *array) {
					   searchArray = array;
				   }];

		[searchController reset];

		[[searchController.searchString should] equal:@""];
		[[searchController.filteredSourceFiles should] equal:sourceFiles];
		[[expectFutureValue(searchArray) shouldEventuallyBeforeTimingOutAfter(60 * 2)] beNil];

	});
});

SPEC_END
