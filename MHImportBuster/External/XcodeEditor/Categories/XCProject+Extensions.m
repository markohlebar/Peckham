//
//  XCProject+NSDate.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 10/06/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "XCProject+Extensions.h"

@interface XCProject ()
- (NSArray*)projectFilesOfType:(XcodeSourceFileType)projectFileType;
@end

@implementation XCProject (NSDate)
- (NSDate *)dateModified {
    NSURL *fileUrl = [NSURL fileURLWithPath:self.filePath];
    NSDate *date = nil;
    [fileUrl getResourceValue:&date
                       forKey:NSURLContentModificationDateKey
                        error:nil];
    return date;
}
@end

@implementation XCProject (MHSubprojects)
- (NSArray *)subProjectFiles {
    return [self projectFilesOfType:XcodeProject];
}
@end
