//
//  MHImportListViewController.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 05/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHImportListViewController : NSObject
@property (nonatomic, strong) NSArray *headers;
+ (instancetype)presentInView:(NSView *)view;
+ (instancetype)present;
- (void)dismiss;
@end
