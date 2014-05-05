//
//  MHImportListView.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportListView.h"

@interface MHImportListView ()
@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation MHImportListView
#pragma mark - Setters
- (void) setHeaders:(NSArray *)headers {
    _headers = headers;
    [_tableView reloadData];
}

#pragma mark - NSTableViewDataSource
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [_headers[row] lastPathComponent];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return _headers.count;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20.0;
}

- (void) tableViewDidReturn:(MHTableView *)tableView {
    NSInteger selectedRow = [_tableView selectedRow];
    [_delegate importList:self
          didSelectHeader:_headers[selectedRow]];
}

@end
