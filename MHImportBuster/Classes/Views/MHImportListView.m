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
    if(self.numberOfRows > 0) {
        NSString *header =  [self.dataSource importList:self stringForRow:row];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:header];
        if (currentString.length > 0) {
            NSRange range = [header rangeOfString:currentString options:NSCaseInsensitiveSearch];
            [string addAttribute:NSForegroundColorAttributeName
                           value:[NSColor redColor]
                           range:range];
        }
        return string;
    }
    else {
        if (currentString > 0) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:currentString];
            NSRange range = NSMakeRange(0, currentString.length);
            [string addAttribute:NSForegroundColorAttributeName
                           value:[NSColor redColor]
                           range:range];
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
    
    if (key.modifierFlags & NSControlKeyMask) {
        if ([key.charactersIgnoringModifiers isEqualToString:@"n"]) {
            // equivalent to down arrow
            selectedRow += 1;
            if (selectedRow == self.numberOfRows) {
                selectedRow = 0;
            }
            [self selectRow:selectedRow];
        }
        else if ([key.charactersIgnoringModifiers isEqualToString:@"p"]) {
            // equivalent to up arrow
            selectedRow -= 1;
            if (selectedRow < 0) {
                selectedRow = self.numberOfRows-1;
            }
            [self selectRow:selectedRow];
        }
        else if ([key.charactersIgnoringModifiers isEqualToString:@"h"]) {
            // equivalent to delete key
            NSUInteger length = currentString.length;
            if (length > 0) {
                currentString = [currentString substringToIndex:length-1];
            }
            [self performSearch:currentString];
        }
        else if ([key.charactersIgnoringModifiers isEqualToString:@"["]) {
            // equivalent to esc key
            [self.delegate importListDidDismiss:self];
        }
    }
    else if ([characters mh_isAlphaNumeric] || key.keyCode == kVK_ANSI_Period) {
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
