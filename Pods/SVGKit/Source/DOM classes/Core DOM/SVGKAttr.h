/*
 SVG-DOM, via Core DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-637646024
 
 interface Attr : Node {
 readonly attribute DOMString        name;
 readonly attribute boolean          specified;
 attribute DOMString        value;
 // raises(DOMException) on setting
 
 // Introduced in DOM Level 2:
 readonly attribute Element          ownerElement;
 };
*/
#import <Foundation/Foundation.h>

#import "SVGKNode.h"
@class SVGKElement;

@interface SVGKAttr : SVGKNode

/*! NB: The official DOM spec FAILS TO SPECIFY what the value of "name" is */
@property(nonatomic,copy,readonly) NSString* name;
@property(nonatomic,readonly) BOOL specified;
@property(nonatomic,copy,readonly) NSString* value;

// Introduced in DOM Level 2:
@property(nonatomic,strong,readonly) SVGKElement* ownerElement;

#pragma mark - ObjC methods

- (instancetype)initWithName:(NSString*) n value:(NSString*) v;
- (instancetype)initWithNamespace:(NSString*) ns qualifiedName:(NSString*) qn value:(NSString*) v;

@end
