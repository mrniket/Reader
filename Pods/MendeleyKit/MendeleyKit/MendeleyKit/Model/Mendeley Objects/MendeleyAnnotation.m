/*
 ******************************************************************************
 * Copyright (C) 2014-2017 Elsevier/Mendeley.
 *
 * This file is part of the Mendeley iOS SDK.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *****************************************************************************
 */

#import "MendeleyAnnotation.h"
#import "NSError+MendeleyError.h"

@implementation MendeleyAnnotation
+ (id)colorFromParameters:(NSDictionary *)colorParameters error:(NSError **)error
{
    if (nil == colorParameters || 3 != colorParameters.allValues.count)
    {
        if (NULL != *error)
        {
            *error = [NSError errorWithCode:kMendeleyJSONTypeObjectNilErrorCode
                       localizedDescription:@"Annotation color components are either nil or not in the correct format."];
        }
        return nil;
    }
    CGFloat red = [[colorParameters objectForKey:kMendeleyJSONColorRed] floatValue] / 255.f;
    CGFloat green = [[colorParameters objectForKey:kMendeleyJSONColorGreen] floatValue] / 255.f;
    CGFloat blue = [[colorParameters objectForKey:kMendeleyJSONColorBlue] floatValue] / 255.f;
    id color = nil;
#if TARGET_OS_IPHONE
    color = [UIColor colorWithRed:red green:green blue:blue alpha:1.f];
#else
    color = [NSColor colorWithSRGBRed:red green:green blue:blue alpha:1.f];
#endif
    return color;
}

+ (NSDictionary *)jsonColorFromColor:(id)color error:(NSError **)error
{

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

#if TARGET_OS_IPHONE
    UIColor *uiColor = nil;
    if (nil != color && [color isKindOfClass:[UIColor class]])
    {
        uiColor = (UIColor *) color;
    }
    else
    {
        if (NULL != error)
        {
            *error = [NSError errorWithCode:kMendeleyUnknownDataTypeErrorCode
                       localizedDescription:@"The color object is either nil or it is neither UIColor nor NSColor"];
        }
        return nil;
    }
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [uiColor getRed:&red green:&green blue:&blue alpha:&alpha];
    red *= 255.f;
    green *= 255.f;
    blue *= 255.f;
    [dictionary setObject:[NSNumber numberWithFloat:red] forKey:kMendeleyJSONColorRed];
    [dictionary setObject:[NSNumber numberWithFloat:green] forKey:kMendeleyJSONColorGreen];
    [dictionary setObject:[NSNumber numberWithFloat:blue] forKey:kMendeleyJSONColorBlue];
#else
    NSColor *nsColor = nil;
    if (nil != color && [color isKindOfClass:[NSColor class]])
    {
        nsColor = (NSColor *) color;
    }
    else
    {
        if (NULL != error)
        {
            *error = [NSError errorWithCode:kMendeleyUnknownDataTypeErrorCode
                       localizedDescription:@"The color object is either nil or it is neither UIColor nor NSColor"];
        }
        return nil;
    }
    CGFloat red = 0;
    CGFloat green = 0;
    CGFloat blue = 0;
    CGFloat alpha = 0;
    [nsColor getRed:&red green:&green blue:&blue alpha:&alpha];
    red *= 255.f;
    green *= 255.f;
    blue *= 255.f;
    [dictionary setObject:[NSNumber numberWithFloat:red] forKey:kMendeleyJSONColorRed];
    [dictionary setObject:[NSNumber numberWithFloat:green] forKey:kMendeleyJSONColorGreen];
    [dictionary setObject:[NSNumber numberWithFloat:blue] forKey:kMendeleyJSONColorBlue];

#endif /* if TARGET_OS_IPHONE */
    return dictionary;
}
@end


@implementation MendeleyHighlightBox

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if (nil != self.page)
    {
        [encoder encodeObject:self.page forKey:kMendeleyJSONPage];
    }
#if TARGET_OS_IPHONE
    NSValue *rectValue = [NSValue valueWithCGRect:self.box];
#else
    NSValue *rectValue = [NSValue valueWithRect:NSRectFromCGRect(self.box)];
#endif
    if (nil != rectValue && NULL != rectValue)
    {
        [encoder encodeObject:rectValue forKey:@"box"];
    }
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (nil != self)
    {
        NSValue *rectValue = [decoder decodeObjectOfClass:[self class] forKey:@"box"];
        if (nil != rectValue)
        {
#if TARGET_OS_IPHONE
            _box = [rectValue CGRectValue];
#else 
            _box = NSRectToCGRect([rectValue rectValue]);
#endif
        }
    }
    _page = [decoder decodeObjectOfClass:[self class] forKey:kMendeleyJSONPage];
    return self;
}


+ (MendeleyHighlightBox *)boxFromJSONParameters:(NSDictionary *)boxParameters
                                          error:(NSError **)error
{
    if (nil == boxParameters )
    {
        if (NULL != *error)
        {
            *error = [NSError errorWithCode:kMendeleyJSONTypeObjectNilErrorCode
                       localizedDescription:@"Annotation position info is nil."];
        }
        return nil;
    }
    MendeleyHighlightBox *box = [MendeleyHighlightBox new];


    NSDictionary *topDict = [boxParameters objectForKey:kMendeleyJSONTopLeft];
    CGFloat topX = [[topDict objectForKey:kMendeleyJSONPositionX] floatValue];
    CGFloat topY = [[topDict objectForKey:kMendeleyJSONPositionY] floatValue];

    NSDictionary *botDict = [boxParameters objectForKey:kMendeleyJSONBottomRight];

    CGFloat botX = [[botDict objectForKey:kMendeleyJSONPositionX] floatValue];
    CGFloat botY = [[botDict objectForKey:kMendeleyJSONPositionY] floatValue];
    CGFloat width = botX - topX;
    CGFloat height = botY - topY;
    CGRect frame = CGRectMake(topX, topY, width, height);

    box.box = frame;
    box.page = [boxParameters objectForKey:kMendeleyJSONPage];
    return box;
}

+ (NSDictionary *)jsonBoxFromHighlightBox:(MendeleyHighlightBox *)box
                                    error:(NSError **)error
{
    if (nil == box)
    {
        if (NULL != error)
        {
            *error = [NSError errorWithCode:kMendeleyUnknownDataTypeErrorCode
                       localizedDescription:@"The position object is nil."];
        }
        return nil;
    }
    NSMutableDictionary *boxDictionary = [NSMutableDictionary dictionary];
    CGRect frame = box.box;
    CGFloat botX = frame.origin.x + frame.size.width;
    CGFloat botY = frame.origin.y + frame.size.height;
    NSMutableDictionary *topLeft = [NSMutableDictionary dictionary];

    [topLeft setObject:[NSNumber numberWithFloat:frame.origin.x] forKey:kMendeleyJSONPositionX];
    [topLeft setObject:[NSNumber numberWithFloat:frame.origin.y] forKey:kMendeleyJSONPositionY];
    NSMutableDictionary *botRight = [NSMutableDictionary dictionary];
    [botRight setObject:[NSNumber numberWithFloat:botX] forKey:kMendeleyJSONPositionX];
    [botRight setObject:[NSNumber numberWithFloat:botY] forKey:kMendeleyJSONPositionY];

    if (nil != box.page)
    {
        [boxDictionary setObject:box.page forKey:kMendeleyJSONPage];
    }
    [boxDictionary setObject:topLeft forKey:kMendeleyJSONTopLeft];
    [boxDictionary setObject:botRight forKey:kMendeleyJSONBottomRight];

    return boxDictionary;
}

@end

