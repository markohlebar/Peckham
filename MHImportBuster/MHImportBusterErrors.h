//
//  MHImportBusterErrors.h
//  MHImportBuster
//
//  Created by marko.hlebar on 25/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#ifndef MHImportBuster_MHImportBusterErrors_h
#define MHImportBuster_MHImportBusterErrors_h

typedef enum {
    MHImportBusterFileDoesntExistAtPath = 1000
} MHImportBusterErrorCode;

#define MHImportBusterErrorDomain @"com.markohlebar.importbuster"

#define MHImportBusterError(__CODE__, __USERINFODICT__)\
[NSError errorWithDomain:MHImportBusterErrorDomain\
                    code:__CODE__\
                userInfo:__USERINFODICT__]

#define MHImportBusterFailingObjectKey      @"MHImportBusterFailingObjectKey"
#define MHImportBusterErrorUserInfo(__OBJECT__) @{MHImportBusterFailingObjectKey : __OBJECT__}

#endif
