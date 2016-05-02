//
//  NSString+CamelCaseSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 02/05/2016.
//  Copyright 2016 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "NSString+CamelCase.h"


SPEC_BEGIN(NSString_CamelCaseSpec)

describe(@"NSString+CamelCase", ^{
    it(@"Should return initials from camelcase strings", ^{
        [[[@"test" mh_camelCaseInitials] should] equal:@""];
        [[[@"MHDocumentObserver" mh_camelCaseInitials] should] equal:@"MHDO"];
    });
});

SPEC_END
