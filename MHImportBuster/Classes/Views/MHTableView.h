//
//  MHTableView.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 04/05/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MHTableView;
@protocol MHTableViewDelegate <NSTableViewDelegate>
- (void)tableView:(MHTableView *)tableView onKeyPress:(NSEvent *)key;
@end

@interface MHTableView : NSTableView
@property (nonatomic, weak) id <MHTableViewDelegate> delegate;
@end
