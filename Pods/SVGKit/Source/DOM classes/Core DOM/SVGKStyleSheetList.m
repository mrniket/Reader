#import "SVGKStyleSheetList.h"
#import "SVGKStyleSheetList+Mutable.h"

@implementation SVGKStyleSheetList

@synthesize internalArray;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.internalArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSUInteger)length
{
	return self.internalArray.count;
}

-(SVGKStyleSheet*) item:(NSUInteger) index
{
	return (self.internalArray)[index];
}

@end

@implementation SVGKStyleSheetList (CocoaAdditions)

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
	return [self.internalArray countByEnumeratingWithState:state objects:buffer count:len];
}

- (SVGKStyleSheet*)objectAtIndexedSubscript:(NSInteger)idx
{
	return (self.internalArray)[idx];
}

@end
