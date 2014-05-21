//
//  MHImportStatement+Construction.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 18/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportStatement.h"

@interface MHImportStatement (Construction)

/**
 *  Creates a framework import statement from a framework header path
 *
 *  @param headerPath a framework header path
 *
 *  @return a framework import statement
 */
+ (MHFrameworkImportStatement *)statementWithFrameworkHeaderPath:(NSString *)headerPath;

/**
 *  Creates a project import statement from a header path
 *
 *  @param headerPath a header path
 *
 *  @return a project import statement
 */
+ (MHProjectImportStatement *)statementWithHeaderPath:(NSString *)headerPath;

@end
