//
//  NSString+MHNSRange.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 08/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MHNSRange)
- (NSRange)mhRangeOfLine:(NSInteger) lineNumber;
@end
