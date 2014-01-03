//
//  MHFileHandle.m
//  MHImportBuster
//
//  Created by marko.hlebar on 31/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

//some code from Dave DeLong http://stackoverflow.com/questions/3707427/how-to-read-data-from-nsfilehandle-line-by-line#3711079

#import "MHFileHandle.h"

@interface NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind;

@end

@implementation NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind {
    
    const void * bytes = [self bytes];
    NSUInteger length = [self length];
    
    const void * searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSUInteger searchIndex = 0;
    
    NSRange foundRange = {NSNotFound, searchLength};
    for (NSUInteger index = 0; index < length; index++) {
        if (((char *)bytes)[index] == ((char *)searchBytes)[searchIndex]) {
            //the current character matches
            if (foundRange.location == NSNotFound) {
                foundRange.location = index;
            }
            searchIndex++;
            if (searchIndex >= searchLength) { return foundRange; }
        } else {
            searchIndex = 0;
            foundRange.location = NSNotFound;
        }
    }
    return foundRange;
}
@end


@implementation MHFileHandle
{
    NSString *_filePath;
    
    NSFileHandle *_fileHandle;
    unsigned long long _currentOffset;
    
    NSString * _lineDelimiter;
    NSData *_lineDelimiterData;

    NSUInteger _chunkSize;
    NSMutableData *_currentData;
}

#pragma mark - Setup

- (void) dealloc {
//    [_fileHandle synchronizeFile];
    [_fileHandle closeFile];
}

+ (instancetype) handleWithFilePath:(NSString *)filePath {
    return [[self alloc] initWithFilePath:filePath];
}

- (id) initWithFilePath:(NSString *)filePath {
    if (self = [super init]) {
        _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        if (_fileHandle == nil) {
            return nil;
        }
        _currentData = [[NSMutableData alloc] init];
        
        _filePath = filePath;
        self.lineDelimiter = @"\n";
        _chunkSize = 10;

        [self calculateTotalFileLength];
        [self seekToStart];
    }
    return self;
}

-(void) calculateTotalFileLength {
    [_fileHandle seekToEndOfFile];
    _totalFileLength = [_fileHandle offsetInFile];
}

#pragma mark - Setters
-(void) setLineDelimiter:(NSString *)lineDelimiter {
    _lineDelimiter = lineDelimiter.copy;
    _lineDelimiterData = [_lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
}

//TODO: Make an index dict, one where we would store the offsets for line numbers for fast seeking
#pragma mark - Reading
- (NSString *) readLine {
    if (_currentOffset >= _totalFileLength) { return nil; }
    
    [_fileHandle seekToFileOffset:_currentOffset];
    [_currentData setData:nil];
    
    BOOL shouldReadMore = YES;
    while (shouldReadMore) {
        if (_currentOffset >= _totalFileLength) { break; }
        unsigned long long chunkSize = _chunkSize;
        if (_currentOffset + chunkSize > _totalFileLength) {
            chunkSize = _totalFileLength - _currentOffset;
        }
        NSData * chunk = [_fileHandle readDataOfLength:chunkSize];
        if (chunk.length == 0) break;
        
        NSRange newLineRange = [chunk rangeOfData_dd:_lineDelimiterData];
        if (newLineRange.location != NSNotFound) {
            
            //include the length so we can include the delimiter in the string
            chunk = [chunk subdataWithRange:NSMakeRange(0, newLineRange.location+[_lineDelimiterData length])];
            shouldReadMore = NO;
        }
        [_currentData appendData:chunk];
        _currentOffset += [chunk length];
    }
    
    NSString *line = [[NSString alloc] initWithData:_currentData encoding:NSUTF8StringEncoding];
    return line;
}

-(NSString*) readLine:(NSInteger) lineNumber {
    [self seekToLine:lineNumber];
    return [self readLine];
}

- (NSString *) readTrimmedLine {
    return [[self readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block {
    NSString * line = nil;
    BOOL stop = NO;
    while (stop == NO && (line = [self readLine])) {
        block(line, &stop);
    }
}

#pragma mark - Seeking 

-(void) seekToStart {
    _currentOffset = 0ULL;
    [_fileHandle seekToFileOffset:_currentOffset];
}

/**
 *  Seeks the file to the line number.
 *  Calling readLine after seekToLine, reads the contents of that line.
 *
 *  @param lineNumber a line number.
 */
-(void) seekToLine:(NSUInteger) lineNumber {
    [self seekToStart];
    for (NSInteger i = 0; i < lineNumber; i++) {
        [self readLine];
    }
}

#pragma mark - Writing
/**
 *  Inserts a string at a certain line number in the file
 *
 *  @param string     a string to insert
 *  @param lineNumber a line number where to insert the string. Line numbers are enumerated starting from 0
 */
-(void) insertString:(NSString*) string atLine:(NSUInteger) lineNumber {
    
    //first we need to make sure that the file is large enough to take the new string
    [_fileHandle truncateFileAtOffset:_totalFileLength + string.length];
    //recalculate total file length
    [self calculateTotalFileLength];
    
    //next, seek to the line
    [self seekToLine:lineNumber];
    
    unsigned long long fileOffset = _currentOffset;
    unsigned long long writeFromOffset = fileOffset + string.length;

    [self writeTempDataFromFileOffset:writeFromOffset
                       tempFileOffset:fileOffset];
    
    //seek back to writing offset
    [_fileHandle seekToFileOffset:fileOffset];
    //and write data
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    [self tryWritingData:stringData];
}

-(void) writeTempDataFromFileOffset:(unsigned long long) fileOffset
                     tempFileOffset:(unsigned long long) tempFileOffset
{
    NSFileHandle *tempFileHandle = [self createTempFileForReading];
    [tempFileHandle seekToFileOffset:tempFileOffset];
    [_fileHandle seekToFileOffset:fileOffset];
    
    NSData *data = nil;
    do {
        data = [tempFileHandle readDataOfLength:_chunkSize];
        [self tryWritingData:data];
    } while (data.length > 0);
    
    [self destroyTempFileForReading];
}

-(void) tryWritingData:(NSData*) data {
    @try {
        [_fileHandle writeData:data];
    }
    @catch (NSException *exception) {
        @throw exception;
        [_fileHandle closeFile];
    }
    @finally {
    }
}

#pragma mark - Deleting 
/**
 *  Deletes a string at a certain line number in the file
 *
 *  @param lineNumber a line number where to delete the string. Line numbers are enumerated starting from 0.
 */
-(void) deleteLine:(NSInteger) lineNumber {
    //move to the desired line
    [self seekToLine:lineNumber];
    unsigned long long offset = _currentOffset;
    NSString *line = [self readLine];
    [self writeTempDataFromFileOffset:offset
                       tempFileOffset:offset + line.length];
    //Truncate
    [_fileHandle truncateFileAtOffset:_totalFileLength - line.length];
    
    //Recalculate total file length
    [self calculateTotalFileLength];
    
    //seek back to line number
    [self seekToLine:lineNumber];
}

/**
 *  Batch deletes lines at given line indexes
 *
 *  @param lineIndexes line indexes to delete
 */
-(void) deleteLines:(NSIndexSet*) lineNumbers {
    //this offset will be +1 for each deleted line and be subtracted from line index
    __block NSInteger offset = 0;
    NSMutableIndexSet *mutableLineNumbers = [lineNumbers mutableCopy];
    [mutableLineNumbers enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [self deleteLine:idx - offset];
        offset++;
    }];
    
}

#pragma mark - Private 

-(NSString*) tempPath {
    return [_filePath stringByAppendingString:@"_"];
}

-(void) destroyTempFileForReading {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    [fileManager removeItemAtPath:[self tempPath]
                            error:&error];
}

-(NSFileHandle*) createTempFileForReading {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempPath = [self tempPath];
    NSError *error = nil;
    [fileManager copyItemAtPath:_filePath
                         toPath:tempPath
                          error:&error];
    if (!error) {
        return [NSFileHandle fileHandleForReadingAtPath:tempPath];
    }
    return nil;
}

@end