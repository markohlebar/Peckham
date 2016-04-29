//
//  NSString+FuzzySearch.m
//  MHImportBuster
//
//  Created by Clément Padovani on 4/29/16.
//  Copyright © 2016 Marko Hlebar. All rights reserved.
//

#import "NSString+FuzzySearch.h"

static NSString * const kNSStringFuzzySearchFuzzyWildcardCharacter = @"*";

@implementation NSString (FuzzySearch)
// implementation per http://stackoverflow.com/a/15091550
- (NSString *)mh_fuzzifiedSearchString {
    NSMutableString *fuzzifiedSearchString = [NSMutableString string];

    [fuzzifiedSearchString appendString:kNSStringFuzzySearchFuzzyWildcardCharacter];

    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {

                              [fuzzifiedSearchString appendString:substring];

                              [fuzzifiedSearchString appendString:kNSStringFuzzySearchFuzzyWildcardCharacter];
                          }];

    return [fuzzifiedSearchString copy];
}
@end
