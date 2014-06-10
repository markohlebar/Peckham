//
//  MHImportLOC.m
//  MHImportBuster
//
//  Created by marko.hlebar on 27/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//

#import "MHImportStatement.h"
#import "PKToken+Factory.h"

@implementation MHImportStatement
- (id)value {
	if (![self containsCannonicalTokens]) {
		return nil;
	}
    
	if (!_value) {
		__block NSMutableString *value = [NSMutableString string];
		[_tokens enumerateObjectsUsingBlock: ^(PKToken *token, NSUInteger idx, BOOL *stop) {
            if (![token isEqual:[PKToken whitespace]]) {
                NSString *tokenString = token.stringValue;
                [value appendString:tokenString];
                
                if ([tokenString isEqual:@"import"]) {
                    [value appendString:@" "];
                }
            }
		}];
		_value = value;
	}
	return _value;
}

- (BOOL)processToken:(PKToken *)token {
	NSArray *cannonicalTokens = [[self class] cannonicalTokens];
    BOOL shouldAddToken = YES;
    if(_tokens.count < 3 || [token isEqual:[PKToken whitespace]]) {
        shouldAddToken = [cannonicalTokens[_tokens.count] isEqual:token];
    }
    if (shouldAddToken){
        [_tokens addObject:token];
        return YES;
    }
    return NO;
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
