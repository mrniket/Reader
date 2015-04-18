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

#import "MendeleyObject.h"

@class MendeleyPhoto;

@interface MendeleyGroup : MendeleyObject

@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *owning_profile_id;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSString *access_level;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) MendeleyPhoto *photo;
@property (nonatomic, strong) NSString *webpage;
@property (nonatomic, strong) NSArray *disciplines;
@property (nonatomic, strong) NSArray *tags;

@end

@interface MendeleyPhoto : MendeleyObject

@property (nonatomic, strong) NSString *original;
@property (nonatomic, strong) NSString *square;
@property (nonatomic, strong) NSString *standard;
@property (nonatomic, strong) NSData *originalImageData;
@property (nonatomic, strong) NSData *squareImageData;
@property (nonatomic, strong) NSData *standardImageData;

@end
