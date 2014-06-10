//
//  Created by Benoît on 11/01/14.
//  Copyright (c) 2014 Pragmatic Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCFXcodePrivate.h"
@class IDESourceCodeDocument;
@class XCTarget;

@interface MHXcodeDocumentNavigator : NSObject
+ (id)currentEditor;
+ (IDESourceCodeDocument *)currentSourceCodeDocument;
+ (NSTextView *)currentSourceCodeTextView;
+ (IDEWorkspaceDocument *)currentWorkspaceDocument;
+ (NSString *)currentFilePath;
+ (NSString *)currentWorkspacePath;


+ (NSString *)pathForFrameworkNamed:(NSString *)frameworkName;
+ (XCTarget *)currentTarget;
@end
