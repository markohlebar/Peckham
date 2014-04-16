//
//  MyClass.h
//  MHImportBuster
//
//  Created by marko.hlebar on 25/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyImport.h"

@interface MyClass : NSObject
@property (nonatomic, strong) MyClass *parent;

+(instancetype) classMethod;
+(instancetype) classMethod:(NSString *)args;

-(void) instanceMethod;
-(void) instanceMethodWithArg1:(NSString *)arg1 arg2:(NSString *)arg2;

@end
