//
//  MHImportStringRenderer.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 02/05/2016.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import "MHImportStringRenderer.h"

static NSString * const kImportString = @"#import";

@implementation MHImportStringRenderer

+ (NSAttributedString *)renderHighlightedStringForImport:(NSString *)import
                                            searchString:(NSString *)searchString
                                                selected:(BOOL)selected {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:import];
    
    if (selected) {
        [string addAttributes:[self whiteForegroundTextAttribute] range:NSMakeRange(0, import.length)];
    }
    
    // highlight matched substring
    if (searchString.length > 0) {
        NSArray *highlightedRanges = [self highlightedRangesForImport:import
                                                         searchString:searchString];
        for (NSValue *rangeValue in highlightedRanges) {
            NSRange range  = [rangeValue rangeValue];
            [string addAttributes:[self highlightedTextAttribute] range:range];
        }
    }
    
    return string;
}

+ (NSArray *)highlightedRangesForImport:(NSString *)import searchString:(NSString *)searchString {
    NSMutableArray *ranges = [NSMutableArray new];
    
    __block NSRange previousRange = NSMakeRange(kImportString.length, import.length - kImportString.length);
    [searchString enumerateSubstringsInRange:NSMakeRange(0, searchString.length)
                                     options:NSStringEnumerationByComposedCharacterSequences | NSStringEnumerationReverse
                                  usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                      NSRange highlightRange = [import rangeOfString:substring
                                                                             options:NSCaseInsensitiveSearch | NSBackwardsSearch
                                                                               range:previousRange];
                                      
                                      if (highlightRange.location != NSNotFound) {
                                          NSValue *rangeValue = [NSValue valueWithRange:highlightRange];
                                          [ranges addObject:rangeValue];
                                          previousRange.length = highlightRange.location - kImportString.length;
                                      }
                                  }];
    return ranges.copy;
}

+ (NSAttributedString *)renderStringForSearchString:(NSString *)searchString {
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:searchString];
    NSRange range = NSMakeRange(0, searchString.length);
    
    [string addAttributes:[self whiteForegroundTextAttribute] range:range];
    
    return string;
}

+ (NSDictionary *)whiteForegroundTextAttribute {
    static NSDictionary *_whiteForegroundTextAttribute = nil;
    if(!_whiteForegroundTextAttribute) {
        _whiteForegroundTextAttribute = @{NSForegroundColorAttributeName: [NSColor whiteColor]};
    }
    return _whiteForegroundTextAttribute;
}

+ (NSDictionary *)highlightedTextAttribute {
    static NSDictionary *_highlightedTextAttribute = nil;
    if(!_highlightedTextAttribute) {
        _highlightedTextAttribute = @{NSForegroundColorAttributeName: [NSColor blackColor],
                                      NSBackgroundColorAttributeName: [NSColor colorWithRed:235/255.f green:222/255.f blue:184/255.f alpha:1.0f],
                                      NSStrokeWidthAttributeName: @(-1)};
    }
    return _highlightedTextAttribute;
}

@end
