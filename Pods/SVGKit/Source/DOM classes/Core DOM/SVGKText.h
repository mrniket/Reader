/*
 SVG-DOM, via Core DOM:
 
 http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1312295772
 
 interface Text : CharacterData {
 Text               splitText(in unsigned long offset)
 raises(DOMException);
 };
*/

#import <Foundation/Foundation.h>

#import "SVGKCharacterData.h"

@interface SVGKText : SVGKCharacterData

- (instancetype)initWithValue:(NSString*) v;

-(SVGKText*) splitText:(NSUInteger) offset;

@end
