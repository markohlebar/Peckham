//
//  MHCreateSearchDictionaryOperation.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 03/05/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import "MHOperation.h"

@interface MHCreateSearchDictionaryOperation : MHOperation

+ (instancetype) operationWithSearchArray:(NSArray *) searchArray
                    searchDictionaryBlock:(MHDictionaryBlock) searchDictionaryBlock;
@end
