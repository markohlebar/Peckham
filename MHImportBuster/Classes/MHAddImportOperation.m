//
//  MHAddImportOperation.m
//  MHImportBuster
//
//  Created by Marko Hlebar on 22/03/2014.
//  Copyright (c) 2014 Marko Hlebar. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <AppKit/AppKit.h>
#import "MHAddImportOperation.h"
#import "MHImportStatement.h"
#import "MHStatementParser.h"
#import "DVTSourceTextStorage+Operations.h"
#import "NSString+Extensions.h"

NSString * const MHAddImportOperationImportRegexPattern = @".*#.*(import|include).*[\",<].*[\",>]";

NSString * const kMHAddImportOperationModuleImportRegexPattern = @".*@.*(import).*.;";

@implementation MHAddImportOperation

+ (instancetype)operationWithSource:(NSTextStorage *)source
				    importToAdd:(MHImportStatement *)importToAdd {
	return [[self alloc] initWithSource:source
					    importToAdd:importToAdd];
}

- (id)initWithSource:(NSTextStorage *)source
	    importToAdd:(MHImportStatement *)importToAdd {
	self = [super initWithSource:source];
	if (self) {
		_importToAdd = importToAdd;
	}
	return self;
}

- (void)execute {
	NSInteger lastLine = [self appropriateLine];
	
	if (lastLine != NSNotFound) {
		NSString *importString = [NSString stringWithFormat:@"%@\n", [_importToAdd value]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.source mhInsertString:importString
							 atLine:lastLine+1];
		});
	}
}

- (NSUInteger)appropriateLine {
	__block NSUInteger lineNumber = NSNotFound;
	__block NSUInteger currentLineNumber = 0;
	__block BOOL foundDuplicate = NO;
	Class importClass = [_importToAdd class];
	[self.source.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		if ([self isImportString:line]) {
			MHImportStatement *statement = [importClass statementWithString:line];
			if ([statement isEqual:_importToAdd]) {
				foundDuplicate = YES;
				*stop = YES;
				return;
			}
			lineNumber = currentLineNumber;
		}
		currentLineNumber++;
	}];
	
	if (foundDuplicate) return NSNotFound;
	
	//if no imports are present find the first new line.
	if (lineNumber == NSNotFound) {
		currentLineNumber = 0;
		[self.source.string enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
			if (![line mh_isWhitespaceOrNewline]) {
				currentLineNumber++;
			}
			else {
				lineNumber = currentLineNumber;
				*stop = YES;
			}
		}];
	}
	
	return lineNumber;
}

+ (NSRegularExpression *)importRegex {
	static NSRegularExpression *_regex = nil;
	if (!_regex) {
		NSError *error = nil;
		_regex = [[NSRegularExpression alloc] initWithPattern:MHAddImportOperationImportRegexPattern
											 options:0
											   error:&error];
	}
	return _regex;
}

+ (NSRegularExpression *) importModuleRegex
{
	static NSRegularExpression *_moduleRegex = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		NSError *regexError = nil;
		
		_moduleRegex = [[NSRegularExpression alloc] initWithPattern: kMHAddImportOperationModuleImportRegexPattern
												  options: 0
												    error: &regexError];
		
		if (regexError)
		{
			NSLog(@"regex error: %@", regexError);
		}
		
	});
	
	return _moduleRegex;
}

- (BOOL) isImportString:(NSString *)string {
	NSRegularExpression *regex = [MHAddImportOperation importRegex];
	NSInteger numberOfMatches = [regex numberOfMatchesInString:string
											 options:0
											   range:NSMakeRange(0, string.length)];
	
	if (numberOfMatches == 0)
	{
		NSRegularExpression *moduleRegex = [MHAddImportOperation importModuleRegex];
		
		numberOfMatches = [moduleRegex numberOfMatchesInString: string
											  options: 0
											    range: NSMakeRange(0, [string length])];
	}
	
	return numberOfMatches > 0;
}

@end