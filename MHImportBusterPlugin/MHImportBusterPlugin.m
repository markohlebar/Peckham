//
//  MHImportBusterPlugin.m
//  MHImportBusterPlugin
//
//  Created by marko.hlebar on 03/01/14.
//    Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHImportBusterPlugin.h"
#import "BBXcode.h"
#import <MHImportBuster/MHImportBuster.h>

static MHImportBusterPlugin *sharedPlugin;

@interface MHImportBusterPlugin()

@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation MHImportBusterPlugin

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
    }
    return self;
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
