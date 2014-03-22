//
//  MHXcodeCoalescedIssuesParser.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 20/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#define kMHXCodeCoalescedIssuesKey          @"IDEIssueManagerCoalescedIssuesKey"
#define kMHXCodeExistingIssuesKey           @"IDEIssueManagerExistingIssuesKey"

#import <Foundation/Foundation.h>

@interface MHXcodeIssuesParser : NSObject

/**
 *  Parses the Xcode issues dictionary
 *
 *  @param issuesDictionary Xcode issues dictionary
 *
 *  @return an array of IDEIssue objects
 */
+(NSArray *) parseDictionary:(NSDictionary *) issuesDictionary;
@end
