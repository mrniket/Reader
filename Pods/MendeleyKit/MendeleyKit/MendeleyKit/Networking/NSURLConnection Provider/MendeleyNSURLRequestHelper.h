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

#import <Foundation/Foundation.h>
#import "MendeleyRequest.h"
#import "MendeleyResponse.h"
#import "MendeleyTask.h"
#import "MendeleyCancellableRequest.h"

@interface MendeleyNSURLRequestHelper : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate, MendeleyCancellableRequest>
@property (nonatomic, copy) MendeleyResponseCompletionBlock completionBlock;
@property (nonatomic, strong) MendeleyRequest *mendeleyRequest;
@property (nonatomic, strong) NSURLConnection *thisConnection;
@property (nonatomic, strong) NSMutableData *responseBody;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) MendeleyResponse *mendeleyResponse;
/**
   initialises the connection with a MendeleyRequest. The MendeleyRequest object holds all the data we need
   to make the network connection
   @param mendeleyRequest
   @param completionBlock
   @return an instance of MendeleyNSURLRequestHelper
 */
- (id)initWithMendeleyRequest:(MendeleyRequest *)mendeleyRequest
              completionBlock:(MendeleyResponseCompletionBlock)completionBlock;

/**
   starts the actual NSURLConnection request
   @return BOOL if successful
 */
- (BOOL)startRequest;
@end
