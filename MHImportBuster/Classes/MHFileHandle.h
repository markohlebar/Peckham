//
//  MHFileHandle.h
//  MHImportBuster
//
//  Created by marko.hlebar on 31/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHFileHandle : NSObject
@property (nonatomic, copy) NSString *lineDelimiter;
@property (nonatomic) NSUInteger chunkSize;
@property (nonatomic, readonly) unsigned long long totalFileLength;

+ (instancetype)handleWithFilePath:(NSString *)filePath;

/**
 *  Reads a line of text and seeks to the next line.
 *
 *  @return a line of text from file.
 */
- (NSString *)readLine;

/**
 *  Reads the file at a certain line.
 *  A combination of seekToLine: and readLine.
 *
 *  @param lineNumber a line number.
 *
 *  @return a line of text from file.
 */
- (NSString *)readLine:(NSInteger)lineNumber;

/**
 *  Seeks the file to the start.
 */
- (void)seekToStart;

/**
 *  Seeks the file to the line number.
 *  Calling readLine after seekToLine, reads the contents of that line.
 *
 *  @param lineNumber a line number.
 */
- (void)seekToLine:(NSUInteger)lineNumber;

/**
 *  Inserts a string at a certain line number in the file.
 *
 *  @param string     a string to insert.
 *  @param lineNumber a line number where to insert the string. Line numbers are enumerated starting from 0.
 */
- (void)insertString:(NSString *)string atLine:(NSUInteger)lineNumber;

/**
 *  Deletes a string at a certain line number in the file
 *
 *  @param lineNumber a line number where to delete the string. Line numbers are enumerated starting from 0.
 */
- (void)deleteLine:(NSInteger)lineNumber;

/**
 *  Batch deletes lines at given line numbers.
 *
 *  @param lineNumbers line numbers to delete
 */
- (void)deleteLines:(NSIndexSet *)lineNumbers;

//- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL *))block;

//-(void) insertString:(NSString*) string atLine:(NSInteger) lineNumber;
//-(void) deleteLine:(NSInteger) lineNumber;

//-(void) moveToLine:(NSInteger) lineNumber;
//-(NSString*) readLine:(NSInteger) lineNumber;

@end
