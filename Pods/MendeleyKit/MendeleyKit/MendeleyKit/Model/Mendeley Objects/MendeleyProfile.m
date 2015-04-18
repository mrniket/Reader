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

#import "MendeleyProfile.h"

@implementation MendeleyEducation
@end

@implementation MendeleyLocation
@end

@implementation MendeleyDiscipline
@end

@implementation MendeleyImage
@end

@implementation MendeleyEmployment

- (void)setIs_main_employment:(NSNumber *)is_main_employment
{
    if (nil != is_main_employment)
    {
        is_main_employment = [NSNumber numberWithBool:[is_main_employment boolValue]];
    }
}
@end

@implementation MendeleyProfile

- (void)setVerified:(NSNumber *)verified
{
    if (nil != verified)
    {
        _verified = [NSNumber numberWithBool:[verified boolValue]];
    }
}

@end

@implementation MendeleyUserProfile
@end

@implementation MendeleyNewProfile
@end

@implementation MendeleyAmendmentProfile
@end