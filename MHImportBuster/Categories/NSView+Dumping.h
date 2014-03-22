//
//  NSView+Dumping.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 08/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//http://www.blackdogfoundry.com/blog/common-xcode4-plugin-techniques/
@interface NSView (Dumping)
-(void)dumpWithIndent:(NSString *)indent;
@end
