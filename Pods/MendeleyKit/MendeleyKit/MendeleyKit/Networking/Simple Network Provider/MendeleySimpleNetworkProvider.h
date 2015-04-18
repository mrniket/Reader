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
#import "MendeleyNetworkProvider.h"

/**
   @name MendeleySimpleNetworkProvider
   As the name suggests this is a very basic implementation of the NetworkProvider using
   NSURLSession based on the use of implicit delegates.
   In short, this means that NSURLSessionTask instances are created with completionHandlers only.
   As a consequence, this class will not act on any progressBlock being passed into it.
 */

@interface MendeleySimpleNetworkProvider : NSObject <MendeleyNetworkProvider, NSURLSessionDelegate>
/**
   A singleton for the simple network provider
 */
+ (MendeleySimpleNetworkProvider *)sharedInstance;
@end
