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

+(PKToken*) curlyBraceLeft {
    static PKToken *_curlyBraceLeft = nil;
    if  (!_curlyBraceLeft) {
        _curlyBraceLeft = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"{" floatValue:0];
    }
    return _curlyBraceLeft;
}

+(PKToken*) curlyBraceRight {
    static PKToken *_curlyBraceRight = nil;
    if  (!_curlyBraceRight) {
        _curlyBraceRight = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"}" floatValue:0];
    }
    return _curlyBraceRight;
}

+(PKToken*) parenthesesLeft {
    static PKToken *_parenthesesLeft = nil;
    if  (!_parenthesesLeft) {
        _parenthesesLeft = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@"(" floatValue:0];
    }
    return _parenthesesLeft;
}

+(PKToken*) parenthesesRight {
    static PKToken *_parenthesesRight = nil;
    if  (!_parenthesesRight) {
        _parenthesesRight = [PKToken tokenWithTokenType:PKTokenTypeSymbol stringValue:@")" floatValue:0];
    }
    return _parenthesesRight;
}

+(PKToken*) placeholderWord {
    static PKToken *_placeholderWord = nil;
    if  (!_placeholderWord) {
        _placeholderWord = [PKToken tokenWithTokenType:PKTokenTypeWord
                                           stringValue:kMHTokenPlaceholderValue
                                            floatValue:0];
    }
    return _placeholderWord;
}

+(PKToken*) at {
    static PKToken *_at = nil;
    if  (!_at) {
        _at = [PKToken tokenWithTokenType:PKTokenTypeSymbol
                              stringValue:@"@"
                               floatValue:0];
    }
    return _at;
}

+(PKToken*) semicolon {
    static PKToken *_semicolon = nil;
    if  (!_semicolon) {
        _semicolon = [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                     stringValue:@";"
                                      floatValue:0];
    }
    return _semicolon;
}

+(PKToken*) plus {
    static PKToken *_plus = nil;
    if  (!_plus) {
        _plus = [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                stringValue:@"+"
                                 floatValue:0];
    }
    return _plus;
}

+(PKToken*) minus {
    static PKToken *_minus = nil;
    if  (!_minus) {
        _minus = [PKToken tokenWithTokenType:PKTokenTypeSymbol
                                 stringValue:@"-"
                                  floatValue:0];
    }
    return _minus;
}

@end
