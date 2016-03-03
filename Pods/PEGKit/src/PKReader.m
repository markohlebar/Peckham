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

#import <PEGKit/PKReader.h>

@interface PKReader ()
@property (nonatomic) NSUInteger offset;
@property (nonatomic) NSUInteger length;
@end

@implementation PKReader

- (id)init {
    return [self initWithString:nil];
}


- (id)initWithString:(NSString *)s {
    self = [super init];
    if (self) {
        self.string = s;
    }
    return self;
}


- (id)initWithStream:(NSInputStream *)s {
    self = [super init];
    if (self) {
        self.stream = s;
    }
    return self;
}


- (void)dealloc {
    self.string = nil;
    self.stream = nil;
    [super dealloc];
}


- (NSString *)debugDescription {
    NSString *buff = [NSString stringWithFormat:@"%@^%@", [_string substringToIndex:_offset], [_string substringFromIndex:_offset]];
    return [NSString stringWithFormat:@"<%@ %p `%@`>", [self class], self, buff];
}


- (void)setString:(NSString *)s {
    NSAssert(!_stream, @"");
    
    if (_string != s) {
        [_string autorelease];
        _string = [s copy];
        self.length = [_string length];
    }
    // reset cursor
    self.offset = 0;
}


- (void)setStream:(NSInputStream *)s {
    NSAssert(!_string, @"");

    if (_stream != s) {
        [_stream autorelease];
        _stream = [s retain];
        _length = NSNotFound;
    }
    // reset cursor
    self.offset = 0;
}


- (PKUniChar)read {
    PKUniChar result = PKEOF;
    
    if (_string) {
        if (_length && _offset < _length) {
            result = [_string characterAtIndex:self.offset++];
        }
    } else {
        NSUInteger maxLen = 1; // 2 for wide char?
        uint8_t c;
        if ([_stream read:&c maxLength:maxLen]) {
            result = (PKUniChar)c;
        }
    }
    
    return result;
}


- (void)unread {
    self.offset = (0 == _offset) ? 0 : _offset - 1;
}


- (void)unread:(NSUInteger)count {
    for (NSUInteger i = 0; i < count; i++) {
        [self unread];
    }
}

@end
