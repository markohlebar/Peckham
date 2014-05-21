//
//  MyClass.m
//  MHImportBuster
//
//  Created by marko.hlebar on 25/12/13.
//  Copyright (c) 2013 Marko Hlebar. All rights reserved.
//


static NSString *const MHHeaderCacheSystemFrameworksPath = @"/System/Library/Frameworks/";

#import "MyClass.h"


@implementation MyClass

+(void) classMethod {

}

+classMethod2 {
    return self;
}

+classMethodWithParameter:(NSString*) parameter {

    return self;
}

-(void) instanceMethod {

}

-(void) instanceMethodWithConditionals {
    if (YES) {
        for(;;) {
        
        }
    }
    else {
        if (YES) {
            
        }
        else if {
            switch (1) {
                case 1:
                    
                    break;
                    
                default:
                    break;
            }
        }
    }
}

-(void) instanceMethodWithParameter1:(id) param1
                          parameter2:(id) param2 {

}

-(void)

instanceMethodWithWeirdFormatting

{
    
}


@end
