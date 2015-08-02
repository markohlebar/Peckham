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

#import "PKSymbolNode.h"
#import "PKSymbolRootNode.h"

@interface PKSymbolNode ()
@property (nonatomic, retain, readwrite) NSString *ancestry;
@property (nonatomic, assign) PKSymbolNode *parent;  // this must be 'assign' to avoid retain loop leak
@property (nonatomic, retain) NSMutableDictionary *children;
@property (nonatomic, assign) PKUniChar character;
@property (nonatomic, retain) NSString *string;

- (void)determineAncestry;
@end

@implementation PKSymbolNode

- (id)initWithParent:(PKSymbolNode *)p character:(PKUniChar)c {
    self = [super init];
    if (self) {
        self.parent = p;
        self.character = c;
        self.children = [NSMutableDictionary dictionary];

        // this private property is an optimization. 
        // cache the NSString for the char to prevent it being constantly recreated in -determineAncestry
        self.string = [NSString stringWithFormat:@"%C", (unichar)_character];

        [self determineAncestry];
    }
    return self;
}


- (void)dealloc {
    self.parent = nil;
    self.ancestry = nil;
    self.string = nil;
    self.children = nil;
    [super dealloc];
}


- (void)determineAncestry {
    if (PKEOF == _parent.character) { // optimization for sinlge-char symbol (parent is symbol root node)
        self.ancestry = _string;
    } else {
        NSMutableString *result = [NSMutableString string];
        
        PKSymbolNode *n = self;
        while (PKEOF != n.character) {
            [result insertString:n.string atIndex:0];
            n = n.parent;
        }
        
        //self.ancestry = [[result copy] autorelease]; // assign an immutable copy
        self.ancestry = result; // optimization
    }
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<PKSymbolNode %@>", self.ancestry];
}

@end
