//
//  MHDocumentLOCObserver.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 26/01/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import "MHDocumentLOCObserver.h"

@implementation MHDocumentLOCObserver

- (void)textDidChange:(NSString *)text {
	NSInteger linesOfCode = [[text componentsSeparatedByString:@"\n"] count];

	if (linesOfCode > _maxLinesOfCode) {
		[self notifyDelegateDidReachConstraint];
	}
}

- (NSString *)constraintDescription {
	return [NSString stringWithFormat:NSLocalizedString(@"A maximum number of lines of code (%d) reached.", @"MHDocumentLOCObserver"), self.maxLinesOfCode];
}

@end
