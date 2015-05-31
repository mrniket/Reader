/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceString : SVGKSource <NSCopying>

@property (nonatomic, strong, readonly) NSString* rawString;

- (instancetype)initWithString:(NSString*)theStr;
+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString;

@end
