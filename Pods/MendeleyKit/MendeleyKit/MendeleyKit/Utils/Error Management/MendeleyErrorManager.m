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

#import "MendeleyErrorManager.h"
#import "NSError+MendeleyError.h"

@interface MendeleyErrorManager ()

@property (nonatomic, strong) NSMutableDictionary *helpers;

@end

@implementation MendeleyErrorManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedObject;

    dispatch_once(&onceToken, ^{
                      sharedObject = [[[self class] alloc] init];
                  });
    return sharedObject;
}

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _helpers = [NSMutableDictionary new];
    }
    return self;
}

- (void)addUserInfoHelper:(id <MendeleyUserInfoProvider> )helper errorDomain:(NSString *)errorDomain
{
    [NSError assertArgumentNotNil:helper argumentName:@"helper"];
    [NSError assertStringArgumentNotNilOrEmpty:errorDomain argumentName:@"errorDomain"];

    [self.helpers setObject:helper forKey:errorDomain];
}

- (void)removeUserInfoHelperWithErrorDomain:(NSString *)errorDomain
{
    [NSError assertStringArgumentNotNilOrEmpty:errorDomain argumentName:@"errorDomain"];

    [self.helpers removeObjectForKey:errorDomain];
}

- (NSError *)errorWithDomain:(NSString *)errorDomain code:(NSInteger)errorCode
{
    [NSError assertStringArgumentNotNilOrEmpty:errorDomain argumentName:@"errorDomain"];

    id <MendeleyUserInfoProvider> helper = [self.helpers objectForKey:errorDomain];
    [NSError assertArgumentNotNil:helper argumentName:@"helper"];

    NSDictionary *userInfo = [helper userInfoWithErrorCode:errorCode];
    [NSError assertArgumentNotNil:userInfo argumentName:@"userInfo"];

    NSError *error = [NSError errorWithDomain:errorDomain code:errorCode userInfo:userInfo];
    return error;
}

- (NSError *)errorFromOriginalError:(NSError *)originalError error:(NSError *)secondError
{
    if (nil == originalError)
    {
        return secondError;
    }
    if (nil == secondError)
    {
        return originalError;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSMutableArray *errors = [NSMutableArray arrayWithObject:secondError];

    if ([originalError code] == MendeleyErrorMultipleErrors)
    {
        [userInfo addEntriesFromDictionary:[originalError userInfo]];
        [errors addObjectsFromArray:[userInfo objectForKey:MendeleyDetailedErrorsKey]];
    }
    else
    {
        [errors addObject:originalError];
    }

    [userInfo setObject:errors forKey:MendeleyDetailedErrorsKey];

    NSString *errorDomain = ([originalError.domain isEqualToString:secondError.domain]) ? originalError.domain : MendeleyErrorDomainMultiple;

    return [NSError errorWithDomain:errorDomain
                               code:MendeleyErrorMultipleErrors
                           userInfo:userInfo];
}

@end
