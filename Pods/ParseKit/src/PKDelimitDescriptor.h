//
//  PKDelimitDescriptor.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/20/13.
//
//

#import <Foundation/Foundation.h>

@interface PKDelimitDescriptor : NSObject <NSCopying>

+ (PKDelimitDescriptor *)descriptorWithStartMarker:(NSString *)start endMarker:(NSString *)end characterSet:(NSCharacterSet *)cs;

@property (nonatomic, retain) NSString *startMarker;
@property (nonatomic, retain) NSString *endMarker;
@property (nonatomic, retain) NSCharacterSet *characterSet;
@end
