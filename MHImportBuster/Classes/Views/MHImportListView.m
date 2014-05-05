//
//  MHImportListView.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportListView.h"
#import <XcodeEditor/XcodeEditor.h>
#import <Carbon/Carbon.h>
#import "NSString+Extensions.h"

@interface MHImportListView ()
@property (weak) IBOutlet NSTableView *tableView;

@end

@implementation MHImportListView
{
    NSMutableString *_currentString;
    NSMutableArray *_filteredHeaders;
}

- (void)awakeFromNib {
    _currentString = [NSMutableString new];
    _filteredHeaders = [NSMutableArray new];
}

- (void)resetCurrentString {
    [_currentString setString:@""];
}

#pragma mark - Setters

- (void) setHeaders:(NSArray *)headers {
    _headers = headers;
    [_filteredHeaders setArray:headers];
    [_tableView reloadData];
    [self resetCurrentString];
}

#pragma mark - NSTableViewDataSource

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(_filteredHeaders.count > 0) {
        NSString *header = [_filteredHeaders[row] lastPathComponent];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:header];
        if (_currentString.length > 0) {
            NSRange range = [header rangeOfString:_currentString options:NSCaseInsensitiveSearch];
            [string addAttribute:NSForegroundColorAttributeName
                           value:[NSColor redColor]
                           range:range];
        }
        return string;
    }
    else {
        if (_currentString > 0) {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:_currentString];
            NSRange range = NSMakeRange(0, _currentString.length);
            [string addAttribute:NSForegroundColorAttributeName
                           value:[NSColor redColor]
                           range:range];
            return string;
        }
    }
    return nil;
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    return _filteredHeaders.count > 0 ? _filteredHeaders.count : 1;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 20.0;
}

#pragma mark - MHTableViewDelegate

- (void)tableView:(MHTableView *)tableView onKeyPress:(NSEvent *)key {
    NSString *characters = key.characters;
    NSInteger selectedRow = [self.tableView selectedRow];
    if ([characters isAlphaNumeric] ||
        key.keyCode == kVK_ANSI_Period) {
        [_currentString appendString:characters];
        [self updateData];
    }
    else if (key.keyCode == kVK_Delete) {
        NSUInteger length = _currentString.length;
        if (length > 0) {
            [_currentString setString:[_currentString substringToIndex:length-1]];
        }
        [self updateData];
    }
    else if (key.keyCode == kVK_Return) {
        if (selectedRow != -1 &&
            _filteredHeaders.count > 0) {
            [_delegate importList:self
                  didSelectHeader:_filteredHeaders[selectedRow]];
        }
    }
}

- (void) updateData {
    NSArray *filteredHeaders = [self headersForCurrentString];
    if (_currentString.length > 0 ) {
        if (![filteredHeaders isEqual:_filteredHeaders]) {
            [_filteredHeaders setArray:filteredHeaders];
            [self selectRow:0];
        }
    }
    else {
        [self setHeaders:_headers];
    }
    [self.tableView reloadData];
}

- (void) selectRow:(NSInteger) row {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                byExtendingSelection:NO];
}

- (NSArray*)headersForCurrentString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.lastPathComponent CONTAINS[cd] %@", _currentString];
    return [_headers filteredArrayUsingPredicate:predicate];
}

@end
