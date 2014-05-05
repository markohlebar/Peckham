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
    NSLog(@"KEY DOWN");
    if (theEvent.type == NSKeyDown && theEvent.keyCode == kVK_Return) {
        NSLog(@"KEY DOWN ENTER");
        [self.delegate tableViewDidReturn:self];
    }
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    if (theEvent.type == NSKeyDown && theEvent.keyCode == kVK_Return) {
        return YES;
    }
    return [super performKeyEquivalent:theEvent];
}

@end
