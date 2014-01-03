//
//  PKCompositeParser.m
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import "PKCompositeParser.h"

@implementation PKCompositeParser

- (void)add:(PKParser *)p {
    NSAssert2(0, @"%s is an abastract method. Must be overridden in %@", __PRETTY_FUNCTION__, NSStringFromClass([self class]));
}

@end
