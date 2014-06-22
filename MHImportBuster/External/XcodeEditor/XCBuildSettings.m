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

static NSString * const XCBuildSettingsCommandFormat           = @"xcodebuild -project \"%@\" -target \"%@\" -showBuildSettings";

NSString *const XCBuildSettingsSDKROOTKey                      = @"SDKROOT";
NSString *const XCBuildSettingsHeaderSearchPathsKey            = @"HEADER_SEARCH_PATHS";
NSString *const XCBuildSettingsUserHeaderSearchPathsKey        = @"USER_HEADER_SEARCH_PATHS";
NSString *const XCBuildSettingsProjectDirKey                   = @"PROJECT_DIR";

@implementation XCBuildSettings
{
    NSDictionary *_settings;
}

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
    if(!_settings) {
        NSString *projectPath = [_target.project filePath];
        NSString *command = [NSString stringWithFormat:XCBuildSettingsCommandFormat, projectPath, _target.name];
        NSString *output = [command xcRunAsCommand];
        _settings = [output xcSettingsDictionary];
    }
    return _settings;
}

- (id) valueForKey:(NSString *)key {
    return self.settings[key];
}

@end
