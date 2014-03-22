//
//  MHImportBusterTestsHelper.h
//  MHImportBuster
//
//  Created by marko.hlebar on 01/01/14.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#ifndef MHImportBuster_MHImportBusterTestsHelper_h
#define MHImportBuster_MHImportBusterTestsHelper_h

#import <Foundation/Foundation.h>
#import "NSString+Files.h"

static NSString *createTempFile(NSString* filePath) {
    NSString *tempFilePath = [filePath filePathByAddingSuffix:@"__"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager copyItemAtPath:filePath toPath:tempFilePath error:nil];
    return tempFilePath;
}

static void deleteFile(NSString* filePath) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:nil];
}

static BOOL compareFiles(NSString *filePath, NSString *filePath2) {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager contentsEqualAtPath:filePath andPath:filePath2];
}

#endif
