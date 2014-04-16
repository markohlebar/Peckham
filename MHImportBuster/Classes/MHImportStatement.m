//
//  MHImportLOC.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import "MHImportStatement.h"
@implementation MHImportStatement
- (id)value {
	if (![self containsCannonicalTokens]) {
		return nil;
	}
    
	if (!_value) {
		__block NSMutableString *value = [NSMutableString string];
		[_tokens enumerateObjectsUsingBlock: ^(PKToken *token, NSUInteger idx, BOOL *stop) {
            [value appendString:token.stringValue];
            if ([token.stringValue isEqual:@"import"]) {
		        [value appendString:@" "];
			}
		}];
		_value = value;
	}
	return _value;
}

@end

@implementation MHFrameworkImportStatement
static NSArray *MHFrameworkImportLOCTokens = nil;
+ (NSArray *)cannonicalTokens {
	if (!MHFrameworkImportLOCTokens) {
		MHFrameworkImportLOCTokens = @[
                                       [PKToken hash],
                                       [PKToken tokenWithTokenType:PKTokenTypeWord
                                                       stringValue:@"import"
                                                        floatValue:0],
                                       [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                                       stringValue:@"<"
                                                        floatValue:0],
                                       [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                                       stringValue:@">"
                                                        floatValue:0]
                                       ];
	}
	return MHFrameworkImportLOCTokens;
}

@end

@implementation MHProjectImportStatement
static NSArray *MHProjectImportLOCTokens = nil;
+ (NSArray *)cannonicalTokens {
	if (!MHProjectImportLOCTokens) {
		MHProjectImportLOCTokens = @[
                                     [PKToken hash],
                                     [PKToken tokenWithTokenType:PKTokenTypeWord
                                                     stringValue:@"import"
                                                      floatValue:0],
                                     [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                                     stringValue:@"\""
                                                      floatValue:0],
                                     [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                                     stringValue:@"\""
                                                      floatValue:0]
                                     ];
	}
	return MHProjectImportLOCTokens;
}

@end
