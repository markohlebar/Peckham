//
//  Created by Benoît on 11/01/14.
//  Copyright (c) 2014 Pragmatic Code. All rights reserved.
//

static NSString *const MHSystemFrameworksPath = @"/System/Library/Frameworks/";

#import <Foundation/Foundation.h>
#import "XCFXcodePrivate.h"
@class IDESourceCodeDocument;

@interface MHXcodeDocumentNavigator : NSObject
+ (id)currentEditor;
+ (IDESourceCodeDocument *)currentSourceCodeDocument;
+ (NSTextView *)currentSourceCodeTextView;
+ (IDEWorkspaceDocument *)currentWorkspaceDocument;
+ (NSString *)currentFilePath;
+ (NSString *)currentWorkspacePath;

/**
 *  Returns a path for the system framework named frameworkName
 *
 *  @param frameworkName a framework name. i.e. Carbon or Carbon.framework
 *
 *  @return a framework path
 */
+ (NSString *)pathForFrameworkNamed:(NSString *)frameworkName;
@end
