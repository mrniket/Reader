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

#import "MendeleySyncInfo.h"

static NSDateFormatter * headerDateFormatter()
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

    [formatter setLocale:enUSPOSIXLocale];
    [formatter setDateFormat:kMendeleyHTTPHeaderDateFormat];
    return formatter;
}


@interface MendeleySyncInfo ()
@property (nonatomic, strong, readwrite) NSDate *syncDate;
@property (nonatomic, strong, readwrite) NSDictionary *linkDictionary;
@property (nonatomic, strong, readwrite) NSNumber *totalCount;
@property (nonatomic, strong, readwrite) NSString *modelVersion;

@end

@implementation MendeleySyncInfo

- (id)initWithAllHeaderFields:(NSDictionary *)allHeaderFields
{
    self = [super init];
    if (nil != self)
    {
        if (nil != allHeaderFields)
        {
            NSString *link = [allHeaderFields objectForKey:kMendeleyRESTRequestLink];
            _linkDictionary = [self linkDictionaryFromLinkString:link];
            _totalCount = [allHeaderFields objectForKey:kMendeleyRESTHTTPTotalCount];
            _modelVersion = [allHeaderFields objectForKey:kMendeleyRESTRequestContentType];
            NSString *stringDate = [allHeaderFields objectForKey:kMendeleyRESTRequestDate];
            if (nil != stringDate)
            {
                _syncDate = [headerDateFormatter() dateFromString:stringDate];
            }

        }
    }
    return self;

}


- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.syncDate forKey:kMendeleyRESTRequestDate];
    [encoder encodeObject:self.linkDictionary forKey:kMendeleyRESTRequestLink];
    [encoder encodeObject:self.modelVersion forKey:kMendeleyRESTRequestContentType];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (nil != self)
    {
        _syncDate = [decoder decodeObjectForKey:kMendeleyRESTRequestDate];
        _linkDictionary = [decoder decodeObjectForKey:kMendeleyRESTRequestLink];
        _modelVersion = [decoder decodeObjectForKey:kMendeleyRESTRequestContentType];
    }
    return self;
}


- (NSDictionary *)linkDictionaryFromLinkString:(NSString *)linkString
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    if (nil == linkString)
    {
        return dictionary;
    }
    NSArray *components = [linkString componentsSeparatedByString:@","];
    [components enumerateObjectsUsingBlock:^(NSString *partialLinkString, NSUInteger idx, BOOL *stop) {
         NSString *key = [self qualifierFromString:partialLinkString];
         NSURL *value = [self urlFromString:partialLinkString];
         if (nil != key && nil != value)
         {
             [dictionary setObject:value forKey:key];
         }
     }];


    return dictionary;
}

- (NSString *)qualifierFromString:(NSString *)string
{
    NSArray *components = [string componentsSeparatedByString:@";"];
    __block NSString *qualifier = nil;

    [components enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
         NSArray *relComponents = [obj componentsSeparatedByString:@"="];
         if (2 == relComponents.count)
         {
             NSString *quotes = @"\"";
             NSString *fullString = relComponents[1];
             NSString *trimmedString = [fullString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
             NSRange range = NSMakeRange(quotes.length, trimmedString.length - 2 * quotes.length);
             qualifier = [trimmedString substringWithRange:range];
             *stop = YES;
         }
     }];
    return qualifier;
}

- (NSURL *)urlFromString:(NSString *)string
{
    NSArray *components = [string componentsSeparatedByString:@";"];
    __block NSURL *url = nil;

    [components enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
         NSArray *components = [obj componentsSeparatedByString:@"<"];
         if (2 == components.count)
         {
             NSString *string = [components objectAtIndex:1];
             NSArray *subComponents = [string componentsSeparatedByString:@">"];
             url = [NSURL URLWithString:[subComponents objectAtIndex:0]];
         }
     }];
    return url;
}
@end
