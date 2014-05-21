//
//  XCTarget+XCProject.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "XCTarget.h"

@interface XCTarget (XCProject)
@property (nonatomic, strong, readonly) XCProject *project;
@property (nonatomic, strong, readonly) NSArray *frameworks;

@end
