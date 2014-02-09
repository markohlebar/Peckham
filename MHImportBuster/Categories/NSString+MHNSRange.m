//
//  NSString+MHNSRange.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 08/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "NSString+MHNSRange.h"

@implementation NSString (MHNSRange)
- (NSRange)mhRangeOfLine:(NSInteger) lineNumber {
    __block NSInteger currentLineNumber = 0;
    __block BOOL foundLine = NO;
    __block NSRange range = NSMakeRange(0, 0);
    [self enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (lineNumber == currentLineNumber) {
            range.length = (line.length + 1);
            foundLine = YES;
            *stop = YES;
        }
        else {
            range.location += (line.length + 1); //+1 for \n
        }
        currentLineNumber++;
    }];
    
    if (foundLine) {
        //trim the length
        NSInteger lengthDiff = self.length - (range.location + range.length);
        if (lengthDiff < 0) {
            range.length += lengthDiff;
        }
    }
    else {
        range.location = NSNotFound;
        range.length = 0;
    }

    return range;
}
@end
