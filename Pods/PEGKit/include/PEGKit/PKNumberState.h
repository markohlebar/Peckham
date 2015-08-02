// The MIT License (MIT)
// 
// Copyright (c) 2014 Todd Ditchendorf
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <PEGKit/PKTokenizerState.h>

@class PKSymbolRootNode;

/*!
    @class      PKNumberState 
    @brief      A number state returns a number from a reader.
    @details    This state's idea of a number allows an optional, initial minus sign, followed by one or more digits. A decimal point and another string of digits may follow these digits.
                If <tt>allowsScientificNotation</tt> is YES (default is NO) this state allows 'e' or 'E' followed by an (optionally explicityly positive or negative) integer to represent 10 to the indicated power. For example, this state will recognize <tt>1e2</tt> as equaling <tt>100</tt>.</p>
*/
@interface PKNumberState : PKTokenizerState

- (void)addPrefix:(NSString *)s forRadix:(NSUInteger)r;
- (void)removePrefix:(NSString *)s;

- (void)addSuffix:(NSString *)s forRadix:(NSUInteger)r;
- (void)removeSuffix:(NSString *)s;

- (void)addGroupingSeparator:(PKUniChar)c forRadix:(NSUInteger)r;
- (void)removeGroupingSeparator:(PKUniChar)c forRadix:(NSUInteger)r;

/*!
    @property   allowsTrailingDecimalSeparator
    @brief      If YES, numbers are allowed to end with a trialing decimal separator, e.g. <tt>42.<tt>
    @details    default is NO
*/
@property (nonatomic) BOOL allowsTrailingDecimalSeparator;

/*!
    @property   allowsScientificNotation
    @brief      If YES, supports exponential numbers like <tt>42.0e2<tt>, <tt>2E+6<tt>, or <tt>5.1e-6<tt>
    @details    default is NO
*/
@property (nonatomic) BOOL allowsScientificNotation;

/*!
    @property   allowsFloatingPoint
    @brief      If YES, supports floating point numbers like <tt>1.0<tt> or <tt>3.14<tt>. If NO, only whole numbers are allowed.
    @details    default is YES
*/
@property (nonatomic) BOOL allowsFloatingPoint;

@property (nonatomic) PKUniChar positivePrefix;
@property (nonatomic) PKUniChar negativePrefix;
@property (nonatomic) PKUniChar decimalSeparator;
@end
