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

@class PKTokenizer;

/*!
    @class      PKAssembly 
    @brief      An Abstract class. A <tt>PKAssembly</tt> maintains a stream of language elements along with stack and target objects.
    @details    <p>Parsers use delegates to record progress at recognizing language elements from assembly's string.</p>
                <p>Note that <tt>PKAssembly</tt> is an abstract class and may not be instantiated directly. Subclasses include <tt>PKAssembly</tt> and <tt>PKCharAssembly</tt>.</p>
*/
@interface PKAssembly : NSObject

+ (instancetype)assembly;

- (instancetype)init;

/*!
    @brief      Removes the object at the top of this assembly's stack and returns it.
    @details    Note this returns an object from this assembly's stack, not from its stream of elements (tokens or chars depending on the type of concrete <tt>PKAssembly</tt> subclass of this object).
    @result     the object at the top of this assembly's stack
*/
- (id)pop;

/*!
    @brief      Pushes an object onto the top of this assembly's stack.
    @param      object object to push
*/
- (void)push:(id)object;

/*!
    @brief      Returns true if this assembly's stack is empty.
    @result     true, if this assembly's stack is empty
*/
- (BOOL)isStackEmpty;

/*!
    @brief      Returns a vector of the elements on this assembly's stack that appear before a specified fence.
    @details    <p>Returns a vector of the elements on this assembly's stack that appear before a specified fence.</p>
                <p>Sometimes a parser will recognize a list from within a pair of parentheses or brackets. The parser can mark the beginning of the list with a fence, and then retrieve all the items that come after the fence with this method.</p>
    @param      fence object that indicates the limit of elements returned from this assembly's stack
    @result     Array of the elements above the specified fence
*/
- (NSArray *)objectsAbove:(id)fence;

/*!
    @property   stack
    @brief      This assembly's stack.
*/
@property (nonatomic, readonly, retain) NSMutableArray *stack;

/*!
    @property   target
    @brief      This assembly's target.
    @details    The object identified as this assembly's "target". Clients can set and retrieve a target, which can be a convenient supplement as a place to work, in addition to the assembly's stack. For example, a parser for an HTML file might use a web page object as its "target". As the parser recognizes markup commands like &lt;head>, it could apply its findings to the target.
*/
@property (nonatomic, retain) id target;

@property (nonatomic) BOOL preservesWhitespaceTokens;
@property (nonatomic) BOOL gathersConsumedTokens;
@end
