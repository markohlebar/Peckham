//
//  MHSourceOperation.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MHSourceOperation <NSObject>
+ (instancetype)operationWithSource:(NSTextStorage *)source;
- (id)initWithSource:(NSTextStorage *)source;
- (void)execute;
@property (nonatomic, readonly) NSTextStorage *source;
@end
