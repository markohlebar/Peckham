//
//  PKCompositeParser.h
//  ParseKit
//
//  Created by Todd Ditchendorf on 10/5/12.
//
//

#import <ParseKit/PKParser.h>

@interface PKCompositeParser : PKParser {
    
}

/*!
    @brief      Adds a parser to the composite.
    @param      p parser to add
*/
- (void)add:(PKParser *)p;
@end
