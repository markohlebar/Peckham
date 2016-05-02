//
//  NSString+FuzzySearch.h
//  MHImportBuster
//
//  Created by Clément Padovani on 4/29/16.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FuzzySearch)
- (NSString *) mh_fuzzifiedSearchString;
@end
