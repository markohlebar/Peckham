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

/*!
    @class      PKWordState 
    @brief      A word state returns a word from a reader.
    @details    <p>Like other states, a tokenizer transfers the job of reading to this state, depending on an initial character. Thus, the tokenizer decides which characters may begin a word, and this state determines which characters may appear as a second or later character in a word. These are typically different sets of characters; in particular, it is typical for digits to appear as parts of a word, but not as the initial character of a word.</p>
                <p>By default, the following characters may appear in a word. The method setWordChars() allows customizing this.</p>
@code
     From     To
      'a'    'z'
      'A'    'Z'
      '0'    '9'
@endcode
                <p>as well as: minus sign <tt>-</tt>, underscore <tt>_</tt>, and apostrophe <tt>'</tt>.</p>
*/
@interface PKWordState : PKTokenizerState

/*!
    @brief      Establish characters in the given range as valid characters for part of a word after the first character. Note that the tokenizer must determine which characters are valid as the beginning character of a word.
    @param      yn true if characters in the given range are word characters
    @param      start the "start" character. e.g. <tt>'a'</tt> or <tt>65</tt>.
    @param      end the "end" character. <tt>'z'</tt> or <tt>90</tt>.
*/
- (void)setWordChars:(BOOL)yn from:(PKUniChar)start to:(PKUniChar)end;

/*!
    @brief      Informs whether the given character is recognized as a word character by this state.
    @param      cin the character to check
    @result     true if the given chracter is recognized as a word character
*/
- (BOOL)isWordChar:(PKUniChar)c;
@end
