//
//  MHDocumentLOCObserverSpec.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 26/01/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "MHDocumentObserver.h"
#import "MHDocumentLOCObserver.h"

@interface MHDocumentLOCObserver (Testing)
- (void)textStorageDidChange:(NSNotification *)notification;
@end

SPEC_BEGIN(MHDocumentLOCObserverSpec)

describe(@"MHDocumentLOCObserver", ^{

    __block MHDocumentLOCObserver *observer = nil;
    __block id mockDelegate;
    beforeEach(^{
        observer = [[MHDocumentLOCObserver alloc] init];
        observer.maxLinesOfCode = 2;
        
        mockDelegate = [KWMock mockForProtocol:@protocol(MHDocumentObserverDelegate)];
        observer.delegate = mockDelegate;

    });
    
    specify(^{
        [[observer should] beNonNil];
    });
    
//    it(@"Should receive a NSTextDidChangeNotification", ^{
//        //TODO: check about mocking NSNotificationCenter
//        id mockTextView = [NSTextView mock];
//        id mockNotification = [NSNotification mock];
//        [mockNotification stub:@selector(object) andReturn:mockTextView];
//        [observer textStorageDidChange:mockNotification];
//    });
    
    it(@"Should call the delegate if more than max lines of code is entered", ^{
        [[mockDelegate should] receive:@selector(documentObserverDidReachConstraint:) withArguments:observer, nil];
        NSString *mockText = @"\n\n\n";
        [observer textDidChange:mockText];
    });
    
    it(@"Should not call the delegate if not more than max lines of code was entered", ^{
        [[mockDelegate shouldNot] receive:@selector(documentObserverDidReachConstraint:) withArguments:observer, nil];
        NSString *mockText = @"";
        [observer textDidChange:mockText];
    });
    
    it(@"Should not call the delegate if equal to max lines of code was entered", ^{
        [[mockDelegate shouldNot] receive:@selector(documentObserverDidReachConstraint:) withArguments:observer, nil];
        NSString *mockText = @"\n";
        [observer textDidChange:mockText];
    });
    
});

SPEC_END