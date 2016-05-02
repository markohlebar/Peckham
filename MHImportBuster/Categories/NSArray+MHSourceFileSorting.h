//
//  NSArray+MHSourceFileSorting.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 02/05/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MHSourceFileSorting)

- (NSArray *)mh_sortedResultsForSearchString:(NSString *)string;

@end
