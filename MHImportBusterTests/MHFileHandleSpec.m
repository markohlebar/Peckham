//
//  MHFileHandleSpec.m
//  MHImportBuster
//
//  Created by marko.hlebar on 31/12/13.
//  Copyright 2013 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHFileHandle.h"
#import "NSMutableIndexSet+NSArray.h"
#import "MHImportBusterTestsHelper.h"

SPEC_BEGIN(MHFileHandleSpec)

describe(@"File handle with existing file", ^{
    __block MHFileHandle *fileHandle = nil;
    __block NSString *zeroLine = @"Zero\n";
    
    __block NSString *firstLine = @"First\n";    //0
    __block NSString *secondLine = @"Second\n";  //1
    __block NSString *thirdLine = @"Third\n";    //2
    __block NSString *fourthLine = @"Fourth\n";  //3
    __block NSString *fifthLine = @"Fifth\n";    //4
    __block NSString *endLine = @"END";          //5
    
    __block NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"FileHandleTestFile"
                                                                                ofType:@""];
    NSAssert(filePath, @"MHFileHandleSpec - File should exist in this bundle");
    __block NSString *tempFilePath = nil;

    beforeEach(^{
        tempFilePath = createTempFile(filePath);
        fileHandle = [MHFileHandle handleWithFilePath:tempFilePath];
    });
    
    afterEach(^{
        deleteFile(tempFilePath);
    });
    
    specify(^{
        [[fileHandle should] beNonNil];
    });
    
    describe(@"Reading", ^{
        it(@"Should be able to read a line", ^{
            NSString *line = [fileHandle readLine];
            [[line should] beNonNil];
            [[line should] equal:firstLine];
        });
        
        it(@"Should be able to read 2 lines", ^{
            NSString *line = [fileHandle readLine];
            [[line should] equal:firstLine];
            line = [fileHandle readLine];
            [[line should] equal:secondLine];
        });
        
        it(@"Should be able to read to the end of the file", ^{
            NSString *line = nil;
            while ((line = [fileHandle readLine]));
            [[line should] beNil];
        });
    });
    
    describe(@"Seeking", ^{
        it(@"Should be able to seek to start", ^{
            [fileHandle readLine];
            [fileHandle readLine];
            
            [fileHandle seekToStart];
            NSString *line = [fileHandle readLine];
            [[line should] equal:firstLine];
        });
        
        it(@"Should be able to seek to specified line", ^{
            [fileHandle seekToLine:1];
            NSString *line = [fileHandle readLine];
            [[line should] equal:secondLine];
        });
    });
    
    describe(@"Inserting", ^{
       it(@"Should be able to insert text at 0 line", ^{
           [fileHandle insertString:zeroLine atLine:0];
           NSString *line = [fileHandle readLine];
           [[line should] equal:zeroLine];
           
           line = [fileHandle readLine];
           [[line should] equal:firstLine];
        });
        
        it(@"Should be able to insert text at middle line", ^{
            [fileHandle insertString:zeroLine atLine:2];
            NSString *line = [fileHandle readLine];
            [[line should] equal:zeroLine];
            
            line = [fileHandle readLine];
            [[line should] equal:thirdLine];
        });
        
        it(@"Should be able to insert text at end of file", ^{
            [fileHandle insertString:zeroLine atLine:5];
            NSString *line = [fileHandle readLine];
            [[line should] equal:zeroLine];
            
            line = [fileHandle readLine];            
            [[line should] equal:endLine];
        });
    });
    
    describe(@"Deleting", ^{
        it(@"Should be able to delete line 0", ^{
            [fileHandle deleteLine:0];
            NSString *line = [fileHandle readLine];
            [[line should] equal:secondLine];
        });
        
        it(@"Should ve able to delete line 2", ^{
            [fileHandle deleteLine:2];
            NSString *line = [fileHandle readLine];
            [[line should] equal:fourthLine];
            
            [fileHandle seekToLine:1];
            line = [fileHandle readLine];
            [[line should] equal:secondLine];
        });
        
        it(@"Should be able to batch delete 2 lines", ^{
           
            NSArray *lines = @[@2, @3];
            [fileHandle deleteLines:[NSMutableIndexSet indexSetWithArray:lines]];
            
            NSString *line = [fileHandle readLine];
            [[line should] equal:fifthLine];
            
            [fileHandle seekToLine:1];
            line = [fileHandle readLine];
            [[line should] equal:secondLine];
        });
        
        it(@"Should be able to batch delete 3 lines with space between", ^{
            
            NSArray *lines = @[@2, @0, @4];
            [fileHandle deleteLines:[NSMutableIndexSet indexSetWithArray:lines]];
            
            NSString *line = [fileHandle readLine];
            [[line should] equal:endLine];
            
            [fileHandle seekToLine:0];
            line = [fileHandle readLine];
            [[line should] equal:secondLine];
        });
    });
});

SPEC_END
