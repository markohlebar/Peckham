//
//  MHImportBusterPlugin.m
//  MHImportBusterPlugin
//
//  Created by marko.hlebar on 03/01/14.
//    Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportBusterPlugin.h"
#import "BBXcode.h"
#import <Carbon/Carbon.h>
#import <MHImportBuster/MHImportBuster.h>

static MHImportBusterPlugin *sharedPlugin;

@interface MHImportBusterPlugin()

@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation MHImportBusterPlugin

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData) {
    
    EventHotKeyID hkRef;
    GetEventParameter(anEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkRef),NULL,&hkRef);
    switch (hkRef.id) {
        case 1:
            NSLog(@"Event 1 was triggered!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveDuplicateImports" object:nil];
            break;
        case 2:
            NSLog(@"Event 2 was triggered!");
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

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.

        // Sample Menu Item:
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"File"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Remove Duplicate Imports" action:@selector(removeDuplicateImports) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
        
//        [self loadKeyboardHandler];
    }
    return self;
}

-(void) loadKeyboardHandler {
    EventHotKeyRef myHotKeyRef;
    EventHotKeyID myHotKeyID;
    EventTypeSpec eventType;
    
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;
    InstallApplicationEventHandler(&myHotKeyHandler,1,&eventType,NULL,NULL);

    myHotKeyID.signature='mhk1';
    myHotKeyID.id=1;

    RegisterEventHotKey(49, cmdKey+shiftKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeDuplicateImports)
                                                 name:@"RemoveDuplicateImports"
                                               object:nil];
}

// Sample Action, for menu item:
- (void)removeDuplicateImports
{
    if (![[BBXcode currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return;
    }
    
    IDESourceCodeEditor *editor = [BBXcode currentEditor];
    IDESourceCodeDocument *document = [editor sourceCodeDocument];
    NSString *filePath = [[document fileURL] path];
    
    MHFile *file = [MHFile fileWithPath:filePath];
    [file removeDuplicateImports];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
