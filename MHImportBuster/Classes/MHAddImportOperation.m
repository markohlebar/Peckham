//
//  MHAddImportOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHAddImportOperation.h"
#import "MHImportStatement.h"
#import "MHStatementParser.h"
#import "DVTSourceTextStorage+Operations.h"

@implementation MHAddImportOperation

+ (instancetype)operationWithSource:(NSTextStorage *)source
                        importToAdd:(MHImportStatement *)importToAdd {
    return [[self alloc] initWithSource:source
                            importToAdd:importToAdd];
}

- (id)initWithSource:(NSTextStorage *)source
         importToAdd:(MHImportStatement *)importToAdd {
    self = [super initWithSource:source];
    if (self) {
        _importToAdd = importToAdd;
    }
    return self;
}

- (void)execute {
    NSArray *statements = [[MHStatementParser new] parseText:self.source.string
                                                       error:nil
                                            statementClasses:@[[MHFrameworkImportStatement class],
                                                               [MHProjectImportStatement class]]];
    __block NSInteger lastLine = 0;
    __weak MHAddImportOperation* weakSelf = self;
    [statements enumerateObjectsUsingBlock:^(MHImportStatement *statement, NSUInteger idx, BOOL *stop) {
        if ([statement isEqual:weakSelf.importToAdd]) {
            lastLine = NSNotFound;
            *stop = YES;
        }
        
        [statement.codeLineNumbers enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            if(idx > lastLine) lastLine = idx;
        }];
    }];

    if (lastLine != NSNotFound) {
        NSString *importString = [NSString stringWithFormat:@"%@\n", [_importToAdd value]];
        [self.source mhInsertString:importString
                             atLine:lastLine+1];
    }
}

@end
