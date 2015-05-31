#import "SVGKNodeList.h"
#import "SVGKNodeList+Mutable.h"

@implementation SVGKNodeList

@synthesize internalArray;

- (instancetype)init {
    self = [super init];
	
    if (self) {
        self.internalArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(SVGKNode*) item:(NSInteger) index
{
	return (self.internalArray)[index];
}

-(long)length
{
	return [self.internalArray count];
}

#pragma mark - ADDITIONAL to SVG Spec: Objective-C support for fast-iteration ("for * in ..." syntax)

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
	return [self.internalArray countByEnumeratingWithState:state objects:buffer count:len];
}

- (SVGKNode*)objectAtIndexedSubscript:(NSInteger)idx
{
    return [self item:idx];
}

#pragma mark - ADDITIONAL to SVG Spec: useful debug / output / description methods

-(NSString *)description
{
	return [NSString stringWithFormat:@"NodeList: array(%@)", self.internalArray];
}

@end
