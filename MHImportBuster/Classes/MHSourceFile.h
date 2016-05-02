//
//  MHSourceFile.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 06/07/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MHSourceFile <NSObject>
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *lastPathComponent;
@property (nonatomic, readonly) NSString *extension;
@property (nonatomic, readonly) NSInteger type;
@end
