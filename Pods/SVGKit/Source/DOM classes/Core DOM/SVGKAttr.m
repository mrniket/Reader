//
//  Attr.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGKAttr.h"

#import "SVGKNode+Mutable.h"

@interface SVGKAttr()
@property(nonatomic,copy,readwrite) NSString* name;
@property(nonatomic,readwrite) BOOL specified;
@property(nonatomic,copy,readwrite) NSString* value;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readwrite) SVGKElement* ownerElement;
@end

@implementation SVGKAttr

@synthesize name;
@synthesize specified;
@synthesize value;

// Introduced in DOM Level 2:
@synthesize ownerElement;

- (instancetype)initWithName:(NSString*) n value:(NSString*) v
{
    self = [super initType:DOMNodeType_ATTRIBUTE_NODE name:n value:v];
    if (self)
	{
		self.name = n;
		self.value = v;
    }
    return self;
}

- (instancetype)initWithNamespace:(NSString*) ns qualifiedName:(NSString*) qn value:(NSString *)v
{
    self = [super initType:DOMNodeType_ATTRIBUTE_NODE name:qn value:v inNamespace:ns];
	if (self)
	{
		self.name = qn;
		self.value = v;
    }
    return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@:%@, owner: %@, specified: %@", self.name, self.value, self.ownerElement, self.specified ? @"yes" : @"no"];
}

@end
