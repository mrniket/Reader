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

#import "MendeleySimpleNetworkProvider.h"
#import "MendeleyRequest.h"
#import "MendeleyLog.h"
#import "NSError+MendeleyError.h"
#import "MendeleyURLBuilder.h"
#import "MendeleySimpleNetworkTask.h"

static NSURLSessionConfiguration * defaultSimpleConfiguration()
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSMutableDictionary *defaultHeaders = [NSMutableDictionary dictionaryWithDictionary:[MendeleyURLBuilder defaultHeader]];

    [defaultHeaders setObject:kMendeleyRESTRequestJSONType forKey:kMendeleyRESTRequestAccept];
    configuration.HTTPAdditionalHeaders = defaultHeaders;
    return configuration;
}

@interface MendeleySimpleNetworkProvider ()
@property (nonatomic, strong) NSMutableDictionary *writableTaskDictionary;
@property (nonatomic, strong) NSURLSession *session;
@end

@implementation MendeleySimpleNetworkProvider
+ (MendeleySimpleNetworkProvider *)sharedInstance
{
    static MendeleySimpleNetworkProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
                      sharedInstance = [[MendeleySimpleNetworkProvider alloc] init];
                      // Do any other initialisation stuff here
                  });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _writableTaskDictionary = [NSMutableDictionary dictionary];
        _session = [NSURLSession sessionWithConfiguration:defaultSimpleConfiguration()
                                                 delegate:self
                                            delegateQueue:nil];
    }
    return self;
}

- (void)cancelAllTasks:(MendeleyCompletionBlock)completionBlock
{
    [self.writableTaskDictionary enumerateKeysAndObjectsUsingBlock: ^(NSNumber *taskID, MendeleySimpleNetworkTask *simpleTask, BOOL *stop) {
         [simpleTask.sessionTask cancel];
         NSError *cancelError = [NSError errorWithCode:kMendeleyCancelledRequestErrorCode];
         simpleTask.completionBlock(nil, cancelError);
     }];

    [self.writableTaskDictionary removeAllObjects];
}

- (void) cancelTask:(MendeleyTask *)mendeleyTask
    completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleySimpleNetworkTask *sessionTask = self.writableTaskDictionary[mendeleyTask.taskID];

    if (nil != sessionTask)
    {
        MendeleyResponseCompletionBlock responseBlock = sessionTask.completionBlock;
        [sessionTask.sessionTask cancel];
        if (nil != responseBlock)
        {
            NSError *cancelError = [NSError errorWithCode:kMendeleyCancelledRequestErrorCode];
            responseBlock(nil, cancelError);
            [self.writableTaskDictionary removeObjectForKey:mendeleyTask.taskID];
        }
    }
}

- (void)invokeDownloadToFileURL:(NSURL *)fileURL
                        baseURL:(NSURL *)baseURL
                            api:(NSString *)api
              additionalHeaders:(NSDictionary *)additionalHeaders
                queryParameters:(NSDictionary *)queryParameters
         authenticationRequired:(BOOL)authenticationRequired
                           task:(MendeleyTask *)task
                  progressBlock:(MendeleyResponseProgressBlock)progressBlock
                completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:api argumentName:@"api"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_GET];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_GET];
    }
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    if (nil != queryParameters)
    {
        [request addParametersToURL:queryParameters isQuery:YES];
    }

    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                  MendeleyResponse *mendeleyResponse = nil;
                                                  if (nil != location)
                                                  {
                                                      NSError *errorWhileMovingFile = nil;
                                                      [[NSFileManager defaultManager] moveItemAtURL:location
                                                                                              toURL:fileURL
                                                                                              error:&errorWhileMovingFile];
                                                      if (nil == errorWhileMovingFile)
                                                      {
                                                          mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response
                                                                                                                     fileURL:fileURL];
                                                      }
                                                      else
                                                      {
                                                          error = errorWhileMovingFile;
                                                      }
                                                  }
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                     completionBlock(mendeleyResponse, error);
                                                                 });
                                              }];

    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:downloadTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [downloadTask resume];
}

- (void)invokeUploadForFileURL:(NSURL *)fileURL
                       baseURL:(NSURL *)baseURL
                           api:(NSString *)api
             additionalHeaders:(NSDictionary *)additionalHeaders
        authenticationRequired:(BOOL)authenticationRequired
                          task:(MendeleyTask *)task
                 progressBlock:(MendeleyResponseProgressBlock)progressBlock
               completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"fileURL"];
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:api argumentName:@"api"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];


    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_POST];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_POST];
    }
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    NSURLSessionUploadTask *uploadTask = [self.session uploadTaskWithRequest:request.mutableURLRequest fromFile:fileURL completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                              MendeleyResponse *mendeleyResponse = nil;
                                              if (nil != response)
                                              {
                                                  mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                              }
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                 completionBlock(mendeleyResponse, error);
                                                             });
                                          }];

    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:uploadTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [uploadTask resume];
}

- (void)         invokeGET:(NSURL *)linkURL
         additionalHeaders:(NSDictionary *)additionalHeaders
           queryParameters:(NSDictionary *)queryParameters
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    return [self invokeGET:linkURL
                               api:nil
                 additionalHeaders:additionalHeaders
                   queryParameters:queryParameters
            authenticationRequired:authenticationRequired
                              task:task
                   completionBlock:completionBlock];
}

- (void)         invokeGET:(NSURL *)baseURL
                       api:(NSString *)api
         additionalHeaders:(NSDictionary *)additionalHeaders
           queryParameters:(NSDictionary *)queryParameters
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_GET];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_GET];
    }
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    if (nil != queryParameters)
    {
        [request addParametersToURL:queryParameters isQuery:YES];
    }

    NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                         MendeleyResponse *mendeleyResponse = nil;
                                         if (nil != response)
                                         {
                                             mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                         }
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                            completionBlock(mendeleyResponse, error);
                                                        });
                                     }];

    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:sessionTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [sessionTask resume];
}

- (void)       invokePATCH:(NSURL *)baseURL
                       api:(NSString *)api
         additionalHeaders:(NSDictionary *)additionalHeaders
            bodyParameters:(NSDictionary *)bodyParameters
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_PATCH];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_PATCH];
    }
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                         MendeleyResponse *mendeleyResponse = nil;
                                         if (nil != response)
                                         {
                                             mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                         }
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                            completionBlock(mendeleyResponse, error);
                                                        });
                                     }];

    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:sessionTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [sessionTask resume];
}

- (void)       invokePATCH:(NSURL *)baseURL
                       api:(NSString *)api
         additionalHeaders:(NSDictionary *)additionalHeaders
                  jsonData:(NSData *)jsonData
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:jsonData argumentName:@"jsonData"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_PATCH];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_PATCH];
    }
    [request.mutableURLRequest setHTTPBody:jsonData];
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                         MendeleyResponse *mendeleyResponse = nil;
                                         if (nil != response)
                                         {
                                             mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                         }
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                            completionBlock(mendeleyResponse, error);
                                                        });
                                     }];
    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:sessionTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [sessionTask resume];
}

- (void)        invokePOST:(NSURL *)baseURL
                       api:(NSString *)api
         additionalHeaders:(NSDictionary *)additionalHeaders
            bodyParameters:(NSDictionary *)bodyParameters
                    isJSON:(BOOL)isJSON
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_POST];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_POST];
    }
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    if (nil != bodyParameters)
    {
        [request addBodyWithParameters:bodyParameters
                                isJSON:isJSON];
    }

    NSURLSessionDataTask *sessionTask = [self.session dataTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                             MendeleyResponse *mendeleyResponse = nil;
                                             if (nil != response)
                                             {
                                                 mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                completionBlock(mendeleyResponse, error);
                                                            });
                                         }];

    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:sessionTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [sessionTask resume];
}

- (void)        invokePOST:(NSURL *)baseURL
                       api:(NSString *)api
         additionalHeaders:(NSDictionary *)additionalHeaders
                  jsonData:(NSData *)jsonData
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:jsonData argumentName:@"jsonData"];
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_POST];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_POST];
    }
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    [request addBodyData:jsonData];
    NSURLSessionDataTask *sessionTask = [self.session dataTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                             MendeleyResponse *mendeleyResponse = nil;
                                             if (nil != response)
                                             {
                                                 mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                completionBlock(mendeleyResponse, error);
                                                            });
                                         }];

    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:sessionTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [sessionTask resume];
}

- (void)         invokePUT:(NSURL *)baseURL
                       api:(NSString *)api
         additionalHeaders:(NSDictionary *)additionalHeaders
            bodyParameters:(NSDictionary *)bodyParameters
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_PUT];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_PUT];
    }
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    NSURLSessionDataTask *sessionTask = [self.session dataTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                             MendeleyResponse *mendeleyResponse = nil;
                                             if (nil != response)
                                             {
                                                 mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                completionBlock(mendeleyResponse, error);
                                                            });
                                         }];
    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:sessionTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [sessionTask resume];
}

- (void)      invokeDELETE:(NSURL *)baseURL
                       api:(NSString *)api
         additionalHeaders:(NSDictionary *)additionalHeaders
            bodyParameters:(NSDictionary *)bodyParameters
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_DELETE];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_DELETE];
    }
    if (nil != additionalHeaders)
    {
        [request addHeaderWithParameters:additionalHeaders];
    }
    NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                         MendeleyResponse *mendeleyResponse = nil;
                                         if (nil != response)
                                         {
                                             mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                         }
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                            completionBlock(mendeleyResponse, error);
                                                        });
                                     }];
    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:sessionTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [sessionTask resume];
}

- (void)        invokeHEAD:(NSURL *)baseURL
                       api:(NSString *)api
    authenticationRequired:(BOOL)authenticationRequired
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyRequest *request;
    if (authenticationRequired)
    {
        request = [MendeleyRequest authenticatedRequestWithBaseURL:baseURL
                                                               api:api
                                                       requestType:HTTP_HEAD];
    }
    else
    {
        request = [MendeleyRequest requestWithBaseURL:baseURL
                                                  api:api
                                          requestType:HTTP_HEAD];
    }
    NSURLSessionTask *sessionTask = [self.session dataTaskWithRequest:request.mutableURLRequest completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
                                         MendeleyResponse *mendeleyResponse = nil;
                                         if (nil != response)
                                         {
                                             mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
                                         }
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                            completionBlock(mendeleyResponse, error);
                                                        });
                                     }];
    MendeleySimpleNetworkTask *simpleNetworkTask = [[MendeleySimpleNetworkTask alloc] initWithSessionTask:sessionTask completionBlock:completionBlock];
    [self.writableTaskDictionary setObject:simpleNetworkTask forKey:task.taskID];
    [sessionTask resume];
}

@end
