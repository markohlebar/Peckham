//
//  MHDocumentLOCObserver.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 26/01/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHDocumentObserver.h"
#import "MHXcodeDocumentNavigator.h"
#import "XCFXcodePrivate.h"

@implementation MHDocumentObserver

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSTextDidChangeNotification
                                                  object:nil];
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textDidChangeNotification:)
                                                     name:NSTextDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)textDidChangeNotification:(NSNotification*) notification {
//    if (![[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
//        return;
//    }
//    
    NSTextView *textView = notification.object;
    [self textDidChange:textView.textStorage.string];
    
//    IDESourceCodeDocument *document = [MHXcodeDocumentNavigator currentSourceCodeDocument];
//    DVTSourceTextStorage *textStorage = (DVTSourceTextStorage*)textView.textStorage;
//    
//    [textStorage replaceCharactersInRange:NSMakeRange(0, 10)
//                               withString:@"blablablabla"
//                          withUndoManager:[document undoManager]];    
}

- (void)textDidChange:(NSString *)text {
  
}

- (void)notifyDelegateDidReachConstraint {
    if ([_delegate respondsToSelector:@selector(documentObserverDidReachConstraint:)]) {
        [_delegate documentObserverDidReachConstraint:self];
    }
}

- (NSString *)constraintDescription {
    return nil;
}

@end