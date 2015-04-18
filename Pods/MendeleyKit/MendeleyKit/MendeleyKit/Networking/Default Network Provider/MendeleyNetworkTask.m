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

#import "MendeleyNetworkTask.h"
#import "MendeleyResponse.h"
#import "NSError+MendeleyError.h"

@interface MendeleyNetworkTask ()

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong, readwrite) NSNumber *taskID;
@property (copy, nonatomic, readwrite) MendeleyResponseCompletionBlock completionBlock;

@end

@implementation MendeleyNetworkTask

#pragma mark - Task Builders

- (instancetype)initTaskWithRequest:(NSURLRequest *)request
                            session:(NSURLSession *)session
                    completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    self = [super init];
    if (self)
    {
        self.task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                                 if (0 != data.length)
                                 {
                                     [theResponse deserialiseRawResponseData:data error:&responseError];
                                 }
                                 completionBlock(theResponse, responseError);
                             }
                             else
                             {
                                 responseError = [NSError errorWithMendeleyResponse:theResponse requestURL:request.URL failureBody:data];
                                 completionBlock(theResponse, responseError);
                             }
                         }
                     }];

        self.taskID = [NSNumber numberWithUnsignedInteger:self.task.taskIdentifier];
    }
    return self;
}

- (void)executeTask
{
    [self.task resume];
}

- (void)cancelTaskWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self.task cancel];
    if (completionBlock)
    {
        completionBlock(YES, nil);
    }
}

@end

@interface MendeleyNetworkUploadTask ()

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong, readwrite) NSNumber *taskID;
@property (copy, nonatomic, readwrite) MendeleyResponseProgressBlock progressBlock;


@end

@implementation MendeleyNetworkUploadTask

@dynamic taskID;
@dynamic task;

- (instancetype)initUploadTaskWithRequest:(NSURLRequest *)request
                                  session:(NSURLSession *)session
                                  fileURL:(NSURL *)fileURL
                            progressBlock:(MendeleyResponseProgressBlock)progressBlock
                          completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    self = [super init];
    if (nil != self)
    {

        self.task = [session uploadTaskWithRequest:request
                                          fromFile:fileURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
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
                                 responseError = [NSError errorWithMendeleyResponse:theResponse requestURL:request.URL];
                                 completionBlock(nil, responseError);
                             }
                         }


                     }];
        self.taskID = [NSNumber numberWithUnsignedInteger:self.task.taskIdentifier];
        self.progressBlock = progressBlock;
    }
    return self;
}

@end

@interface MendeleyNetworkDownloadTask ()

@property (nonatomic, strong) NSURLSessionTask *task;
@property (nonatomic, strong, readwrite) NSNumber *taskID;
@property (copy, nonatomic, readwrite) NSURL *fileURL;
@property (copy, nonatomic, readwrite) MendeleyResponseProgressBlock progressBlock;
@property (copy, nonatomic) NSURLSessionDownloadTask *downloadTask;

@end

@implementation MendeleyNetworkDownloadTask

@dynamic taskID;
@dynamic task;

- (instancetype)initDownloadTaskWithRequest:(NSURLRequest *)request
                                    session:(NSURLSession *)session
                                    fileURL:(NSURL *)fileURL
                              progressBlock:(MendeleyResponseProgressBlock)progressBlock
                            completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    self = [super init];
    if (nil != self)
    {
        self.fileURL = fileURL;
        self.task = [session dataTaskWithRequest:request];
        self.taskID = [NSNumber numberWithUnsignedInteger:self.task.taskIdentifier];
        self.progressBlock = progressBlock;
        self.completionBlock = completionBlock;
    }
    return self;
}

- (void)addRealDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    self.downloadTask = downloadTask;
}

- (void)cancelTaskWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self.task cancel];
    [self.downloadTask cancel];
    if (completionBlock)
    {
        completionBlock(YES, nil);
    }
}

@end
