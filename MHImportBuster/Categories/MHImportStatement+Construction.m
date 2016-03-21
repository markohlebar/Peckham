//
//  MHImportStatement+Construction.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 18/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportStatement+Construction.h"
#import "NSString+Files.h"

@implementation MHImportStatement (Construction)

+ (MHFrameworkImportStatement *)statementWithFrameworkHeaderPath:(NSString *)headerPath {
    if (![headerPath isHeaderFilePath] || [headerPath containsIllegalCharacters]) return nil;
    
    NSArray *pathComponents = [headerPath pathComponents];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", @".framework"];
    NSString *framework = [[pathComponents filteredArrayUsingPredicate:predicate] firstObject];
    NSString *frameworkName = [framework stringByDeletingPathExtension];
    NSString *header = [pathComponents lastObject];
    
    if (frameworkName && header) {
        NSString *statementString = [NSString stringWithFormat:@"#import <%@/%@>", frameworkName, header];
        return [MHFrameworkImportStatement statementWithString:statementString];
    }
    
    return nil;
}

+ (MHProjectImportStatement *)statementWithHeaderPath:(NSString *)headerPath {
    if (![headerPath isHeaderFilePath] || [headerPath containsIllegalCharacters]) return nil;

    NSString *header = [headerPath lastPathComponent];
    NSString *statementString = [NSString stringWithFormat:@"#import \"%@\"", header];
    return [MHProjectImportStatement statementWithString:statementString];
}

@end
