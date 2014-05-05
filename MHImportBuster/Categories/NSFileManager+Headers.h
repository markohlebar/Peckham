//
//  NSFileManager+Headers.h
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Headers)
///finds all files with extension in directory and its subdirectories
///@param extension extension of file ie @"h"
///@param path directory path
///@return array of headers
+(NSArray*) findFilesWithExtension:(NSString*) extension inDirectory:(NSString*) path;

///finds all files with extensions in directory and its subdirectories
///@param extensions array of extensions of file ie @[@"h, @"m"]
///@param path directory path
///@return array of headers
+(NSArray*) findFilesWithExtensions:(NSArray*) extensions inDirectory:(NSString*) path;

///finds all subdirectories inside a directory
///@param directoryPath directory to find subdirectories for
///@return subdirectories
+(NSArray*) subDirectoriesInDirectory:(NSString*) directoryPath;
@end
