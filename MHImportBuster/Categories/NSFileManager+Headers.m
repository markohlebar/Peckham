//
//  NSFileManager+Headers.m
//  PropertyParser
//
//  Created by marko.hlebar on 7/20/13.
//  Copyright (c) 2013 Clover Studio. All rights reserved.
//

#import "NSFileManager+Headers.h"

@implementation NSFileManager (Headers)
///finds all files with extension in directory and its subdirectories
///@param extension extension of file ie @"h"
///@param path directory path
///@return array of headers
+(NSArray*) findFilesWithExtension:(NSString*) extension inDirectory:(NSString*) path {
    return [NSFileManager findFilesWithExtensions:@[extension] inDirectory:path];
}

///finds all files with extensions in directory and its subdirectories
///@param extensions array of extensions of file ie @[@"h, @"m"]
///@param path directory path
///@return array of headers
+(NSArray*) findFilesWithExtensions:(NSArray*) extensions inDirectory:(NSString*) path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSMutableArray *items = [NSMutableArray arrayWithArray:[fileManager subpathsOfDirectoryAtPath:path error:&error]];
    NSMutableArray *files = [NSMutableArray array];
    if (!error) {
        [items addObjectsFromArray:[fileManager subpathsAtPath:path]];

        for (NSString *item in items) {

            for (NSString *extension in extensions) {
                if ([[item pathExtension] isEqualToString:extension]) {
                    NSString *fullPath = [path stringByAppendingPathComponent:item];
                    if (![files containsObject:fullPath]) {
                        [files addObject:fullPath];
                    }
                }
            }
        }
    }
    else {
        NSLog(@"%@ %@", path, [error localizedDescription]);
    }
    
    return [files copy];
}

///finds all subdirectories inside a directory
///@param directory directory to find subdirectories for
///@return subdirectories
+(NSArray*) subDirectoriesInDirectory:(NSString*) directoryPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *items = [fileManager subpathsOfDirectoryAtPath:directoryPath error:&error];
    
    NSMutableArray *directories = [NSMutableArray array];
    
    for (NSString *item in items) {
        NSString * fullPath = [directoryPath stringByAppendingPathComponent:item];
        BOOL isDir;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir) {
            [directories addObject: fullPath];
        }
    }
    
    return [directories copy];
}

@end
