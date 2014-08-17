//
//  MHImportListView.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportListView.h"
#import <Carbon/Carbon.h>
#import "NSString+Extensions.h"

@interface MHImportListView ()
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;
@end

@implementation MHImportListView

- (void)awakeFromNib {
    [self.tableView setDoubleAction:@selector(onDoubleClick:)];
}

- (void)startLoading {
    [self.activityIndicator startAnimation:self];
}

- (void)stopLoading {
    [self.activityIndicator stopAnimation:self];
}

#pragma mark - Setters

- (void)setNumberOfRows:(NSUInteger)numberOfRows {
    _numberOfRows = numberOfRows;
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (void)onDoubleClick:(NSTableView *)sender {
    [self onSelectedRow:sender.clickedRow];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *currentString = [self.dataSource searchStringForImportList:self];
  
    NSDictionary *whiteForegroundTextAttribute = @{NSForegroundColorAttributeName: [NSColor whiteColor]};
    NSDictionary *redForegroundTextAttribute   = @{NSForegroundColorAttributeName: [NSColor colorWithRed:218/255.f green:48/255.f blue:55/255.f alpha:1.0f]};
    NSDictionary *highlightedTextAttribute     = @{NSForegroundColorAttributeName: [NSColor blackColor],
                                                   NSBackgroundColorAttributeName: [NSColor colorWithRed:235/255.f green:222/255.f blue:184/255.f alpha:1.0f],
                                                   NSStrokeWidthAttributeName: @(-1)};
  
    if (self.numberOfRows > 0) {
        NSString *header =  [self.dataSource importList:self stringForRow:row];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:header];
        
        // invert black->white for selected row
        if (tableView.selectedRow == row) {
            [string addAttributes:whiteForegroundTextAttribute range:NSMakeRange(0, header.length)];
        }

        // highlight matched substring
        if (currentString.length > 0) {
            NSRange range = [header rangeOfString:currentString options:NSCaseInsensitiveSearch];
            [string addAttributes:highlightedTextAttribute range:range];
        }

        return string;
    }
    else {
        if (currentString > 0) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:currentString];
            NSRange range = NSMakeRange(0, currentString.length);
            
            [string addAttributes:redForegroundTextAttribute range:range];

            return string;
        }
    }
    return nil;
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return self.numberOfRows > 0 ? self.numberOfRows : 1;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20.0;
}

#pragma mark - MHTableViewDelegate

- (void)tableView:(MHTableView *)tableView onKeyPress:(NSEvent *)key {
    NSString *currentString = [self.dataSource searchStringForImportList:self];

    NSString *characters = key.characters;
    NSInteger selectedRow = [self.tableView selectedRow];
    if ([characters mh_isAlphaNumeric] ||
        key.keyCode == kVK_ANSI_Period) {
        currentString = [currentString stringByAppendingString:characters];
        [self performSearch:currentString];
    }
    else if (key.keyCode == kVK_Delete) {
        NSUInteger length = currentString.length;
        if (length > 0) {
            currentString = [currentString substringToIndex:length-1];
        }
        [self performSearch:currentString];
    }
    else if (key.keyCode == kVK_Escape) {
        [self.delegate importListDidDismiss:self];
    }
    else if (key.keyCode == kVK_Return) {
        [self onSelectedRow:selectedRow];
    }
}

- (void)onSelectedRow:(NSInteger) selectedRow {
    if (selectedRow != -1) {
        [self.delegate importList:self didSelectRow:selectedRow];
    }
}

- (void)performSearch:(NSString *)searchString {
    [self.dataSource importList:self performSearch:searchString];
}

- (void) selectRow:(NSInteger) row {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:row];
}

@end
