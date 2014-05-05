//
//  MHImportListView.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHTableView.h"

@class MHImportListView;
@protocol MHImportListViewDelegate <NSObject>
@required
-(void) importList:(MHImportListView *)importList didSelectHeader:(NSString *)headerPath;

@end

@interface MHImportListView : NSView <MHTableViewDelegate, NSTableViewDataSource>
@property (nonatomic, strong) NSArray *headers;
@property (nonatomic, weak) id <MHImportListViewDelegate> delegate;

+ (instancetype)presentInPopover;
- (void) dismiss;
@end
