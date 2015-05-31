/*
//  Document.h

 NOT a Cocoa / Apple document,
 NOT an SVG document,
 BUT INSTEAD: a DOM document (blame w3.org for the too-generic name).
 
 Required for SVG-DOM
 
 c.f.:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#i-Document
 
 interface Document : Node {
 readonly attribute DocumentType     doctype;
 readonly attribute DOMImplementation  implementation;
 readonly attribute Element          documentElement;
 Element            createElement(in DOMString tagName)
 raises(DOMException);
 DocumentFragment   createDocumentFragment();
 Text               createTextNode(in DOMString data);
 Comment            createComment(in DOMString data);
 CDATASection       createCDATASection(in DOMString data)
 raises(DOMException);
 ProcessingInstruction createProcessingInstruction(in DOMString target, 
 in DOMString data)
 raises(DOMException);
 Attr               createAttribute(in DOMString name)
 raises(DOMException);
 EntityReference    createEntityReference(in DOMString name)
 raises(DOMException);
 NodeList           getElementsByTagName(in DOMString tagname);
 // Introduced in DOM Level 2:
 Node               importNode(in Node importedNode, 
 in boolean deep)
 raises(DOMException);
 // Introduced in DOM Level 2:
 Element            createElementNS(in DOMString namespaceURI, 
 in DOMString qualifiedName)
 raises(DOMException);
 // Introduced in DOM Level 2:
 Attr               createAttributeNS(in DOMString namespaceURI, 
 in DOMString qualifiedName)
 raises(DOMException);
 // Introduced in DOM Level 2:
 NodeList           getElementsByTagNameNS(in DOMString namespaceURI, 
 in DOMString localName);
 // Introduced in DOM Level 2:
 Element            getElementById(in DOMString elementId);
 };

 
 */

#import <Foundation/Foundation.h>

#import "SVGKNode.h"
#import "SVGKElement.h"
#import "SVGKComment.h"
#import "SVGKCDATASection.h"
#import "SVGKDocumentFragment.h"
#import "SVGKEntityReference.h"
#import "SVGKNodeList.h"
#import "SVGKProcessingInstruction.h"
#import "SVGKDocumentType.h"
#import "SVGKAppleSucksDOMImplementation.h"

@interface SVGKDocument : SVGKNode

@property(nonatomic,strong,readonly) SVGKDocumentType*     doctype;
@property(nonatomic,strong,readonly) SVGKAppleSucksDOMImplementation*  implementation;
@property(nonatomic,strong,readonly) SVGKElement*          documentElement;


-(SVGKElement*) createElement:(NSString*) tagName NS_RETURNS_RETAINED;
-(SVGKDocumentFragment*) createDocumentFragment NS_RETURNS_RETAINED;
-(SVGKText*) createTextNode:(NSString*) data NS_RETURNS_RETAINED;
-(SVGKComment*) createComment:(NSString*) data NS_RETURNS_RETAINED;
-(SVGKCDATASection*) createCDATASection:(NSString*) data NS_RETURNS_RETAINED;
-(SVGKProcessingInstruction*) createProcessingInstruction:(NSString*) target data:(NSString*) data NS_RETURNS_RETAINED;
-(SVGKAttr*) createAttribute:(NSString*) data NS_RETURNS_RETAINED;
-(SVGKEntityReference*) createEntityReference:(NSString*) data NS_RETURNS_RETAINED;

-(SVGKNodeList*) getElementsByTagName:(NSString*) data;

// Introduced in DOM Level 2:
-(SVGKNode*) importNode:(SVGKNode*) importedNode deep:(BOOL) deep;

// Introduced in DOM Level 2:
-(SVGKElement*) createElementNS:(NSString*) namespaceURI qualifiedName:(NSString*) qualifiedName NS_RETURNS_RETAINED;

// Introduced in DOM Level 2:
-(SVGKAttr*) createAttributeNS:(NSString*) namespaceURI qualifiedName:(NSString*) qualifiedName;

// Introduced in DOM Level 2:
-(SVGKNodeList*) getElementsByTagNameNS:(NSString*) namespaceURI localName:(NSString*) localName;

// Introduced in DOM Level 2:
-(SVGKElement*) getElementById:(NSString*) elementId;

@end
