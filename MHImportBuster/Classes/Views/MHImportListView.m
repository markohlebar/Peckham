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
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
}

#pragma mark - NSTableViewDataSource

- (void)onDoubleClick:(NSTableView *)sender {
    [self onSelectedRow:sender.clickedRow];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *currentString = [self.dataSource searchStringForImportList:self];

    if (self.numberOfRows > 0) {
        NSString *header =  [self.dataSource importList:self stringForRow:row];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:header];
        
        // invert black->white for selected row
        if (tableView.selectedRow == row) {
            [string addAttributes:[self whiteForegroundTextAttribute] range:NSMakeRange(0, header.length)];
        }

        // highlight matched substring
        if (currentString.length > 0) {
            NSRange range = [header rangeOfString:currentString options:NSCaseInsensitiveSearch];
            [string addAttributes:[self highlightedTextAttribute] range:range];
        }

        return string;
    }
    else {
        if (currentString > 0) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:currentString];
            NSRange range = NSMakeRange(0, currentString.length);
            
            [string addAttributes:[self redForegroundTextAttribute] range:range];

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
    else if ([self isValidKeyForSearching:key]) {
        currentString = [currentString stringByAppendingString:key.characters];
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
    if (selectedRow != -1 && self.numberOfRows > 0) {
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


#pragma mark - MHImportListView table text styles

- (NSDictionary *)whiteForegroundTextAttribute {
    return @{NSForegroundColorAttributeName: [NSColor whiteColor]};
}

- (NSDictionary *)redForegroundTextAttribute {
    NSColor *salmonRed = [NSColor colorWithRed:255/255.f green:120/255.f blue:120/255.f alpha:1.0f];
    return @{NSForegroundColorAttributeName: salmonRed,
             NSStrokeColorAttributeName: salmonRed,
             NSStrokeWidthAttributeName: @(-2.5)};
}

- (NSDictionary *)highlightedTextAttribute {
    return @{NSForegroundColorAttributeName: [NSColor blackColor],
             NSBackgroundColorAttributeName: [NSColor colorWithRed:235/255.f green:222/255.f blue:184/255.f alpha:1.0f],
             NSStrokeWidthAttributeName: @(-1)};
}

#pragma mark - Keystroke helpers

- (BOOL)isValidKeyForSearching:(NSEvent *)key {
    return [key.characters mh_isAlphaNumeric] ||
           key.keyCode == kVK_ANSI_Period ||
           (key.modifierFlags & NSShiftKeyMask && key.keyCode == kVK_ANSI_Equal) ||
           (key.modifierFlags & NSShiftKeyMask && key.keyCode == kVK_ANSI_Minus);
}

@end
