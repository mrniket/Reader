#import "SVGKSourceLocalFile.h"
#import "SVGKSource-private.h"

@interface SVGKSourceLocalFile()
@property (nonatomic, readwrite) BOOL wasRelative;
@end

@implementation SVGKSourceLocalFile

+(uint64_t) sizeInBytesOfFilePath:(NSString*) filePath
{
	NSError* errorReadingFileAttributes;
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSDictionary* atts = [fileManager attributesOfItemAtPath:filePath error:&errorReadingFileAttributes];
	
	if( atts == nil )
		return -1;
	else
		return atts.fileSize;
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[SVGKSourceLocalFile alloc] initWithFilename:self.filePath];
}

- (instancetype)initWithFilename:(NSString*)p
{
	NSInputStream* stream = [[NSInputStream alloc] initWithFileAtPath:p];
	//DO NOT DO THIS: let the parser do it at last possible moment (Apple has threading problems otherwise!) [stream open];
	if (self = [super initWithInputSteam:stream]) {
		self.filePath = p;
		self.approximateLengthInBytesOr0 = [SVGKSourceLocalFile sizeInBytesOfFilePath:p];

	}
	return self;
}

+ (SVGKSourceLocalFile*)sourceFromFilename:(NSString*)p {
	SVGKSourceLocalFile* s = [[SVGKSourceLocalFile alloc] initWithFilename:p];
	
	return s;
}

- (SVGKSourceLocalFile *)sourceFromRelativePath:(NSString *)relative {
	NSString *absolute = ((NSURL*)[NSURL URLWithString:relative relativeToURL:[NSURL fileURLWithPath:self.filePath]]).path;
    if ([[NSFileManager defaultManager] fileExistsAtPath:absolute])
	{
       SVGKSourceLocalFile* result = [SVGKSourceLocalFile sourceFromFilename:absolute];
		result.wasRelative = true;
		return result;
	}
    return nil;
}

-(NSString *)description
{
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:self.filePath];
	return [NSString stringWithFormat:@"File: %@%@\"%@\" (%llu bytes)", self.wasRelative? @"(relative) " : @"", fileExists?@"":@"NOT FOUND!  ", self.filePath, self.approximateLengthInBytesOr0 ];
}

@end
