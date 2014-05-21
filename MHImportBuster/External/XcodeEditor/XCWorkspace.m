//
//  XCWorkspace.m
//  xcode-editor
//
//  Created by Marko Hlebar on 06/05/2014.
//  Copyright (c) 2014 EXPANZ. All rights reserved.
//

#import "XCWorkspace.h"
#import "XCProject.h"
#import "NSString+XCAdditions.h"

static NSString * const XCWorkspaceContents =       @"contents.xcworkspacedata";
static NSString * const XCFileRefElement =          @"FileRef";
static NSString * const XCLocationKey =             @"location";

@interface XCWorkspace () <NSXMLParserDelegate>

@end

@implementation XCWorkspace
{
    NSXMLParser *_parser;
}

+ (instancetype)workspaceWithFilePath:(NSString*)filePath
{
    return [[self alloc] initWithFilePath:filePath];
}

- (instancetype)initWithFilePath:(NSString*)filePath
{
    self = [super init];
    if (self)
    {
        _filePath = filePath.copy;
        
        [self parseWorkspaceWithFilePath:_filePath];
    }
    return self;
}

- (void)parseWorkspaceWithFilePath:(NSString *)filePath
{
    _projects = [NSArray new];
    
    filePath = [filePath stringByAppendingPathComponent:XCWorkspaceContents];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    
    _parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    _parser.delegate = self;
    [_parser parse];
}

- (void) addProjectWithFilePath:(NSString *)filePath {
    XCProject *project = [XCProject projectWithFilePath:filePath];
    _projects = [_projects arrayByAddingObject:project];
}

-   (void)parser:(NSXMLParser *)parser
 didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI
   qualifiedName:(NSString *)qName
      attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:XCFileRefElement]) {
        NSString *location = attributeDict[XCLocationKey];
        
        if ([location containsString:@"self:"]) {
            location = [self workspaceRootPath];
        }
        else {
            NSArray *stringsToReplace = @[@"group:", @"container:"];
            location = [location stringByReplacingOccurrencesOfStrings:stringsToReplace
                                                            withString:@""];
            location = [[self workspaceRootPath] stringByAppendingPathComponent:location];
        }

        [self addProjectWithFilePath:location];
    }
}

- (NSString *)workspaceRootPath
{
    return [_filePath stringByDeletingLastPathComponent];
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    _parser = nil;
}

@end
