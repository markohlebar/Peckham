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

static MHImportBusterPlugin *sharedPlugin;

@interface MHImportBusterPlugin() <MHDocumentObserverDelegate>

@property (nonatomic, strong) NSBundle *bundle;
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
            
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Sort Imports" action:@selector(sortImports) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
            
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Find Missing Imports" action:@selector(findMissingImports) keyEquivalent:@""];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
        
        [self addIssuesObserver];
        
//        [self loadKeyboardHandler];
        
//        _documentObserver = [[MHDocumentObserver alloc] init];
        
//        _locObserver = [[MHDocumentLOCObserver alloc] init];
//        _locObserver.delegate = self;
//        _locObserver.maxLinesOfCode = 150;
        
    }
    return self;
}

-(void) addIssuesObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(coalesceIssues:)
                                                 name:@"IDEIssueManagerDidCoalesceIssuesNotification"
                                               object:nil];
}

-(void) coalesceIssues:(NSNotification *)notification {
//    NSLog(@"Coalescing:\n\n%@", notification.userInfo);
    [MHXcodeIssuesParser parseDictionary:notification.userInfo];
    
    [self addImport];
}

-(void) findMissingImports {
    NSTask *task = [[NSTask alloc] init];
    
    task.launchPath = @"/Users/mhlebar/Documents/clang-llvm/build/bin/loop-convert";
//    task.arguments = @[
//                       [NSString stringWithFormat:@"--style=%@", style],
//                       @"-i",
    task.arguments = @[
                       [self currentFilePath],
                       @"--"
                       ];
    
    [task launch];
    [task waitUntilExit];
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

#pragma mark - MHDocumentObserverDelegate 

-(void) documentObserverDidReachConstraint:(MHDocumentObserver *)documentObserver {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Constraint reached"
                                     defaultButton:@"Continue"
                                   alternateButton:@""
                                       otherButton:@""
                         informativeTextWithFormat:documentObserver.constraintDescription];
    [alert runModal];
}

- (NSString *)currentFilePath {
    if (![[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        return nil;
    }
    
    //TODO: produce a separate document for each filePath. note when any changes occur
    //on the observers.
    
    IDESourceCodeEditor *editor = [MHXcodeDocumentNavigator currentEditor];
    IDESourceCodeDocument *document = [editor sourceCodeDocument];
    return [[document fileURL] path];
}

- (void) addImport {
    NSString *filePath = [self currentFilePath];
    if(filePath) {
        MHFile *file = [MHFile fileWithPath:filePath];
        [file addImport:@"#import \"Header.h\""];
    }
}

// Sample Action, for menu item:
- (void)removeDuplicateImports {
    NSString *filePath = [self currentFilePath];
    if(filePath) {
        MHFile *file = [MHFile fileWithPath:filePath];
        [file removeDuplicateImports];
    }
}

-(void) sortImports {
    NSString *filePath = [self currentFilePath];
    if(filePath) {
        MHFile *file = [MHFile fileWithPath:filePath];
        [file sortImportsAlphabetically];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end