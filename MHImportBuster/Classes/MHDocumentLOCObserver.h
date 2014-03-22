//
//  MHDocumentLOCObserver.h
//  MHImportBuster
//
//  Created by Marko Hlebar on 26/01/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHDocumentObserver.h"

@interface MHDocumentLOCObserver : MHDocumentObserver
@property (nonatomic, readwrite) NSUInteger maxLinesOfCode;

@end
