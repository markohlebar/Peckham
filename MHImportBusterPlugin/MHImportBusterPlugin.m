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
            NSLog(@"Event 1 was triggered!");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveDuplicateImports" object:nil];
            break;
        case 2:
            NSLog(@"Event 2 was triggered!");
            break;
    }
    return noErr;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        }
        
        [self loadKeyboardHandler];
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
    NSArray *issues = [MHXcodeIssuesParser parseDictionary:notification.userInfo];
    
    for (IDEIssue *issue in issues) {
        if (issue.severity == IDEIssueSeverityError) {
            if ([issue.fullMessage containsString:@"Use of undeclared identifier"]) {
                NSArray *components = [issue.fullMessage componentsSeparatedByString:@"'"];
                NSString *className = components.count > 1 ? components[1] : nil;
                
                NSLog(@"Class Name %@", className);
                
                MHHeaderCache *headerCache = [MHHeaderCache new];
                NSString *header = [headerCache headerForClassName:className];
                
                NSLog(@"HEADER FOUND: %@", header);
//                if (header) {
//                    [self addImport:header];
//                }
            }
            else if([issue.fullMessage containsString:@"Unknown type name"]) {
                NSArray *components = [issue.fullMessage componentsSeparatedByString:@"'"];
                NSString *className = components.count > 1 ? components[1] : nil;
                
                NSLog(@"Class Name %@", className);
                
                MHHeaderCache *headerCache = [MHHeaderCache new];
                NSString *header = [headerCache headerForClassName:className];
                
                NSLog(@"HEADER FOUND: %@", header);
//                if (header) {
//                    [self addImport:header];
//                }
            }
            else if([issue.fullMessage containsString:@"No visible @interface for"]) {
                NSArray *components = [issue.fullMessage componentsSeparatedByString:@"'"];
                NSString *className = components.count > 1 ? components[1] : nil;
                NSString *methodName = components.count > 3 ? components[3] : nil;
                NSLog(@"Class Name %@", className);
                NSLog(@"Method Name %@", methodName);
                MHHeaderCache *headerCache = [MHHeaderCache new];
                NSString *header = [headerCache headerForMethod:methodName
                                                   forClassName:className];
                
                NSLog(@"HEADER FOUND FOR METHOD: %@", header);
//                if (header) {
//                    [self addImport:header];
//                }
            }
        }
    }
    
   // [self addImport];
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

    RegisterEventHotKey(kVK_ANSI_P, cmdKey+controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showImportList:)
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

#pragma mark - Actions 

- (void)showImportList:(NSNotification *)notification {
    [MHImportListViewController present];
    
    [MHHeaderCache allFrameworksInCurrentWorkspace];
}

- (void)removeDuplicateImports {
    MHFile *file = [MHFile fileWithCurrentFilePath];
    [file removeDuplicateImports];
}

-(void) sortImports {
    MHFile *file = [MHFile fileWithCurrentFilePath];
    [file sortImportsAlphabetically];
}

@end