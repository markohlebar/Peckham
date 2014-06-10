//
//  MHAddImportOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <AppKit/AppKit.h>
#import "MHAddImportOperation.h"
#import "MHImportStatement.h"
#import "MHStatementParser.h"
#import "DVTSourceTextStorage+Operations.h"
#import "NSString+Extensions.h"

NSString * const MHAddImportOperationImportRegexPattern = @".*#.*(\bimport\b|\binclude\b)*[\",<]*[\",>]";

@implementation MHAddImportOperation

+ (instancetype)operationWithSource:(NSTextStorage *)source
                        importToAdd:(MHImportStatement *)importToAdd {
    return [[self alloc] initWithSource:source
                            importToAdd:importToAdd];
}

- (id)initWithSource:(NSTextStorage *)source
         importToAdd:(MHImportStatement *)importToAdd {
    self = [super initWithSource:source];
    if (self) {
        _importToAdd = importToAdd;
    }
    return self;
}

- (void)execute {
    NSInteger lastLine = [self appropriateLine];
    
    if (lastLine != NSNotFound) {
        NSString *importString = [NSString stringWithFormat:@"%@\n", [_importToAdd value]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.source mhInsertString:importString
                                 atLine:lastLine+1];
        });
    }
}

- (NSUInteger)appropriateLine {
    __block NSUInteger lineNumber = NSNotFound;
    __block NSUInteger currentLineNumber = 0;
    [self.source.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if ([self isImportString:line]) {
            lineNumber = currentLineNumber;
        }
        currentLineNumber++;
    }];
    
    if (lineNumber == NSNotFound) {
        currentLineNumber = 0;
        [self.source.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
            if (![line isWhitespaceOrNewline]) {
                currentLineNumber++;
            }
            else {
                lineNumber = currentLineNumber;
                *stop = YES;
            }
        }];
    }
    
    return lineNumber;
}

+ (NSRegularExpression *)importRegex {
    static NSRegularExpression *_regex = nil;
    if (!_regex) {
        NSError *error = nil;
        _regex = [[NSRegularExpression alloc] initWithPattern:MHAddImportOperationImportRegexPattern
                                                      options:0
                                                        error:&error];
    }
    return _regex;
}

- (BOOL) isImportString:(NSString *)string {
    NSRegularExpression *regex = [MHAddImportOperation importRegex];
    NSInteger numberOfMatches = [regex numberOfMatchesInString:string
                                                       options:0
                                                         range:NSMakeRange(0, string.length)];
    return numberOfMatches > 0;
}

@end
