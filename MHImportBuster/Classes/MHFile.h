//
//  MHFile.h
//  MHImportBuster
//
//  Created by marko.hlebar on 30/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHImportStatement;
@interface MHFile : NSObject
@property (nonatomic, readonly, copy) NSString *filePath;
+ (instancetype)fileWithPath:(NSString *)filePath;
+ (instancetype)fileWithCurrentFilePath;
- (void)removeDuplicateImports;
- (void)sortImportsAlphabetically;
- (void)addImport:(MHImportStatement *)import;
- (void)observeFileChanges;
@end

@interface MHInterfaceFile : MHFile

@end

@interface MHImplementationFile : MHFile

@end
