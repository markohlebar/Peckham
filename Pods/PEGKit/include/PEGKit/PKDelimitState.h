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

#import <PEGKit/PKTokenizerState.h>

@class PKSymbolRootNode;
@class PKDelimitDescriptorCollection;

/*!
    @class      PKDelimitState 
    @brief      A delimit state returns a delimited string token from a reader
    @details    This state will collect characters until it sees a match to the end marker that corresponds to the start marker the tokenizer used to switch to this state.
*/
@interface PKDelimitState : PKTokenizerState

/*!
    @brief      Adds the given strings as a delimited string start and end markers. both may be multi-char
    @details    <tt>start</tt> and <tt>end</tt> may be different strings. e.g. <tt>&lt;#</tt> and <tt>#&gt;</tt>.
    @param      start a single- or multi-character marker that should be recognized as the start of a multi-line comment
    @param      end a single- or multi-character marker that should be recognized as the end of a multi-line comment that began with <tt>start</tt>
    @param      set of characters allowed to appear within the delimited string or <tt>nil</tt> to allow any non-newline characters
*/
- (void)addStartMarker:(NSString *)start endMarker:(NSString *)end allowedCharacterSet:(NSCharacterSet *)set;

/*!
    @property   balancesEOFTerminatedStrings
    @brief      if YES, this state will append a matching end delimiter marker (e.g. <tt>--></tt> or <tt>%></tt>) to strings terminated by EOF. 
    @details	Default is NO.
*/
@property (nonatomic) BOOL balancesEOFTerminatedStrings;

@property (nonatomic) BOOL allowsNestedMarkers;
@end
