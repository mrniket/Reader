/**
 
 */
#import "SVGKSource.h"

@interface SVGKSourceLocalFile : SVGKSource <NSCopying>

@property (nonatomic, strong) NSString* filePath;
@property (nonatomic, readonly) BOOL wasRelative;

- (instancetype)initWithFilename:(NSString*)p;
+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p;

@end
