/*
 SVG-DOM, via Core DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1004215813
 
 interface ProcessingInstruction : Node {
 readonly attribute DOMString        target;
 attribute DOMString        data;
 // raises(DOMException) on setting
 
 };
*/

#import <Foundation/Foundation.h>

#import "SVGKNode.h"

@interface SVGKProcessingInstruction : SVGKNode
@property(nonatomic,copy,readonly) NSString* target;
@property(nonatomic,copy,readonly) NSString* data;

-(instancetype) initProcessingInstruction:(NSString*) target value:(NSString*) data;

@end
