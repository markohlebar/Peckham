//
//  MHOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 11/06/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHOperation.h"

@implementation MHOperation
{
    BOOL _finished;
    BOOL _executing;
    BOOL _canceled;
}

-(id) init {
    self = [super init];
    if (self) {
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

- (BOOL) isCancelled {
    return _canceled;
}

-(void) cancel {
    _canceled = YES;
}

@end
