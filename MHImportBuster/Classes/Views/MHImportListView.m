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
#import "MHSearchArrayOperation.h"

@interface MHImportListView ()
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;
@end

@implementation MHImportListView
{
    NSMutableString *_currentString;
    NSMutableArray *_filteredImports;
    NSOperationQueue *_searchOperationQueue;
    MHSearchArrayOperation *_currentSearchOperation;
}

- (void)awakeFromNib {
    _currentString = [NSMutableString new];
    _filteredImports = [NSMutableArray new];
    
    _searchOperationQueue = [NSOperationQueue new];
    
    [self.tableView setDoubleAction:@selector(onDoubleClick:)];
}

- (void)resetCurrentString {
    [_currentString setString:@""];
}

- (void)startLoading {
    [self.activityIndicator startAnimation:self];
}

- (void)stopLoading {
    [self.activityIndicator stopAnimation:self];
}

#pragma mark - Setters

- (void) setImports:(NSArray *)headers {
    _imports = headers;
    [_filteredImports setArray:headers];
    [_tableView reloadData];
    [self resetCurrentString];
}

#pragma mark - NSTableViewDataSource

- (void)onDoubleClick:(NSTableView *)sender {
    [self onSelectedRow:sender.clickedRow];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if(_filteredImports.count > 0) {
        NSString *header =  [self.delegate importList:self formattedImport:_filteredImports[row]];

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
        [self updateData:NO];
    }
    else if (key.keyCode == kVK_Delete) {
        NSUInteger length = _currentString.length;
        if (length > 0) {
            [_currentString setString:[_currentString substringToIndex:length-1]];
        }
        [self updateData:YES];
    }
    else if (key.keyCode == kVK_Escape) {
        [self.delegate importListDidDismiss:self];
    }
    else if (key.keyCode == kVK_Return) {
        [self onSelectedRow:selectedRow];
    }
}

- (void)onSelectedRow:(NSInteger) selectedRow {
    if (selectedRow != -1 &&
        _filteredImports.count > 0) {
        [self.delegate importList:self
                  didSelectImport:_filteredImports[selectedRow]];
    }

}

- (void) updateData:(BOOL) useCompleteDataSet {
    NSArray *searchArray = useCompleteDataSet ? _imports : _filteredImports;
    if (_currentString.length > 0 ) {
        
        MHArrayBlock resultsBlock = ^(NSArray *filteredImports) {
            [_filteredImports setArray:filteredImports];
            [self selectRow:0];
            [self.tableView reloadData];
        };
        
        [_currentSearchOperation cancel];
        _currentSearchOperation = [MHSearchArrayOperation operationWithSearchArray:searchArray
                                                                      searchString:_currentString
                                                                searchResultsBlock:resultsBlock];
        [_searchOperationQueue addOperation:_currentSearchOperation];
    }
    else {
        [self setImports:searchArray];
        [self.tableView reloadData];
    }
}

- (void) selectRow:(NSInteger) row {
    [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
                byExtendingSelection:NO];
    [self.tableView scrollRowToVisible:row];
}

- (NSArray*)importsForCurrentString {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[cd] %@", _currentString];
    return [_imports filteredArrayUsingPredicate:predicate];
}

@end
