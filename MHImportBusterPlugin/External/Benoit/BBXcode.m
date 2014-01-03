//
//  BBXcode.m
//  BBUncrustifyPlugin
//
//  Created by Benoît on 16/03/13.
//
//

#import "BBXcode.h"
//#import "BBUncrustify.h"

NSArray *BBMergeContinuousRanges(NSArray* ranges) {
    if (ranges.count == 0) return nil;
    
    NSMutableIndexSet *mIndexes = [NSMutableIndexSet indexSet];
    for (NSValue *rangeValue in ranges) {
        NSRange range = [rangeValue rangeValue];
        [mIndexes addIndexesInRange:range];
    }
    
    NSMutableArray *mergedRanges = [NSMutableArray array];
    [mIndexes enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        [mergedRanges addObject:[NSValue valueWithRange:range]];
    }];
    return [mergedRanges copy];
}

@implementation BBXcode

+ (id)currentEditor {
    id currentWindowController = [[NSApp keyWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = currentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }
    return nil;
}

+ (NSArray *)selectedObjCFileNavigableItems {
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
                if ([selectedObject isKindOfClass:NSClassFromString(@"IDEFileNavigableItem")]) {
                    IDEFileNavigableItem *fileNavigableItem = selectedObject;
                    NSString *uti = fileNavigableItem.documentType.identifier;
                    if ([uti isEqualToString:(NSString *)kUTTypeObjectiveCSource] || [uti isEqualToString:(NSString *)kUTTypeCHeader]) {
                        [mutableArray addObject:fileNavigableItem];
                    }
                }
            }
        }
    }

    if (mutableArray.count) {
        return [mutableArray copy];
    }
    return nil;
}

@end
