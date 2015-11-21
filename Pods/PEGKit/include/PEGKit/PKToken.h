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
#import <PEGKit/PKTypes.h>

/*!
    @typedef    enum PKTokenType
    @brief      Indicates the type of a <tt>PKToken</tt>
    @var        PKTokenTypeEOF A constant indicating that the endo fo the stream has been read.
    @var        PKTokenTypeNumber A constant indicating that a token is a number, like <tt>3.14</tt>.
    @var        PKTokenTypeQuotedString A constant indicating that a token is a quoted string, like <tt>"Launch Mi"</tt>.
    @var        PKTokenTypeSymbol A constant indicating that a token is a symbol, like <tt>"&lt;="</tt>.
    @var        PKTokenTypeWord A constant indicating that a token is a word, like <tt>cat</tt>.
    @var        PKTokenTypeWhitespace A constant indicating that a token is whitespace, like <tt>\t</tt>.
    @var        PKTokenTypeComment A constant indicating that a token is a comment, like <tt>// this is a hack</tt>.
    @var        PKTokenTypeDelimtedString A constant indicating that a token is a delimitedString, like <tt><#foo></tt>.
*/
typedef enum {
    PKTokenTypeEOF = -1,
    PKTokenTypeInvalid = 0,
    PKTokenTypeNumber = 1,
    PKTokenTypeQuotedString = 2,
    PKTokenTypeSymbol = 3,
    PKTokenTypeWord = 4,
    PKTokenTypeWhitespace = 5,
    PKTokenTypeComment = 6,
    PKTokenTypeDelimitedString = 7,
    PKTokenTypeURL = 8,
    PKTokenTypeEmail = 9,
#if PK_PLATFORM_TWITTER_STATE
    PKTokenTypeTwitter = 10,
    PKTokenTypeHashtag = 11,
#endif
    PKTokenTypeEmpty = 12,
    PKTokenTypeAny = 13,
} PKTokenType;

/*!
    @class      PKToken
    @brief      A token represents a logical chunk of a string.
    @details    For example, a typical tokenizer would break the string <tt>"1.23 &lt;= 12.3"</tt> into three tokens: the number <tt>1.23</tt>, a less-than-or-equal symbol, and the number <tt>12.3</tt>. A token is a receptacle, and relies on a tokenizer to decide precisely how to divide a string into tokens.
*/
@interface PKToken : NSObject <NSCopying>

/*!
    @brief      Factory method for creating a singleton <tt>PKToken</tt> used to indicate that there are no more tokens.
    @result     A singleton used to indicate that there are no more tokens.
*/
+ (PKToken *)EOFToken;

/*!
    @brief      Factory convenience method for creating an autoreleased token.
    @param      t the type of this token.
    @param      s the string value of this token.
    @param      n the number falue of this token.
    @result     an autoreleased initialized token.
*/
+ (instancetype)tokenWithTokenType:(PKTokenType)t stringValue:(NSString *)s doubleValue:(double)n;

/*!
    @brief      Designated initializer. Constructs a token of the indicated type and associated string or numeric values.
    @param      t the type of this token.
    @param      s the string value of this token.
    @param      n the number falue of this token.
    @result     an autoreleased initialized token.
*/
- (instancetype)initWithTokenType:(PKTokenType)t stringValue:(NSString *)s doubleValue:(double)n;

/*!
    @brief      Returns true if the supplied object is an equivalent <tt>PKToken</tt>, ignoring differences in case.
    @param      obj the object to compare this token to.
    @result     true if <tt>obj</tt> is an equivalent <tt>PKToken</tt>, ignoring differences in case.
*/
- (BOOL)isEqualIgnoringCase:(id)obj;

/*!
    @brief      Returns more descriptive textual representation than <tt>-description</tt> which may be useful for debugging puposes only.
    @details    Usually of format similar to: <tt>&lt;QuotedString "Launch Mi"></tt>, <tt>&lt;Word cat></tt>, or <tt>&lt;Number 3.14></tt>
    @result     A textual representation including more descriptive information than <tt>-description</tt>.
*/
- (NSString *)debugDescription;

/*!
    @property   number
    @brief      True if this token is the EOF singleton token. getter=isEOF
*/
@property (nonatomic, readonly) BOOL isEOF;

/*!
    @property   number
    @brief      True if this token is a number.
*/
@property (nonatomic, readonly) BOOL isNumber;

/*!
    @property   quotedString
    @brief      True if this token is a quoted string. getter=isQuotedString
*/
@property (nonatomic, readonly) BOOL isQuotedString;

/*!
    @property   symbol
    @brief      True if this token is a symbol. getter=isSymbol
*/
@property (nonatomic, readonly) BOOL isSymbol;

/*!
    @property   word
    @brief      True if this token is a word. getter=isWord
*/
@property (nonatomic, readonly) BOOL isWord;

/*!
    @property   whitespace
    @brief      True if this token is whitespace. getter=isWhitespace
*/
@property (nonatomic, readonly) BOOL isWhitespace;

/*!
    @property   comment
    @brief      True if this token is a comment. getter=isComment
*/
@property (nonatomic, readonly) BOOL isComment;

/*!
    @property   delimitedString
    @brief      True if this token is a delimited string. getter=isDelimitedString
*/
@property (nonatomic, readonly) BOOL isDelimitedString;

/*!
    @property   URL
    @brief      True if this token is a URL. getter=isURL
*/
@property (nonatomic, readonly) BOOL isURL;

/*!
    @property   email
    @brief      True if this token is an email address. getter=isEmail
*/
@property (nonatomic, readonly) BOOL isEmail;

#if PK_PLATFORM_TWITTER_STATE
/*!
    @property   twitter
    @brief      True if this token is an twitter handle. getter=isTwitter
*/
@property (nonatomic, readonly) BOOL isTwitter;

/*!
    @property   hashtaag
    @brief      True if this token is an twitter hashtag. getter=isHashtag
*/
@property (nonatomic, readonly) BOOL isHashtag;
#endif

/*!
    @property   tokenType
    @brief      The type of this token.
*/
@property (nonatomic, readonly) PKTokenType tokenType;

/*!
    @property   doubleValue
    @brief      The numeric value of this token.
*/
@property (nonatomic, readonly) double doubleValue;

/*!
    @property   stringValue
    @brief      The string value of this token.
*/
@property (nonatomic, readonly, copy) NSString *stringValue;

/*!
    @property   stringValue
    @brief      If a QuotedString, the string value of this token minus the quotes. Otherwise the stringValue.
 */
@property (nonatomic, readonly, copy) NSString *quotedStringValue;

/*!
    @property   value
    @brief      Returns an object that represents the value of this token.
*/
@property (nonatomic, readonly, copy) id value;

/*!
    @property   offset
    @brief      The character offset of this token in the original source string.
*/
@property (nonatomic, readonly) NSUInteger offset;

/*!
    @property   lineNumber
    @brief      The line number of this token in the original source string.
*/
@property (nonatomic, readonly) NSUInteger lineNumber;

/*!
    @property   tokenKind
    @brief      The kind of this token.
*/
@property (nonatomic) NSInteger tokenKind;
@end
