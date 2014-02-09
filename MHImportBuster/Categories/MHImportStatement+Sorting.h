//
//  MHImportStatement+Sorting.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportStatement.h"

@interface MHImportStatement (Sorting)
-(NSComparisonResult) compare:(MHImportStatement*) other;
@end
