//
//  MHInterfaceStatementSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/04/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHInterfaceStatement.h"
#import "MHTestTokens.h"

SPEC_BEGIN(MHInterfaceStatementSpec)

describe(@"MHInterfaceStatement", ^{
    
    __block MHInterfaceStatement *statement = nil;
    
    beforeEach(^{
        statement = [MHInterfaceStatement statement];
    });
    
    it(@"Should find an interface", ^{
        feedStatement(statement, @"@interface MyInterface\n@end");
        [[statement.value should] equal:@"MyInterface"];
    });
    
    it(@"Should find an interface with superclass", ^{
        feedStatement(statement, @"@interface MyInterface : NSObject\n@end");
        [[statement.value should] equal:@"MyInterface"];
    });
    
    it(@"Should find an interface with superclass and protocol", ^{
        feedStatement(statement, @"@interface MyInterface : NSObject <MyProtocol>\n@end");
        [[statement.value should] equal:@"MyInterface"];
    });
    
    it(@"Should find an interface containing a property, a class method and instance method", ^{
        feedStatement(statement, @"@interface MyInterface : NSObject <MyProtocol>\n\
                      @property (nonatomic) BOOL testProperty;\n\
                      +(void)classMethod;\n\
                      -(void)instanceMethod:(NSInteger)argument;\n\
                      @end");
        [[statement.value should] equal:@"MyInterface"];
        [[statement.children should] haveCountOf:3];

    });
});

SPEC_END
