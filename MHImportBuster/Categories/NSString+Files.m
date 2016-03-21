//
//  NSString+Files.m
//  MHImportBuster
//
//  Created by marko.hlebar on 29/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import "NSString+Files.h"

@implementation NSString (Files)

+(NSCharacterSet *) invalidCharacterSet {
    static NSCharacterSet *_invalidCharacterSet = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _invalidCharacterSet = [[NSCharacterSet characterSetWithRange: NSMakeRange(0, 256)] invertedSet];
    });

    return _invalidCharacterSet;
}

/**
 *  Checks if the file path provided is valid
 *
 *  @return YES if file exists at path
 */
-(BOOL) isValidFilePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    return [fileManager fileExistsAtPath:self isDirectory:&isDirectory] && !isDirectory;
}

/**
 *  Checks if file path is to a header file
 *
 *  @return YES if file path is to a header file
 */
-(BOOL) isHeaderFilePath {
    NSString *extension = [self pathExtension];
    return [extension isEqualToString:@"h"] || [extension isEqualToString:@"hh"];
}

/**
 *  Checks if the string contains invalid characters/
 *
 *  @discussion Valid characters are the characters represented by the inverted `NSCharacterSet` of the set from range of location 0 and length 256.
 *
 *
 *  @return YES if the lastPathComponent contains characters included in the invalid character set.
 */
-(BOOL) containsIllegalCharacters {
    NSString *fileName = [self lastPathComponent];
    return [fileName rangeOfCharacterFromSet: [[self class] invalidCharacterSet]].location != NSNotFound;
}

/**
 *  Checks if file path is to an implementation file
 *
 *  @return YES if file path is to an implementation file
 */
-(BOOL) isImplementationFilePath {
    NSString *extension = [self pathExtension];
    return [extension isEqualToString:@"m"] || [extension isEqualToString:@"mm"];
}

/**
 *  Adds a suffix to the file path, respecting the file extension.
 *
 *  @param suffix a suffix
 *
 *  @return a file path with added suffix
 */
-(NSString*) filePathByAddingSuffix:(NSString*) suffix {
    NSString *extension = [self pathExtension];
    NSString *filePath = self;
    if (extension) {
        filePath = [filePath stringByDeletingPathExtension];
    }
    filePath = [filePath stringByAppendingString:suffix];
    return extension ? [filePath stringByAppendingPathExtension:extension] : filePath;
}

@end
