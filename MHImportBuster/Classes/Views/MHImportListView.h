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
@class XCSourceFile;
@protocol MHImportListViewDelegate <NSObject>
@required
- (void)importList:(MHImportListView *)importList didSelectImport:(XCSourceFile *)import;
- (NSString *)importList:(MHImportListView *)importList formattedImport:(XCSourceFile *)import;
- (void)importListDidDismiss:(MHImportListView *)importList;
@end

@interface MHImportListView : NSView <MHTableViewDelegate, NSTableViewDataSource>
@property (nonatomic, strong) NSArray *imports;
@property (nonatomic, weak) id <MHImportListViewDelegate> delegate;

- (void)startLoading;
- (void)stopLoading;
@end
