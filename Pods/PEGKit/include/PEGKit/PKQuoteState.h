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
    @class      PKQuoteState 
    @brief      A quote state returns a quoted string token from a reader
    @details    This state will collect characters until it sees a match to the character that the tokenizer used to switch to this state. For example, if a tokenizer uses a double- quote character to enter this state, then <tt>-nextToken</tt> will search for another double-quote until it finds one or finds the end of the reader.
*/
@interface PKQuoteState : PKTokenizerState

/*!
    @property   allowsEOFTerminatedQuotes
    @brief      if YES, this state will consider unbalanced quoted strings (quoted strings terminated by EOF) as a quoted string rather than a <tt>'</tt> or <tt>"</tt> symbol token followed by zero or more tokens. Default is YES.
*/
@property (nonatomic) BOOL allowsEOFTerminatedQuotes;

/*!
    @property   balancesEOFTerminatedQuotes
    @brief      if YES, this state will append a matching quote char (<tt>'</tt> or <tt>"</tt>) to strings terminated by EOF. Default is NO.
*/
@property (nonatomic) BOOL balancesEOFTerminatedQuotes;

/*!
    @property   usesCSVStyleEscaping
    @brief      if NO, this state will use slash-style escaping (<tt>\'</tt> or <tt>\"</tt>). If YES, it will use CSV-style escaping, by doubling the quote character (<tt>''</tt> or <tt>""</tt>). The default behaviour is NO (slash-style).
*/
@property (nonatomic) BOOL usesCSVStyleEscaping;
@end
