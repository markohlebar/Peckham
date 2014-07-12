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
- (void)importList:(MHImportListView *)importList didSelectRow:(NSUInteger)row;
- (void)importListDidDismiss:(MHImportListView *)importList;
@end

@protocol MHImportListViewDataSource <NSObject>
@required
- (void)importList:(MHImportListView *)importList
     performSearch:(NSString *)searchString;
- (NSString *)searchStringForImportList:(MHImportListView *)importList;
- (NSString *)importList:(MHImportListView *)importList stringForRow:(NSUInteger)row;
@end

@interface MHImportListView : NSView <MHTableViewDelegate, NSTableViewDataSource>
@property (nonatomic, readwrite) NSUInteger numberOfRows;
@property (nonatomic, weak) id <MHImportListViewDelegate> delegate;
@property (nonatomic, weak) id <MHImportListViewDataSource> dataSource;

- (void)startLoading;
- (void)stopLoading;
@end
