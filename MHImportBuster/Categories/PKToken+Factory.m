//
//  PKToken+Factory.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 09/02/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "PKToken+Factory.h"

@implementation PKToken (Factory)

+(PKToken*) forwardSlash {
    static PKToken *_forwardSlashToken = nil;
    if (!_forwardSlashToken) {
        _forwardSlashToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"/" floatValue:0];
    }
    return _forwardSlashToken;
}

+(PKToken*) dot {
    static PKToken *_dotToken = nil;
    if  (!_dotToken) {
        _dotToken = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"." floatValue:0];
    }
    return _dotToken;
}

@end
