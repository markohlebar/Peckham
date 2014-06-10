//
//  MyClass.m
//  MHImportBuster
//
//  Created by marko.hlebar on 25/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//


static NSString *const MHHeaderCacheSystemFrameworksPath = @"/System/Library/Frameworks/";

#import "MyClass.h"


@implementation MyClass

#pragma mark - MyClass

+ (MHFrameworkImportStatement *)statementWithFrameworkHeaderPath:(NSString *)headerPath {
    
    NSArray *pathComponents = [headerPath pathComponents];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", @".framework"];
    NSString *framework = [[pathComponents filteredArrayUsingPredicate:predicate] firstObject];
    NSString *frameworkName = [framework stringByDeletingPathExtension];
    NSString *header = [pathComponents lastObject];
    
    if (frameworkName && [header is]) {
        NSString *statementString = [NSString stringWithFormat:@"#import <%@/%@>", frameworkName, header];
        return [MHFrameworkImportStatement statementWithString:statementString];
    }
    
    return nil;
}

@end
