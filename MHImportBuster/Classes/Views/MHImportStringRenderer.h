//
//  MHImportStringRenderer.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 02/05/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHImportStringRenderer : NSObject

+ (NSAttributedString *)renderHighlightedStringForImport:(NSString *)import
                                            searchString:(NSString *)searchString
                                                selected:(BOOL)selected;

+ (NSAttributedString *)renderStringForSearchString:(NSString *)searchString;

@end
