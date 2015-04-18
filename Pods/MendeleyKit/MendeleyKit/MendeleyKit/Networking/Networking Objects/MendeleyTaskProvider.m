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

#import "MendeleyTaskProvider.h"
#import "MendeleyResponse.h"
#import "NSError+MendeleyError.h"

@implementation MendeleyTaskProvider

+ (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                                      session:(NSURLSession *)session
                              completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (nil != error)
                                          {
                                              completionBlock(nil, error);
                                          }
                                          else
                                          {
                                              MendeleyResponse *theResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                              NSError *responseError = nil;
                                              if (theResponse.isSuccess)
                                              {
                                                  [theResponse deserialiseRawResponseData:data error:&responseError];
                                                  completionBlock(theResponse, responseError);
                                              }
                                              else
                                              {
                                                  responseError = [NSError errorWithCode:kMendeleyJSONTypeUnrecognisedErrorCode localizedDescription:theResponse.responseMessage];
                                                  completionBlock(nil, responseError);
                                              }
                                          }
                                      }];

    return dataTask;
}

+ (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                              session:(NSURLSession *)session
                                        progressBlock:(MendeleyResponseProgressBlock)progressBlock completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request];

//    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request
//                                                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
//
//                                                  if (error)
//                                                  {
//                                                      completionBlock(nil, error);
//                                                  }
//                                                  else
//                                                  {
//                                                      NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], [location lastPathComponent]];
//                                                      NSURL *savedFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fileName]];
//                                                      NSError *errorWhileMovingFile = nil;
//                                                      [[NSFileManager defaultManager] moveItemAtURL:location
//                                                                                              toURL:savedFileURL
//                                                                                              error:&errorWhileMovingFile];
//
//                                                      MendeleyResponse *theResponse = [MendeleyResponse mendeleyReponseForURLResponse:response fileURL:savedFileURL];
//                                                      completionBlock(theResponse, errorWhileMovingFile);
//                                                  }
//                                              }];

    return downloadTask;
}

+ (NSURLSessionUploadTask *)uploadTaskWithRequest:(NSURLRequest *)request
                                          session:(NSURLSession *)session
                                    progressBlock:(MendeleyResponseProgressBlock)progressBlock
                                  completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    return nil;
}

@end
