//
//  MHXcodeCoalescedIssuesParser.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 20/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHXcodeIssuesParser.h"
#import "XCFXcodePrivate.h"
//#import "NSObject+MHLogMethods.h"

@implementation MHXcodeIssuesParser

+(NSArray *) parseDictionary:(NSDictionary *) issuesDictionary {
    NSMutableArray *allIssues = [NSMutableArray array];
    NSArray *existingIssues = issuesDictionary[kMHXCodeExistingIssuesKey];
    [allIssues addObjectsFromArray:existingIssues];

    for (IDEIssue *issue in existingIssues) {
        NSLog(@"########### Issue %@ ############", NSStringFromClass(issue.class));
        NSLog(@"Message :%@", issue.fullMessage);
        NSLog(@"Severity :%ld", issue.severity);
        NSLog(@"Issue Type ID :%@", issue.issueTypeIdentifier);
//        NSLog(@"Fixable Items: %@", [issue performSelector:@selector(fixableDiagnosticItems)]);
//        NSLog(@"originatingMessage: %@", [issue performSelector:@selector(originatingMessage)]);
//
//        
//        NSArray *documentLocations = issue.documentLocations;
//        for (DVTTextDocumentLocation *location in documentLocations) {
////            [location mhLogMethods];
//        }
//        
//        
//        NSLog(@"\n\n");
    }


    NSArray *coalescedIssues = issuesDictionary[kMHXCodeCoalescedIssuesKey];
    [allIssues addObjectsFromArray:coalescedIssues];
    return allIssues.copy;
}

@end
