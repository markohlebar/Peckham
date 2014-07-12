//
//  MHImportListViewController.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 05/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHHeaderCache;
@class MHSourceFileSearchController;
@interface MHImportListViewController : NSObject
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, strong) MHSourceFileSearchController *searchController;
@property (nonatomic, strong) MHHeaderCache *headerCache;

+ (instancetype)sharedInstance;
+ (instancetype)presentInView:(NSView *)view;
+ (instancetype)present;
- (void)dismiss;
@end
