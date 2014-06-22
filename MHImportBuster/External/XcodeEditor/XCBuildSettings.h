//
//  XCBuildSettings.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const XCBuildSettingsSDKROOTKey;
extern NSString *const XCBuildSettingsHeaderSearchPathsKey;
extern NSString *const XCBuildSettingsUserHeaderSearchPathsKey;
extern NSString *const XCBuildSettingsProjectDirKey;

@class XCTarget;
@interface XCBuildSettings : NSObject
@property (nonatomic, strong, readonly) XCTarget *target;
@property (nonatomic, readonly) NSDictionary *settings;
+ (instancetype)buildSettingsWithTarget:(XCTarget *)target;
- (id) valueForKey:(NSString *)key;
@end
