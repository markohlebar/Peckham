//  Copyright 2010 Todd Ditchendorf
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <ParseKit/PKAssembly.h>

@class PKTokenizer;
@class PKToken;

/*!
    @class      PKSTokenAssembly
    @brief      A <tt>PKSTokenAssembly</tt> is a <tt>PKAssembly</tt> whose elements are <tt>PKToken</tt>s.
    @details    <tt>PKToken</tt>s are, roughly, the chunks of text that a <tt>PKTokenizer</tt> returns.
*/
@interface PKSTokenAssembly : PKAssembly <NSCopying> {
    PKTokenizer *tokenizer;
    NSMutableArray *tokens;
    BOOL preservesWhitespaceTokens;
    BOOL gathersConsumedTokens;
}

/*!
    @brief      Convenience factory method for initializing an autoreleased assembly with the tokenizer <tt>t</tt> and its string
    @param      t tokenizer whose string will be worked on
    @result     an initialized autoreleased assembly
*/
+ (PKSTokenAssembly *)assemblyWithTokenizer:(PKTokenizer *)t;

/*!
    @brief      Initializes an assembly with the tokenizer <tt>t</tt> and its string
    @param      t tokenizer whose string will be worked on
    @result     an initialized assembly
*/
- (id)initWithTokenzier:(PKTokenizer *)t;

/*!
    @property   preservesWhitespaceTokens
    @brief      If true, whitespace tokens retreived from this assembly's tokenizier will be silently placed on this assembly's stack without being reported by -next or -peek. Default is false.
*/
@property (nonatomic) BOOL preservesWhitespaceTokens;
@property (nonatomic) BOOL gathersConsumedTokens;
@end
