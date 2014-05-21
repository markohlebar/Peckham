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

@interface MHImportListViewController () <NSPopoverDelegate, MHImportListViewDelegate>
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
    [self setHeaders:[self allHeadersSortedAlphabetically]];
}

- (void)setHeaders:(NSArray *)headers {
    _headers = headers;
    
    MHImportListView *listView = (MHImportListView *)self.popover.contentViewController.view;
    listView.imports = headers;
    listView.delegate = self;
}

- (NSArray *)allHeadersSortedAlphabetically {
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"value" ascending:YES];
    return [[MHHeaderCache allImportStatementsInCurrentWorkspace] sortedArrayUsingDescriptors:@[descriptor]];
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

- (void)importList:(MHImportListView *)importList didSelectImport:(MHImportStatement *)importStatement {
    [self addImport:importStatement];
    [self dismiss];
}

@end
