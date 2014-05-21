//
//  XCBuildSettings.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "XCBuildSettings.h"
#import "XCTarget+XCProject.h"
#import "NSString+XCAdditions.h"
#import <XcodeEditor/XCProject.h>

static NSString * const XCBuildSettingsCommandFormat = @"xcodebuild -project %@ -target %@ -showBuildSettings";

@implementation XCBuildSettings

+ (instancetype)buildSettingsWithTarget:(XCTarget *)target
{
    return [[self alloc] initWithTarget:target];
}

- (instancetype)initWithTarget:(XCTarget *)target
{
    self = [super init];
    if (self) {
        _target = target;
    }
    return self;
}

- (NSDictionary *)settings
{
    NSString *projectPath = [_target.project filePath];
    NSString *command = [NSString stringWithFormat:XCBuildSettingsCommandFormat, projectPath, _target.name];
    NSString *output = [command xcRunAsCommand];
    return [output xcSettingsDictionary];
}

@end
