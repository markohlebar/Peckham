//
//  MHAppDelegate.m
//  MHImportBusterApp
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHAppDelegate.h"
//#import <MHImportBuster/MHImportBuster.h>
#import "MHImportListView.h"

@interface MHAppDelegate () <NSPopoverDelegate>
@property (nonatomic, strong) NSPopover *popover;
@end

@implementation MHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)instantiatePopover
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSViewController *contentViewController = [[NSViewController alloc] initWithNibName:@"MHImportListView" bundle:bundle];
    
    NSPopover *popover = [[NSPopover alloc] init];
    popover.delegate = self;
    popover.behavior = NSPopoverBehaviorTransient;
    popover.appearance = NSPopoverAppearanceMinimal;
    popover.animates = NO;
    popover.contentViewController = contentViewController;
    self.popover = popover;
    
    MHImportListView *listView = (MHImportListView *)self.popover.contentViewController.view;
    listView.headers = @[@"Aheader.h", @"BHeader.h", @"AAHeader.h"];
    
    NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
    [self.popover showRelativeToRect:keyWindow.frame
                              ofView:keyWindow.contentView
                       preferredEdge:NSMinYEdge];
}

- (IBAction)onInfo:(id)sender {
    [self instantiatePopover];
}
@end
