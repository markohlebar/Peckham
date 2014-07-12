//
//  MHImportListViewController.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 05/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportListViewController.h"
#import "MHXcodeDocumentNavigator.h"
#import "MHImportListView.h"
#import "MHFile.h"
#import "MHHeaderCache.h"
#import "NSTextView+Operations.h"
#import "MHImportStatement.h"
#import "MHImportStatement+Construction.h"
#import "NSString+Extensions.h"
#import <XcodeEditor/XCSourceFile.h>
#import "MHSourceFile.h"
#import "MHSourceFileSearchController.h"

@interface MHImportListViewController () <NSPopoverDelegate, MHImportListViewDelegate, MHImportListViewDataSource>
@property (nonatomic, strong) NSPopover *popover;
@end

@implementation MHImportListViewController

+ (instancetype)sharedInstance {
    static MHImportListViewController *_viewController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _viewController = [[self alloc] init];
    });
    return _viewController;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadImportListView];
        self.headerCache = [MHHeaderCache sharedCache];
    }
    return self;
}

- (void)loadImportListView {
    NSBundle *bundle = [NSBundle bundleForClass:[MHImportListView class]];
    NSViewController *contentViewController = [[NSViewController alloc] initWithNibName:@"MHImportListView" bundle:bundle];
    
    NSPopover *popover = [[NSPopover alloc] init];
    popover.delegate = self;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.appearance = NSPopoverAppearanceMinimal;
    popover.animates = NO;
    popover.contentViewController = contentViewController;
    self.popover = popover;
    
    self.importListView.delegate = self;
    self.importListView.dataSource = self;
}

- (void)showImportListViewInTextView:(NSTextView *) textView {
    NSRect frame = [textView mhFrameForCaret];
    [self showImportListViewInView:textView frame:frame];
}

- (void)showImportListViewInView:(NSView *) view frame:(NSRect)frame {
    if (!self.popover.isShown) {
        [self.popover showRelativeToRect:frame
                                  ofView:view
                           preferredEdge:NSMinYEdge];
        
        [self startLoading];
        
        [self.searchController reset];
        [self.headerCache loadHeaders:^(NSArray *headers, BOOL doneLoading) {
            self.headers = headers;
            if (doneLoading) {
                [self stopLoading];
            }
        }];
    }
}

- (MHImportListView *)importListView {
    return (MHImportListView *)self.popover.contentViewController.view;
}

- (void)startLoading {
    [self.importListView startLoading];
}

- (void)stopLoading {
    [self.importListView stopLoading];
}

- (void)setHeaders:(NSArray *)headers {
    _headers = headers;
    
    if (![self.searchController.sourceFiles isEqual:headers]) {
        self.searchController = [MHSourceFileSearchController searchControllerWithSourceFiles:headers];
        self.importListView.numberOfRows = headers.count;
    }
    
    [self.searchController reset];
}

+ (instancetype)present {
    NSTextView *currentTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
    if (!currentTextView) return nil;
    return [self presentInView:currentTextView];
}

+ (instancetype)presentInView:(NSView *)view {
    MHImportListViewController *instance = [self sharedInstance];
    if([view isKindOfClass:[NSTextView class]]) {
        [instance showImportListViewInTextView:(NSTextView *)view];
    }
    else {
        [instance showImportListViewInView:view frame:view.frame];
    }
    return instance;
}

- (void)dismiss {
    [self.popover close];
}

#pragma mark MHFile 


- (void) addImport:(MHImportStatement *)statement {
    MHFile *file = [MHFile fileWithCurrentFilePath];
    [file addImport:statement];
}

#pragma mark - MHImportListViewDelegate

- (NSArray *)sourceFiles {
    return self.searchController.filteredSourceFiles;
}

- (MHImportStatement *)importStatementForImport:(id <MHSourceFile>)import {
    if ([[MHHeaderCache sharedCache] isProjectHeader:import]) {
        return [MHImportStatement statementWithHeaderPath:import.name];
    }
    else {
        return [MHImportStatement statementWithFrameworkHeaderPath:import.name];
    }
}

- (void)importList:(MHImportListView *)importList didSelectRow:(NSUInteger)row {
    
    id <MHSourceFile> import = self.sourceFiles[row];
    [self addImport:[self importStatementForImport:import]];
    [self dismiss];
}

- (void)importListDidDismiss:(MHImportListView *)importList {
    [self dismiss];
}

#pragma mark - MHImportListViewDataSource

- (void)importList:(MHImportListView *)importList performSearch:(NSString *)searchString {
    __weak typeof(self) weakSelf = self;
    [self.searchController search:searchString
                      searchBlock:^(NSArray *array) {
                          weakSelf.importListView.numberOfRows = array.count;
                      }];
}

- (NSString *)importList:(MHImportListView *)importList stringForRow:(NSUInteger)row {
    id <MHSourceFile> import = self.sourceFiles[row];
    NSString *formattedImport = [self importStatementForImport:import].value;
    return formattedImport ? formattedImport : import.name;
}

- (NSString *)searchStringForImportList:(MHImportListView *)importList {
    return self.searchController.searchString;
}

#pragma mark - NSPopoverDelegate

- (void)popoverWillClose:(NSNotification *)notification {
    [self.searchController reset];
}

@end
