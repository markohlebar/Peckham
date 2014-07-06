//
//  MHConcreteSourceFile.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 06/07/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHConcreteSourceFile.h"

@interface MHConcreteSourceFile ()
@property (nonatomic, copy) NSString *name;
@end

@implementation MHConcreteSourceFile
+ (instancetype)sourceFileWithName:(NSString *)name {
    return [[self alloc] initWithName:name];
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name.copy;
    }
    return self;
}

- (NSString *)lastPathComponent {
    return [self.name lastPathComponent];
}

- (NSString *)extension {
    return [self.name pathExtension];
}

- (NSUInteger)hash {
    return [self.name hash];
}

- (BOOL)isEqual:(MHConcreteSourceFile *)other {
    return (other == self || [other.name isEqualToString:self.name]);
}

@end
