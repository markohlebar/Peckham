//
//  MHImportBusterPlugin.m
//  MHImportBusterPlugin
//
//  Created by marko.hlebar on 03/01/14.
//    Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Carbon/Carbon.h>
#import <MHImportBuster/MHImportBuster.h>
#import "MHImportBusterPlugin.h"
#import "MHXcodeDocumentNavigator.h"
#import "XCFXcodePrivate.h"
#import "MHXcodeIssuesParser.h"
#import "MHHeaderCache.h"
#import "NSString+Extensions.h"
#import "MHImportListViewController.h"

NSString * const MHImportBusterPluginShowImportListNotification = @"MHImportBusterPluginShowImportListNotification";

static MHImportBusterPlugin *sharedPlugin;

@interface MHImportBusterPlugin() <MHDocumentObserverDelegate>
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSPopover *popover;
@end

@implementation MHImportBusterPlugin
{
    MHDocumentObserver *_documentObserver;
    MHDocumentLOCObserver *_locObserver;
}
OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData) {
    
    EventHotKeyID hkRef;
    GetEventParameter(anEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkRef),NULL,&hkRef);
    switch (hkRef.id) {
        case 1:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:MHImportBusterPluginShowImportListNotification
                                                                object:nil];
        }
            break;

    }
    return noErr;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        [self loadKeyboardHandler];
        [self registerObserver];
        [self loadHeaderCache];
    }
    return self;
}

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showImportList:)
                                                 name:MHImportBusterPluginShowImportListNotification
                                               object:nil];
}

- (void)loadHeaderCache {
    [MHHeaderCache sharedCache];
}

- (void)loadKeyboardHandler {
    EventHotKeyRef myHotKeyRef;
    EventHotKeyID myHotKeyID;
    EventTypeSpec eventType;
    
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    InstallApplicationEventHandler(&myHotKeyHandler,1,&eventType,NULL,NULL);

    myHotKeyID.signature='mhk1';
    myHotKeyID.id=1;

    RegisterEventHotKey(kVK_ANSI_P, cmdKey+controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
}

#pragma mark - Actions 

- (void)showImportList:(NSNotification *)notification {
    [MHImportListViewController present];
}

- (void)removeDuplicateImports {
    MHFile *file = [MHFile fileWithCurrentFilePath];
    [file removeDuplicateImports];
}

- (void)sortImports {
    MHFile *file = [MHFile fileWithCurrentFilePath];
    [file sortImportsAlphabetically];
}

@end