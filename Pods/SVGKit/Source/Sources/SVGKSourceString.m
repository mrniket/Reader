#import "SVGKSourceString.h"
#import "SVGKSource-private.h"

@interface SVGKSourceString ()
@property (nonatomic, strong, readwrite) NSString* rawString;
@end

@implementation SVGKSourceString

- (instancetype)initWithString:(NSString*)theStr
{
	NSString *tmpStr = [[NSString alloc] initWithString:theStr];
	NSInputStream* stream = [[NSInputStream alloc] initWithData:[tmpStr dataUsingEncoding:NSUTF8StringEncoding]];
	//DO NOT DO THIS: let the parser do it at last possible moment (Apple has threading problems otherwise!) [stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.rawString = tmpStr;
		self.approximateLengthInBytesOr0 = [theStr lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	}
	
	return self;
}

+ (SVGKSource*)sourceFromContentsOfString:(NSString*)rawString
{
	SVGKSourceString *s = [[self alloc] initWithString:rawString];
	
	return s;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[[self class] alloc] initWithString:self.rawString];
}

- (NSString*)description
{
	return [NSString stringWithFormat:@"%@, string length: %lu", [self baseDescription], (unsigned long)[self.rawString length]];
}

- (NSString*)debugDescription
{
	return [NSString stringWithFormat:@"%@, string: %@", [self baseDescription], self.rawString];
}

@end
