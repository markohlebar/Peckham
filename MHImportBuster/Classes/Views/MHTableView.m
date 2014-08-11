//
//  MHTableView.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHTableView.h"
#import <Carbon/Carbon.h>

@implementation MHTableView
@dynamic delegate;

- (void) keyDown:(NSEvent *)theEvent {
    [super keyDown:theEvent];
    if (theEvent.type == NSKeyDown) {
        [self.delegate tableView:self onKeyPress:theEvent];
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    if (theEvent.type == NSKeyDown) {
        if (theEvent.keyCode == kVK_UpArrow ||
            theEvent.keyCode == kVK_DownArrow) {
            return [super performKeyEquivalent:theEvent];
        }
        else if (theEvent.modifierFlags & NSControlKeyMask) {
            return [super performKeyEquivalent:theEvent];
        }
    }
    return YES;
}

@end
