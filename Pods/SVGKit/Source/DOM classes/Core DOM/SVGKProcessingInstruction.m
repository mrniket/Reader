//
//  ProcessingInstruction.m
//  SVGKit
//
//  Created by adam on 22/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SVGKProcessingInstruction.h"

@interface SVGKProcessingInstruction()
@property(nonatomic,copy,readwrite) NSString* target;
@property(nonatomic,copy,readwrite) NSString* data;
@end

@implementation SVGKProcessingInstruction

@synthesize target;
@synthesize data;

-(instancetype) initProcessingInstruction:(NSString*) t value:(NSString*) d
{
    self = [super initType:DOMNodeType_PROCESSING_INSTRUCTION_NODE name:t value:d];
    if (self) {
		self.target = t;
		self.data = d;
    }
    return self;
}

@end
