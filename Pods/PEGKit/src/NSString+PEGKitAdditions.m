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

#import "NSString+PEGKitAdditions.h"

@implementation NSString (PEGKitAdditions)

- (NSString *)stringByTrimmingQuotes {
    NSUInteger len = [self length];
    
    if (len < 2) {
        return self;
    }
    
    NSRange r = NSMakeRange(0, len);
    
    unichar c = [self characterAtIndex:0];
    if (!isalnum(c)) {
        unichar quoteChar = c;
        r.location = 1;
        r.length -= 1;

        c = [self characterAtIndex:len - 1];
        if (c == quoteChar) {
            r.length -= 1;
        }
        return [self substringWithRange:r];
    } else {
        return self;
    }
}

@end
