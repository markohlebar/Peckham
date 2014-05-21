//
//  NSString+XCAdditions.h
//  xcode-editor
//
//  Created by Marko Hlebar on 08/05/2014.
//  Copyright (c) 2014 EXPANZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XCAdditions)
- (NSString *)stringByReplacingOccurrencesOfStrings:(NSArray *)targets
                                         withString:(NSString *)replacement;

- (BOOL)containsOccurencesOfStrings:(NSArray *)strings;
- (BOOL)containsString:(NSString *)string;
@end

@interface NSString (ShellExecution)
- (NSString*)xcRunAsCommand;
@end

@interface NSString (ParseXCSettings)
- (NSDictionary*)xcSettingsDictionary;
- (id)xcParseWhitespaceArray;
@end