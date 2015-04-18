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

#import "MendeleyTask.h"

@interface MendeleyTask ()

@property (nonatomic, strong, readwrite) NSString *taskID;

@end

@implementation MendeleyTask

- (instancetype)initWithTaskID:(NSString *)taskID
{
    self = [super init];
    if (nil != self)
    {
        _taskID = taskID;
        _requestObject = nil;
    }
    return self;
}

- (instancetype)initWithRequestObject:(id)requestObject
{
    self = [super init];
    if (nil != self)
    {
        _taskID = nil;
        _requestObject = requestObject;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (nil != self)
    {
        _taskID = [[NSUUID UUID] UUIDString];
        _requestObject = nil;
    }
    return self;
}

@end
