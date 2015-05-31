/**
 Makes the writable properties all package-private, effectively
 */

#import "SVGDocument.h"

@interface SVGDocument ()
@property (nonatomic, copy, readwrite) NSString* title;
@property (nonatomic, copy, readwrite) NSString* referrer;
@property (nonatomic, copy, readwrite) NSString* domain;
@property (nonatomic, copy, readwrite) NSString* URL;
@property (nonatomic, strong, readwrite) SVGSVGElement* rootElement;
@end
