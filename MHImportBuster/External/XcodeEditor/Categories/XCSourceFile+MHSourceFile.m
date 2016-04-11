//
//  XCSourceFile+Equality.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 06/07/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "XCSourceFile+MHSourceFile.h"

@implementation XCSourceFile (MHSourceFile)

- (NSUInteger)hash {
    return self.type ^ [self.name hash] ^ [self.key hash];
}

- (BOOL)isEqual:(XCSourceFile *)other {
    return (other == self ||
            (other.type == self.type && [other.name isEqualToString:self.name] && [self.key isEqualToString: other.key]));
}

- (NSString *)lastPathComponent {
    return [self.name lastPathComponent];
}

- (NSString *)extension {
    return [self.name pathExtension];
}

@end
