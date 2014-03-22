//
//  MHBlocks.h
//  MHImportBuster
//
//  Created by marko.hlebar on 25/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#ifndef MHImportBuster_MHBlocks_h
#define MHImportBuster_MHBlocks_h

typedef void(^MHVoidBlock)(void);
typedef void(^MHErrorBlock)(NSError* error);
typedef void(^MHArrayBlock)(NSArray* array);

#endif
