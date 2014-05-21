//
//  XCTarget+XCProject.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

static NSString *const XCFrameworkExtension = @".framework";

#import "XCTarget+XCProject.h"

@implementation XCTarget (XCProject)
- (XCProject *)project {
    return _project;
}

- (NSArray *)frameworks {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@", XCFrameworkExtension];
    return [self.members filteredArrayUsingPredicate:predicate];
}

@end
