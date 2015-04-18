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

#import "MendeleyOAuthCredentials.h"
#import "MendeleyOAuthConstants.h"
#import "MendeleyObjectHelper.h"

@interface MendeleyOAuthCredentials ()
@property (nonatomic, strong) NSDate *currentDate;
@end

@implementation MendeleyOAuthCredentials
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _currentDate = [NSDate date];
    }
    return self;
}

- (NSDictionary *)authenticationHeader
{
    return @{ @"Authorization" : [NSString stringWithFormat:@"Bearer %@", self.access_token] };
}

- (BOOL)oauthCredentialIsExpired
{
    NSDate *expiryDate = [self.currentDate dateByAddingTimeInterval:[self.expires_in doubleValue]];

    return [expiryDate compare:[NSDate date]] == NSOrderedAscending;
}

#pragma mark NSSecureCoding protocol

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSArray *propertyNames = [MendeleyObjectHelper propertyNamesForModel:self];

    [propertyNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
         id value = [self valueForKey:name];
         if (nil != value)
         {
             [encoder encodeObject:value forKey:name];
         }
     }];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (nil != self)
    {
        [self decodeWithDecoder:decoder];
    }
    return self;
}

#pragma mark -
#pragma mark private

- (void)decodeWithDecoder:(NSCoder *)decoder
{
    NSArray *propertyNames = [MendeleyObjectHelper propertyNamesForModel:self];

    [propertyNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger idx, BOOL *stop) {
         id value = [decoder decodeObjectOfClass:[self class] forKey:name];
         if (nil != value)
         {
             [self setValue:value forKey:name];
         }
     }];
}

@end
