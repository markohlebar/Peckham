//
//  MHAddImportOperation.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHConcreteSourceOperation.h"

@class MHImportStatement;
@interface MHAddImportOperation : MHConcreteSourceOperation
@property (nonatomic, readonly, strong) MHImportStatement *importToAdd;

+ (instancetype)operationWithSource:(NSTextStorage *)source
                        importToAdd:(MHImportStatement *)importToAdd;

@end
