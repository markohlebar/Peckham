//
//  MHImportStatement+ConstructionSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 18/05/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHImportStatement+Construction.h"


SPEC_BEGIN(MHImportStatement_ConstructionSpec)

describe(@"MHImportStatement+Construction", ^{
    
    it(@"Should be able to construct a framework statement from a framework header path", ^{
        
        NSString *headerPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Cocoa.framework/Versions/A/Headers/Cocoa.h";
        MHFrameworkImportStatement *statement = [MHFrameworkImportStatement statementWithFrameworkHeaderPath:headerPath];
        [[statement.value should] equal:@"#import <Cocoa/Cocoa.h>"];
        
        headerPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Foundation.framework/Versions/A/Headers/Foundation.h";
        statement = [MHFrameworkImportStatement statementWithFrameworkHeaderPath:headerPath];
        [[statement.value should] equal:@"#import <Foundation/Foundation.h>"];

        headerPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Foundation/Versions/A/Headers/Foundation.h";
        statement = [MHFrameworkImportStatement statementWithFrameworkHeaderPath:headerPath];
        [[statement.value should] beNil];
        
        headerPath = @"/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/System/Library/Frameworks/Foundation.framework/Versions/A/Headers/Foundation";
        statement = [MHFrameworkImportStatement statementWithFrameworkHeaderPath:headerPath];
        [[statement.value should] beNil];
        
    });
    
    it(@"Should be able to construct a project statement from a project header path", ^{
        NSString *headerPath = @"/Headers/MyHeader.h";
        MHProjectImportStatement *statement = [MHProjectImportStatement statementWithHeaderPath:headerPath];
        [[statement.value should] equal:@"#import \"MyHeader.h\""];
        
        headerPath = @"/Header/";
        statement = [MHProjectImportStatement statementWithHeaderPath:headerPath];
        [[statement.value should] beNil];
        
    });
});

SPEC_END
