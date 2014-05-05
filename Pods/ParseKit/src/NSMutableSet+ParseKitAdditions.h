//
//  NSMutableSet+ParseKitAdditions.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 4/5/13.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableSet (ParseKitAdditions)
- (void)unionSetTestingEquality:(NSSet *)s;
- (void)intersectSetTestingEquality:(NSSet *)s;
- (void)minusSetTestingEquality:(NSSet *)s;
- (void)exclusiveSetTestingEquality:(NSSet *)s;
@end
