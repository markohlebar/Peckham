//
//  MHDocumentObserver.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 26/01/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MHDocumentObserver;
@protocol MHDocumentObserverDelegate <NSObject>
@optional
- (void)documentObserverDidReachConstraint:(MHDocumentObserver *)documentObserver;
@end

@interface MHDocumentObserver : NSObject
@property (nonatomic, weak) id <MHDocumentObserverDelegate> delegate;

- (void)textDidChange:(NSString *)text;

- (void)notifyDelegateDidReachConstraint;

- (NSString *)constraintDescription;

@end
