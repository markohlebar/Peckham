//
//  MHConcreteSourceFile.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 06/07/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MHSourceFile.h"

@interface MHConcreteSourceFile : NSObject <MHSourceFile>
+ (instancetype)sourceFileWithName:(NSString *)name;
@end