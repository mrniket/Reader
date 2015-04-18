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

#import "MendeleyRequest.h"
#import "MendeleyCancellableRequest.h"

@interface MendeleyTask : MendeleyRequest
/**
   @name MendeleyTask can be used in both NSURLSession and NSURLConnection APIs
   However, only one property gets populated for each.
   - for NSURLSession use initWithTaskID
   - for NSURLConnection use initWithRequestObject
 */

@property (nonatomic, strong, readonly) NSString *taskID;
@property (nonatomic, strong) id<MendeleyCancellableRequest> requestObject;


/**
   @param taskID
   @return an instance of type MendeleyCancellationRequest
 */
- (instancetype)initWithTaskID:(NSString *)taskID;

/**
   @param taskObject
   @return a cancellable task/request object
 */
- (instancetype)initWithRequestObject:(id<MendeleyCancellableRequest>)requestObject;
@end
