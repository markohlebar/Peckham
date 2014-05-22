//
//  PKTokenizer+Factory.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 13/04/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "PKTokenizer+Factory.h"

@implementation PKTokenizer (Factory)
+ (PKTokenizer *)defaultTokenizer {
    PKTokenizer *defaultTokenizer = [PKTokenizer tokenizer];
    //sets the parsing of #import "header.h" not to behave as quoted string
    [defaultTokenizer setTokenizerState:(PKTokenizerState *)defaultTokenizer.symbolState
                                   from:'"'
                                     to:'"'];
    
    [defaultTokenizer setTokenizerState:(PKTokenizerState *)defaultTokenizer.symbolState
                                   from:0
                                     to:' '];
    
    //sets the parsing of anything that starts with a # as a word
//    [defaultTokenizer setTokenizerState:(PKTokenizerState *)defaultTokenizer.wordState
//                                   from:'#'
//                                     to:'#'];
    //sets the parsing of anything that starts with a @ as a word
    [defaultTokenizer setTokenizerState:(PKTokenizerState *)defaultTokenizer.wordState
                                   from:'@'
                                     to:'@'];
	return defaultTokenizer;
}
@end
