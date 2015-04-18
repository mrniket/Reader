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

@interface MendeleyTaskProvider : NSObject
/**
   This creates a generic NSURLSessionTask
   @param request
   @param session
   @param completionBlock
 */
+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                      session:(NSURLSession *)session
                              completionBlock:(MendeleyResponseCompletionBlock)completionBlock;

/**
   This creates a download task
   @param request
   @param session
   @param progressBlock
   @param completionBlock
 */
+ (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                              session:(NSURLSession *)session
                                        progressBlock:(MendeleyResponseProgressBlock)progressBlock
                                      completionBlock:(MendeleyResponseCompletionBlock)completionBlock;

/**
   This creates a download task
   @param request
   @param session
   @param progressBlock
   @param completionBlock
 */
+ (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                          session:(NSURLSession *)session
                                    progressBlock:(MendeleyResponseProgressBlock)progressBlock
                                  completionBlock:(MendeleyResponseCompletionBlock)completionBlock;

@end
