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

@end

@implementation MHImportListView
{
    NSMutableString *_currentString;
    NSMutableArray *_filteredImports;
}

- (void)awakeFromNib {
    _currentString = [NSMutableString new];
    _filteredImports = [NSMutableArray new];
}

- (void)resetCurrentString {
    [_currentString setString:@""];
}

#pragma mark - Setters

- (void) setImports:(NSArray *)headers {
    _imports = headers;
    [_filteredImports setArray:headers];
    [_tableView reloadData];
    [self resetCurrentString];
}

#pragma mark - NSTableViewDataSource

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(_filteredImports.count > 0) {
        NSString *header = [_filteredImports[row] value];
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
    return _filteredImports.count > 0 ? _filteredImports.count : 1;
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
            _filteredImports.count > 0) {
            [_delegate importList:self
                  didSelectImport:_filteredImports[selectedRow]];
        }
    }
}

- (void) updateData {
    NSArray *filteredImports = [self importsForCurrentString];
    if (_currentString.length > 0 ) {
        if (![filteredImports isEqual:_filteredImports]) {
            [_filteredImports setArray:filteredImports];
            [self selectRow:0];
        }
    }
    else {
        [self setImports:_imports];
    }
    [self.tableView reloadData];
}

- (void) selectRow:(NSInteger) row {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:row];
}

- (NSArray*)importsForCurrentString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.value CONTAINS[cd] %@", _currentString];
    return [_imports filteredArrayUsingPredicate:predicate];
}

@end
