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

@class MendeleyNetworkTask;

@interface MendeleyDataHelper : NSObject
/**
   @name This class provides callback methods for download tasks. Used in conjunction with the
   Default Network Provider (NSURLSession based)
 */
/**
   @param session
   @param dataTask
   @param response
   @param completionHandler
 */
- (void)    URLSession:(NSURLSession *)session
              dataTask:(MendeleyNetworkTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler;

/**
   @param session
   @param task
   @param error
 */
- (void)      URLSession:(NSURLSession *)session
                    task:(MendeleyNetworkTask *)task
    didCompleteWithError:(NSError *)error;

@end
