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
-(BOOL) isValidFilePath;

/**
 *  Checks if file path is to a header file
 *
 *  @return YES if file path is to a header file
 */
-(BOOL) isHeaderFilePath;

/**
 *  Checks if file path is to an implementation file
 *
 *  @return YES if file path is to an implementation file
 */
-(BOOL) isImplementationFilePath;

/**
 *  Adds a suffix to the file path, respecting the file extension.
 *
 *  @param suffix a suffix
 *
 *  @return a file path with added suffix
 */
-(NSString*) filePathByAddingSuffix:(NSString*) suffix;
@end
