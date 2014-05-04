//
//  MHImportListView.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MHImportListView : NSView <NSTableViewDelegate, NSTableViewDataSource>
@property (nonatomic, strong) NSArray *headers;
@end
