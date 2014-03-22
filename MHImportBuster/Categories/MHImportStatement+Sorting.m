//
//  MHImportStatement+Sorting.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportStatement+Sorting.h"
#import "PKToken+Factory.h"

@implementation MHImportStatement (Sorting)

-(NSComparisonResult) compare:(MHImportStatement*) other {
    //1. Framework statements have higher precedence than project statements
    BOOL isSelfFrameworkImport = [self isKindOfClass:[MHFrameworkImportStatement class]];
    BOOL isOtherFrameworkImport = [other isKindOfClass:[MHFrameworkImportStatement class]];
    
    BOOL areImportsOfSameClass = isSelfFrameworkImport == isOtherFrameworkImport;
    if(areImportsOfSameClass) {
        //compare strings
        return [self.value compare:other.value];
    }
    else {
        return isSelfFrameworkImport ? NSOrderedAscending : NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

-(BOOL) hasSubpath {
    return [_tokens containsObject:[PKToken forwardSlash]];
}

@end
