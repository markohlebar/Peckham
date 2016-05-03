//
//  NSString+Files.h
//  MHImportBuster
//
//  Created by marko.hlebar on 29/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Files)
/**
 *  Checks if the file path provided is valid
 *
 *  @return YES if file exists at path
 */
- (BOOL)isValidFilePath;

/**
 *  Checks if file path is to a header file
 *
 *  @return YES if file path is to a header file
 */
- (BOOL)isHeaderFilePath;

/**
 *  Checks if file path is a CPP header file. 
 *  This will check if the extension is .hpp / .hxx
 *  and will also check if there is an associated .c / .cpp file in the project
 *
 *  @return YES if is file a CPP header
 */
- (BOOL)isCPPHeaderFilePath;

/**
 *  Checks if file path is to an implementation file
 *
 *  @return YES if file path is to an implementation file
 */
- (BOOL)isImplementationFilePath;

/**
 *  Checks if file path is to an implementation file with .c / .cpp extension
 *
 *  @return YES if file path is to an implementation file
 */
- (BOOL)isCPPImplementationFilePath;

/**
 *  Checks if the string contains invalid characters/
 *
 *  @discussion Valid characters are the characters represented by the inverted `NSCharacterSet` of the set from range of location 0 and length 256.
 *
 *
 *  @return YES if the lastPathComponent contains characters included in the invalid character set.
 */
- (BOOL)containsIllegalCharacters;

/**
 *  Adds a suffix to the file path, respecting the file extension.
 *
 *  @param suffix a suffix
 *
 *  @return a file path with added suffix
 */
- (NSString *)filePathByAddingSuffix:(NSString*) suffix;

@end
