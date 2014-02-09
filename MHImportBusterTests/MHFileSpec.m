//
//  MHFileSpec.m
//  MHImportBuster
//
//  Created by marko.hlebar on 30/12/13.
//  Copyright 2013 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHFile.h"
#import "MHStatement.h"
#import "MHImportBusterTestsHelper.h"

SPEC_BEGIN(MHFileSpec)

MHFile* (^fileBlock)(NSString* filePath) = ^(NSString *filePath) {
    MHFile *file = [MHFile fileWithPath:filePath];
    return file;
};

describe(@"Interface tests", ^{
    __block MHFile *file = nil;
    __block NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"MyClass" ofType:@"h"];

    beforeAll(^{
        file = fileBlock(filePath);
    });
    
    specify(^{
        [[file should] beNonNil];
    });
    
    it(@"Should be of class MHInterfaceFile", ^{
        [[file should] beKindOfClass:[MHInterfaceFile class]];
    });

    
    it(@"Should have a file path", ^{
        [[file.filePath should] equal:filePath];
    });
});

describe(@"Implementation tests", ^{
    __block MHFile *file = nil;
    __block NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"MyClass" ofType:@"m"];
    
    beforeAll(^{
        file = fileBlock(filePath);
    });
    
    specify(^{
        [[file should] beNonNil];
    });
    
    it(@"Should be of class MHImplementationFile", ^{
        [[file should] beKindOfClass:[MHImplementationFile class]];
    });
});

describe(@"Invalid file tests", ^{
    __block MHFile *file = nil;
    __block NSString *filePath = @"fakeFilePath.fake";
    
    beforeAll(^{
        file = fileBlock(filePath);
    });
    
    specify(^{
        [[file should] beNil];
    });
    
});

describe(@"Duplicate imports tests", ^{
    __block MHFile *file = nil;
    __block NSString *cannonicalFilePath = [[NSBundle bundleForClass:self.class] pathForResource:@"MyClass" ofType:@"h"];
    __block NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"MyClass_duplicateImports" ofType:@"h"];
    __block NSString *tempFilePath = nil;
    
    beforeEach(^{
        tempFilePath = createTempFile(filePath);
        file = fileBlock(tempFilePath);
    });
    
    afterEach(^{
        deleteFile(tempFilePath);
    });
    
//    it(@"Should be able to remove duplicate imports", ^{
//        [file removeDuplicateImports];
//        BOOL result = compareFiles(cannonicalFilePath, tempFilePath);
//        [[theValue(result) should] beYes];
//    });
});

SPEC_END
