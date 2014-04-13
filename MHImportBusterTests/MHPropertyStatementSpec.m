//
//  MHPropertyStatementSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 12/04/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHPropertyStatement.h"
#import "MHInterfaceStatement.h"
#import "MHTestTokens.h"
#import "MHPropertyQualifierStatement.h"

SPEC_BEGIN(MHPropertyStatementSpec)

describe(@"MHPropertyStatement", ^{
    __block MHPropertyStatement *statement = nil;
    
    beforeEach(^{
        statement = [MHPropertyStatement statement];
    });
    
    it(@"Should find a property", ^{
        feedStatement(statement, @"@property NSInteger test;");
        [[statement.value should] equal:@"test"];
    });
    
    it(@"Should find a property qualifier", ^{
        feedStatement(statement, @"@property (nonatomic) NSInteger test;");
        [[statement.value should] equal:@"test"];
        [[statement.children should] haveCountOf:1];
        [[[statement.children firstObject] should] beKindOfClass:[MHPropertyQualifierStatement class]];
    });
    
    it(@"Should find a property qualifier with IBOutlet", ^{
        feedStatement(statement, @"@property (nonatomic) IBOutlet NSInteger test;");
        [[statement.value should] equal:@"test"];
        [[statement.children should] haveCountOf:1];
        [[[statement.children firstObject] should] beKindOfClass:[MHPropertyQualifierStatement class]];
    });
    
});

SPEC_END
