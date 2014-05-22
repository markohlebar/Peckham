//
//  MHStringLiteralStatement.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 20/05/2014.
//  Copyright 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHStringLiteralStatement.h"


SPEC_BEGIN(MHStringLiteralStatementSpec)

describe(@"MHStringLiteralStatement", ^{

    __block MHStringLiteralStatement *statement = nil;
    
    NSString *filePath = [[NSBundle bundleForClass:self.class] pathForResource:@"MHStringLiteralStatementSpec" ofType:@""];
    NSString *text = [NSString stringWithContentsOfFile:filePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
    NSArray *strings = [text componentsSeparatedByString:@"\n"];
    
    specify(^{
        statement = [MHStringLiteralStatement statementWithString:strings[0]];
        [[statement should] beNonNil];
        [[statement.value should] equal:@"Test"];
        
        statement = [MHStringLiteralStatement statementWithString:strings[1]];
        [[statement should] beNonNil];
        [[statement.value should] equal:@"Test \\\" \\\" "];
    });
    
});

SPEC_END
