//
//  NSTextView+Operations.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 05/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextView (Operations)
/**
 *  Returns frame for caret in text view.
 *
 *  @return a frame
 */
- (NSRect) mhFrameForCaret;
@end
