//
//  MHXcodeIssuesParserSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHXcodeIssuesParser.h"

SPEC_BEGIN(MHXcodeIssuesParserSpec)

describe(@"MHXcodeIssuesParser", ^{
    it(@"Given a dictionary with 3 issues it should return 3 issues", ^{
        NSArray *issues = [MHXcodeIssuesParser parseDictionary:@{
                                                                 kMHXCodeCoalescedIssuesKey : @[
                                                                         [NSObject nullMock],
                                                                         [NSObject nullMock]
                                                                         ],
                                                                 kMHXCodeExistingIssuesKey : @[
                                                                         [NSObject nullMock]
                                                                         ],
                                                                 }];
        [[issues should] haveCountOf:3];
    });
    
    it(@"Given a dictionary with 4 issues it should return 4 issues", ^{
        NSArray *issues = [MHXcodeIssuesParser parseDictionary:@{
                                                                 kMHXCodeCoalescedIssuesKey : @[
                                                                         [NSObject nullMock],
                                                                         [NSObject nullMock]
                                                                         ],
                                                                 kMHXCodeExistingIssuesKey : @[
                                                                         [NSObject nullMock],
                                                                         [NSObject nullMock]
                                                                         ],
                                                                 }];
        [[issues should] haveCountOf:4];
    });
});

SPEC_END
