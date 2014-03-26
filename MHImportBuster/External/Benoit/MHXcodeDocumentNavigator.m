//
//  Created by Benoît on 11/01/14.
//  Copyright (c) 2014 Pragmatic Code. All rights reserved.
//

#import "MHXcodeDocumentNavigator.h"

@implementation MHXcodeDocumentNavigator {}

#pragma mark - Helpers

+ (id)currentEditor {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }
    return nil;
}

+ (IDEWorkspaceDocument *)currentWorkspaceDocument {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];
    id document = [currentWindowController document];
    if (currentWindowController && [document isKindOfClass:NSClassFromString(@"IDEWorkspaceDocument")]) {
        return (IDEWorkspaceDocument *)document;
    }
    return nil;
}

+ (IDESourceCodeDocument *)currentSourceCodeDocument {
    if ([[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        IDESourceCodeEditor *editor = [MHXcodeDocumentNavigator currentEditor];
        return editor.sourceCodeDocument;
    }
    
    if ([[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        IDESourceCodeComparisonEditor *editor = [MHXcodeDocumentNavigator currentEditor];
        if ([[editor primaryDocument] isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
            IDESourceCodeDocument *document = (IDESourceCodeDocument *)editor.primaryDocument;
            return document;
        }
    }
    
    return nil;
}

+ (NSTextView *)currentSourceCodeTextView {
    if ([[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        IDESourceCodeEditor *editor = [MHXcodeDocumentNavigator currentEditor];
        return editor.textView;
    }
    
    if ([[MHXcodeDocumentNavigator currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        IDESourceCodeComparisonEditor *editor = [MHXcodeDocumentNavigator currentEditor];
        return editor.keyTextView;
    }
    
    return nil;
}

+ (NSArray *)selectedNavigableItems {
    NSMutableArray *mutableArray = [NSMutableArray array];
    id currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = currentWindowController;
        IDEWorkspaceTabController *workspaceTabController = [workspaceController activeWorkspaceTabController];
        IDENavigatorArea *navigatorArea = [workspaceTabController navigatorArea];
        id currentNavigator = [navigatorArea currentNavigator];
        
        if ([currentNavigator isKindOfClass:NSClassFromString(@"IDEStructureNavigator")]) {
            IDEStructureNavigator *structureNavigator = currentNavigator;
            for (id selectedObject in structureNavigator.selectedObjects) {
                if ([selectedObject isKindOfClass:NSClassFromString(@"IDENavigableItem")]) {
                    [mutableArray addObject:selectedObject];
                }
            }
        }
    }
    
    if (mutableArray.count) {
        return [NSArray arrayWithArray:mutableArray];
    }
    return nil;
}

+ (NSArray *)selectedSourceCodeFileNavigableItems {
    NSMutableArray *mutableArray = [NSMutableArray array];
    id currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = currentWindowController;
        IDEWorkspaceTabController *workspaceTabController = [workspaceController activeWorkspaceTabController];
        IDENavigatorArea *navigatorArea = [workspaceTabController navigatorArea];
        id currentNavigator = [navigatorArea currentNavigator];
        
        if ([currentNavigator isKindOfClass:NSClassFromString(@"IDEStructureNavigator")]) {
            IDEStructureNavigator *structureNavigator = currentNavigator;
            for (id selectedObject in structureNavigator.selectedObjects) {
                NSArray *arrayOfFiles = [self recursivlyCollectFileNavigableItemsFrom:selectedObject];
                if (arrayOfFiles.count) {
                    [mutableArray addObjectsFromArray:arrayOfFiles];
                }
            }
        }
    }
    
    if (mutableArray.count) {
        return [NSArray arrayWithArray:mutableArray];
    }
    return nil;
}

+ (NSArray *)recursivlyCollectFileNavigableItemsFrom:(IDENavigableItem *)selectedObject {
    id items = nil;
    
    if ([selectedObject isKindOfClass:NSClassFromString(@"IDEGroupNavigableItem")]) {
        //|| [selectedObject isKindOfClass:NSClassFromString(@"IDEContainerFileReferenceNavigableItem")]) { //disallow project
        NSMutableArray *mItems = [NSMutableArray array];
        IDEGroupNavigableItem *groupNavigableItem = (IDEGroupNavigableItem *)selectedObject;
        for (IDENavigableItem *child in groupNavigableItem.childItems) {
            NSArray *childItems = [self recursivlyCollectFileNavigableItemsFrom:child];
            if (childItems.count) {
                [mItems addObjectsFromArray:childItems];
            }
        }
        items = mItems;
    }
    else if ([selectedObject isKindOfClass:NSClassFromString(@"IDEFileNavigableItem")]) {
        IDEFileNavigableItem *fileNavigableItem = (IDEFileNavigableItem *)selectedObject;
        NSString *uti = fileNavigableItem.documentType.identifier;
        if ([[NSWorkspace sharedWorkspace] type:uti conformsToType:(NSString *)kUTTypeSourceCode]) {
            items = @[fileNavigableItem];
        }
    }
    
    return items;
}

+ (NSArray *)containerFolderURLsForNavigableItem:(IDENavigableItem *)navigableItem {
    NSMutableArray *mArray = [NSMutableArray array];
    
    do {
        NSURL *folderURL = nil;
        id representedObject = navigableItem.representedObject;
        if ([navigableItem isKindOfClass:NSClassFromString(@"IDEGroupNavigableItem")]) {
            // IDE-GROUP (a folder in the navigator)
            IDEGroup *group = (IDEGroup *)representedObject;
            folderURL = group.resolvedFilePath.fileURL;
        } else if ([navigableItem isKindOfClass:NSClassFromString(@"IDEContainerFileReferenceNavigableItem")]) {
            // CONTAINER (an Xcode project)
            IDEFileReference *fileReference = representedObject;
            folderURL = [fileReference.resolvedFilePath.fileURL URLByDeletingLastPathComponent];
        } else if ([navigableItem isKindOfClass:NSClassFromString(@"IDEKeyDrivenNavigableItem")]) {
            // WORKSPACE (root: Xcode project or workspace)
            IDEWorkspace *workspace = representedObject;
            folderURL = [workspace.representingFilePath.fileURL URLByDeletingLastPathComponent];
        }
        if (folderURL && ![mArray containsObject:folderURL]) [mArray addObject:folderURL];
        navigableItem = [navigableItem parentItem];
    } while (navigableItem != nil);
    
    if (mArray.count > 0) return [NSArray arrayWithArray:mArray];
    return nil;
}

+ (NSArray *)containerFolderURLsAncestorsToNavigableItem:(IDENavigableItem *)navigableItem {
    if (navigableItem) {
        return [MHXcodeDocumentNavigator containerFolderURLsForNavigableItem:navigableItem];
    }
    return nil;
}


@end
