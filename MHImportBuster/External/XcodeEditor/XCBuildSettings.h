//
//  XCBuildSettings.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCTarget;
@interface XCBuildSettings : NSObject
@property (nonatomic, strong, readonly) XCTarget *target;
@property (nonatomic, readonly) NSDictionary *settings;
+ (instancetype)buildSettingsWithTarget:(XCTarget *)target;
@end
