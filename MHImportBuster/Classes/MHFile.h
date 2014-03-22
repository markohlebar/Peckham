//
//  MHFile.h
//  MHImportBuster
//
//  Created by marko.hlebar on 30/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHFile : NSObject
@property (nonatomic, readonly, copy) NSString *filePath;
+ (instancetype)fileWithPath:(NSString *)filePath;
- (void)removeDuplicateImports;
- (void)sortImportsAlphabetically;
- (void)addImport:(NSString *)import;

- (void)observeFileChanges;

@end

@interface MHInterfaceFile : MHFile

@end

@interface MHImplementationFile : MHFile

@end
