//
//  SVGUtils.h
//  SVGKit
//
//  Copyright Matt Rajca 2010-2011. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#define RGB_N(v) (v) / 255.0

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
	uint8_t r;
	uint8_t g;
	uint8_t b;
	uint8_t a;
} SVGColor;

SVGColor SVGColorMake (uint8_t r, uint8_t g, uint8_t b, uint8_t a);
SVGColor SVGColorFromString (const char *string);

CGFloat SVGPercentageFromString (const char *string);


CF_IMPLICIT_BRIDGING_ENABLED

CGMutablePathRef CreatePathFromPointsInString (const char *string, bool close);
CGColorRef CGColorWithSVGColor (SVGColor color);

CF_IMPLICIT_BRIDGING_DISABLED

#ifdef __cplusplus
}
#endif
