//
//  NSObject+MHLogMethods.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 08/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "NSObject+MHLogMethods.h"
#import <objc/objc-runtime.h>

@implementation NSObject (MHLogMethods)
- (void)mhLogMethods {
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList(object_getClass(self), &methodCount);
    NSMutableString *methods = [NSMutableString stringWithFormat:@"\n%@\n\n", NSStringFromClass(self.class)];
    for(int i = 0; i < methodCount; i++) {
        [methods appendFormat:@"%s\n", sel_getName(method_getName(methodList[i]))];
    }
    NSLog(@"%@", methods);
}
@end
