//
//  MHConcreteSourceOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHConcreteSourceOperation.h"

@implementation MHConcreteSourceOperation
{
    BOOL _finished;
    BOOL _executing;
    BOOL _canceled;
}

+ (instancetype)operationWithSource:(NSTextStorage *)source{
    return [[self alloc] initWithSource:source];
}

-(id) initWithSource:(NSTextStorage *)source {
    self = [super init];
    if (self) {
        _source = source;
        _canceled = NO;
        _finished = NO;
        _executing = NO;
    }
    return self;
}

-(void) execute {
    [self doesNotRecognizeSelector:_cmd];
}

-(void) start {
    _executing = YES;
    _finished = NO;
    
    [self execute];
    
    _finished = YES;
    _executing = NO;
}

-(BOOL) isConcurrent
{
    return YES;
}

-(BOOL) isExecuting
{
    return _executing;
}

-(BOOL) isFinished
{
    return _finished;
}

-(void) cancel {
    _canceled = YES;
}

@end
