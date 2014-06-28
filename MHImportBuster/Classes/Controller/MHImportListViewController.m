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

@interface MHImportListViewController () <NSPopoverDelegate, MHImportListViewDelegate>
@property (nonatomic, strong) NSPopover *popover;
@end

@implementation MHImportListViewController
{
 
}

+ (instancetype)sharedInstance {
    static MHImportListViewController *_viewController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _viewController = [[self alloc] init];
    });
    return _viewController;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadImportListView];
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
}

- (void)showImportListViewInTextView:(NSTextView *) textView {
    NSRect frame = [textView mhFrameForCaret];
    [self showImportListViewInView:textView frame:frame];
}

- (void)showImportListViewInView:(NSView *) view frame:(NSRect)frame {
    [self.popover showRelativeToRect:frame
                              ofView:view
                       preferredEdge:NSMinYEdge];
    
    [[MHHeaderCache sharedCache] loadHeaders:^(NSArray *headers) {
        self.headers = headers;
    }];
}

- (void)setHeaders:(NSArray *)headers {
    _headers = headers;
    
    MHImportListView *listView = (MHImportListView *)self.popover.contentViewController.view;
    listView.imports = headers;
    listView.delegate = self;
}

+ (instancetype)present {
    NSTextView *currentTextView = [MHXcodeDocumentNavigator currentSourceCodeTextView];
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

- (MHImportStatement *)importStatementForImport:(NSString *)import {
    if ([[MHHeaderCache sharedCache] isProjectHeader:import]) {
        return [MHImportStatement statementWithHeaderPath:import];
    }
    else {
        return [MHImportStatement statementWithFrameworkHeaderPath:import];
    }
}

- (void)importList:(MHImportListView *)importList didSelectImport:(NSString *)import {
    [self addImport:[self importStatementForImport:import]];
    [self dismiss];
}

- (NSString *)importList:(MHImportListView *)importList formattedImport:(NSString *)import {
    NSString *formattedImport = [self importStatementForImport:import].value;
    return formattedImport ? formattedImport : import;
}

- (void)importListDidDismiss:(MHImportListView *)importList {
    [self dismiss];
}

@end
