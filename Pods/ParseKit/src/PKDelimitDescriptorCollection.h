//
//  PKDelimitDescriptorCollection.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 3/20/13.
//
//

#import <Foundation/Foundation.h>

@class PKDelimitDescriptor;

@interface PKDelimitDescriptorCollection : NSObject

- (void)add:(PKDelimitDescriptor *)desc;
- (void)remove:(PKDelimitDescriptor *)desc;

- (NSArray *)descriptorsForStartMarker:(NSString *)startMarker;
@end
