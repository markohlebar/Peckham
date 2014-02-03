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
@property (nonatomic, strong) NSArray *statements;
+ (instancetype)fileWithPath:(NSString *)filePath;

- (void)removeDuplicateImports;
- (void)observeFileChanges;

@end

@interface MHInterfaceFile : MHFile

@end

@interface MHImplementationFile : MHFile

@end
