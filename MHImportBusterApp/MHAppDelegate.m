//
//  MHAppDelegate.m
//  MHImportBusterApp
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHAppDelegate.h"
#import <MHImportBuster/MHImportBuster.h>

@interface MHAppDelegate () <NSPopoverDelegate>
@property (nonatomic, strong) NSPopover *popover;
@end

@implementation MHAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)onInfo:(id)sender {
    NSWindow *keyWindow = [[NSApplication sharedApplication] keyWindow];
    MHImportListViewController *controller = [MHImportListViewController presentInView:keyWindow.contentView];
    controller.headers = @[@"AHeader.h", @"BHeader.h", @"AAHeader.h", @"CHeader.h"];
    
}
@end
