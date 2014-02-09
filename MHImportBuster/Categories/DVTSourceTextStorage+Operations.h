//
//  DVTSourceTextStorage+Operations.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 08/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 *  A category on NSTextStorage, which mimicks a category on DVTSourceTextStorage
 */
@interface NSTextStorage (MHOperations)

/**
 *  Inserts a string at a certain line number in the string.
 *
 *  @param string     a string to insert.
 *  @param lineNumber a line number where to insert the string. Line numbers are enumerated starting from 0.
 */
- (void)mhInsertString:(NSString *)string atLine:(NSUInteger)lineNumber;

/**
 *  Deletes a string at a certain line number in the string
 *
 *  @param lineNumber a line number where to delete the string. Line numbers are enumerated starting from 0.
 */
- (void)mhDeleteLine:(NSInteger)lineNumber;

/**
 *  Batch deletes lines at given line numbers.
 *
 *  @param lineNumbers line numbers to delete
 */
- (void)mhDeleteLines:(NSIndexSet *)lineNumbers;

@end
