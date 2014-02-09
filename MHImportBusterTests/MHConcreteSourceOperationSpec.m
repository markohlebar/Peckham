//
//  MHConcreteSourceOperationSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHConcreteSourceOperation.h"


SPEC_BEGIN(MHConcreteSourceOperationSpec)

describe(@"MHConcreteSourceOperation", ^{
    
    __block MHConcreteSourceOperation *operation = nil;
    __block id mockSource = [NSTextStorage mock];
    
    beforeEach(^{
        operation = [MHConcreteSourceOperation operationWithSource:mockSource];
    });
    
    specify(^{
        [[operation shouldNot] beNil];
        [[operation should] beKindOfClass:[MHConcreteSourceOperation class]];
    });
    
    it(@"Should assign a source text view property", ^{
        [[operation.source should] equal:mockSource];
    });
    
    it(@"Should be able to execute", ^{
        [[operation should] respondToSelector:@selector(execute)];
    });
    
    it(@"Should execute after start", ^{
        [[operation shouldEventually] receive:@selector(execute)];
        [operation start];
    });
    
});

SPEC_END
