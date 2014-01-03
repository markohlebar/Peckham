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

#import <ParseKit/PKReader.h>

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


- (id)initWithStream:(NSStream *)s {
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


- (NSString *)string {
    return [[string retain] autorelease];
}


- (NSStream *)stream {
    return [[stream retain] autorelease];
}


- (void)setString:(NSString *)s {
    NSAssert(!stream, @"");
    
    if (string != s) {
        [string autorelease];
        string = [s copy];
        length = [string length];
    }
    // reset cursor
    offset = 0;
}


- (void)setStream:(NSInputStream *)s {
    NSAssert(!string, @"");

    if (stream != s) {
        [stream autorelease];
        stream = [s retain];
        length = NSNotFound;
    }
    // reset cursor
    offset = 0;
}


- (PKUniChar)read {
    PKUniChar result = PKEOF;
    
    if (string) {
        if (length && offset < length) {
            result = [string characterAtIndex:offset++];
        }
    } else {
        NSUInteger maxLen = 1; // 2 for wide char?
        uint8_t c;
        if ([stream read:&c maxLength:maxLen]) {
            result = (PKUniChar)c;
        }
    }
    
    return result;
}


- (void)unread {
    offset = (0 == offset) ? 0 : offset - 1;
}


- (void)unread:(NSUInteger)count {
    for (NSUInteger i = 0; i < count; i++) {
        [self unread];
    }
}

@synthesize offset;
@end
