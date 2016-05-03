//
//  MHCreateSearchDictionaryOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 03/05/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import "MHCreateSearchDictionaryOperation.h"
#import "MHSourceFile.h"
#import "NSString+CamelCase.h"

@interface MHCreateSearchDictionaryOperation ()
@property (nonatomic, copy) NSArray *searchArray;
@property (nonatomic, copy) MHDictionaryBlock searchDictionaryBlock;
@end

@implementation MHCreateSearchDictionaryOperation

+ (instancetype) operationWithSearchArray:(NSArray *) searchArray
                    searchDictionaryBlock:(MHDictionaryBlock) searchDictionaryBlock {
    return [[self alloc] initWithSearchArray:searchArray
                       searchDictionaryBlock:searchDictionaryBlock];
}

- (instancetype)initWithSearchArray:(NSArray *)searchArray
              searchDictionaryBlock:(MHDictionaryBlock)searchDictionaryBlock {
    self = [super init];
    if (self) {
        _searchArray = searchArray.copy;
        _searchDictionaryBlock = [searchDictionaryBlock copy];
    }
    return self;
}

- (void)execute {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    for (id <MHSourceFile> source in self.searchArray) {
        NSString *fileName = source.lastPathComponent;
        NSString *fileNameWithNoExtension = [fileName stringByDeletingPathExtension];
        NSArray *components = fileNameWithNoExtension.mh_componentsSeparatedByCamelCase;
        
        for (NSString *component in components) {
            NSMutableArray *lookupArray = dictionary[component];
            
            if(!lookupArray) {
                lookupArray = [NSMutableArray new];
                dictionary[component] = lookupArray;
            }
            
            [lookupArray addObject:source];
        }
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.searchDictionaryBlock(dictionary);
    });
}

@end
