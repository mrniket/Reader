//
//  Text.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGKText.h"

@implementation SVGKText

- (instancetype)initWithValue:(NSString*) v
{
    self = [super initType:DOMNodeType_TEXT_NODE name:@"#text" value:v];
    if (self) {
		
    }
    return self;
}
-(SVGKText*) splitText:(NSUInteger) offset;
{
	NSAssert( FALSE, @"Not implemented yet" );
	return nil;
}

@end
