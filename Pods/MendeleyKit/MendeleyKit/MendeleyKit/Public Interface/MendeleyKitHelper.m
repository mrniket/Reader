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

#import "MendeleyKitHelper.h"
#import "MendeleyResponse.h"
#import "NSError+MendeleyError.h"
#import "MendeleyQueryRequestParameters.h"
#import "MendeleyBlockExecutor.h"
#import "MendeleyModeller.h"
#import "NSError+MendeleyError.h"

@interface MendeleyKitHelper ()

@property (nonatomic, weak) id <MendeleyKitHelperDelegate> delegate;

@end

@implementation MendeleyKitHelper

- (instancetype)initWithDelegate:(id <MendeleyKitHelperDelegate> )delegate
{
    self = [super init];
    if (nil != self)
    {
        [NSError assertArgumentNotNil:delegate argumentName:@"delegate"];
        _delegate = delegate;
    }
    return self;
}

- (BOOL)isSuccessForResponse:(MendeleyResponse *)response
                       error:(NSError **)error
{
    if (nil == response)
    {
        return NO;
    }
    else if ((*error).code == NSURLErrorCancelled)
    {
        return NO;
    }
    else if (!response.isSuccess)
    {
        if (nil == *error)
        {
            *error = [NSError errorWithCode:kMendeleyResponseTypeUnknownErrorCode
                       localizedDescription      :response.responseMessage];
        }
        return NO;
    }
    return YES;
}

- (void)mendeleyObjectListOfType:(NSString *)objectTypeString
                             api:(NSString *)apiString
                      parameters:(NSDictionary *)queryParameters
               additionalHeaders:(NSDictionary *)additionalHeaders
                            task:(MendeleyTask *)task
                 completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    [NSError assertStringArgumentNotNilOrEmpty:objectTypeString argumentName:@"objectTypeString"];
    [NSError assertStringArgumentNotNilOrEmpty:apiString argumentName:@"apiString"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    id <MendeleyNetworkProvider> networkProvider = [self provider];
    NSURL *baseAPIURL = [self URL];
    [networkProvider invokeGET:baseAPIURL
                           api:apiString
             additionalHeaders:additionalHeaders
               queryParameters:queryParameters
        authenticationRequired:YES
                          task:task
               completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithArrayCompletionBlock:completionBlock];
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithArray:nil
                                syncInfo:nil
                                   error:error];
         }
         else
         {
             MendeleyModeller *jsonModeller = [MendeleyModeller sharedInstance];
             [jsonModeller parseJSONData:response.responseBody expectedType:objectTypeString completionBlock: ^(NSArray *folders, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithArray:nil
                                         syncInfo:nil
                                            error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithArray:folders
                                         syncInfo:response.syncHeader
                                            error:nil];
                  }
              }];
         }
     }];
}

- (void)mendeleyIDStringListForAPI:(NSString *)apiString
                        parameters:(NSDictionary *)queryParameters
                 additionalHeaders:(NSDictionary *)additionalHeaders
                              task:(MendeleyTask *)task
                   completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    [NSError assertStringArgumentNotNilOrEmpty:apiString argumentName:@"apiString"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    id <MendeleyNetworkProvider> networkProvider = [self provider];
    NSURL *baseAPIURL = [self URL];
    [networkProvider invokeGET:baseAPIURL
                           api:apiString
             additionalHeaders:additionalHeaders
               queryParameters:queryParameters
        authenticationRequired:YES
                          task:task
               completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithArrayCompletionBlock:completionBlock];
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithArray:nil
                                syncInfo:nil
                                   error:error];
         }
         else
         {
             MendeleyModeller *jsonModeller = [MendeleyModeller sharedInstance];
             id jsonData = response.responseBody;
             if ([jsonData isKindOfClass:[NSArray class]])
             {
                 NSArray *jsonArray = (NSArray *) jsonData;
                 [jsonModeller parseJSONArrayOfIDDictionaries:jsonArray completionBlock:^(NSArray *arrayOfStrings, NSError *parseError) {
                      if (nil != arrayOfStrings)
                      {
                          [blockExec executeWithArray:arrayOfStrings
                                             syncInfo:response.syncHeader
                                                error:nil];
                      }
                      else
                      {
                          [blockExec executeWithArray:nil
                                             syncInfo:nil
                                                error:parseError];
                      }

                  }];
             }
         }
     }];

}



- (void)mendeleyObjectOfType:(NSString *)objectTypeString
                  parameters:(NSDictionary *)queryParameters
                         api:(NSString *)apiString
           additionalHeaders:(NSDictionary *)additionalHeaders
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertStringArgumentNotNilOrEmpty:objectTypeString argumentName:@"objectTypeString"];
    [NSError assertStringArgumentNotNilOrEmpty:apiString argumentName:@"apiString"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    id <MendeleyNetworkProvider> networkProvider = [self provider];
    NSURL *baseAPIURL = [self URL];
    [networkProvider invokeGET:baseAPIURL
                           api:apiString
             additionalHeaders:additionalHeaders
               queryParameters:queryParameters
        authenticationRequired:YES
                          task:task
               completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithObjectCompletionBlock:completionBlock];
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithMendeleyObject:nil
                                         syncInfo:nil
                                            error:error];
         }
         else
         {
             MendeleyModeller *modeller = [MendeleyModeller sharedInstance];
             [modeller parseJSONData:response.responseBody expectedType:objectTypeString completionBlock: ^(MendeleyObject *object, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithMendeleyObject:nil
                                                  syncInfo:nil
                                                     error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithMendeleyObject:object
                                                  syncInfo:response.syncHeader
                                                     error:nil];
                  }
              }];
         }
     }];
}

- (void)createMendeleyObject:(MendeleyObject *)mendeleyObject
                         api:(NSString *)apiString
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:mendeleyObject argumentName:@"mendeleyObject"];
    [NSError assertStringArgumentNotNilOrEmpty:apiString argumentName:@"apiString"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithCompletionBlock:completionBlock];
    MendeleyModeller *modeller = [MendeleyModeller sharedInstance];

    NSError *serialiseError = nil;
    NSData *jsonData = [modeller jsonObjectFromModelOrModels:mendeleyObject error:&serialiseError];
    if (nil == jsonData)
    {
        [blockExec executeWithBool:NO
                             error:serialiseError];
        return;
    }
    id <MendeleyNetworkProvider> networkProvider = [self provider];
    NSURL *baseAPIURL = [self URL];
    [networkProvider invokePOST:baseAPIURL
                            api:apiString
              additionalHeaders:nil
                       jsonData:jsonData
         authenticationRequired:YES
                           task:task
                completionBlock: ^(MendeleyResponse *response, NSError *error) {
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithBool:NO
                                  error:error];
         }
         else
         {
             [blockExec executeWithBool:YES
                                  error:nil];
         }
     }];
}


- (void)createMendeleyObject:(MendeleyObject *)mendeleyObject
                         api:(NSString *)apiString
           additionalHeaders:(NSDictionary *)additionalHeaders
                expectedType:(NSString *)objectTypeString
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:mendeleyObject argumentName:@"mendeleyObject"];
    [NSError assertStringArgumentNotNilOrEmpty:apiString argumentName:@"apiString"];
    [NSError assertStringArgumentNotNilOrEmpty:objectTypeString argumentName:@"objectTypeString"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithObjectCompletionBlock:completionBlock];
    MendeleyModeller *modeller = [MendeleyModeller sharedInstance];

    NSError *serialiseError = nil;
    NSData *jsonData = [modeller jsonObjectFromModelOrModels:mendeleyObject error:&serialiseError];
    if (nil == jsonData)
    {
        [blockExec executeWithMendeleyObject:nil
                                    syncInfo:nil
                                       error:serialiseError];
        return;
    }
    id <MendeleyNetworkProvider> networkProvider = [self provider];
    NSURL *baseAPIURL = [self URL];
    [networkProvider invokePOST:baseAPIURL
                            api:apiString
              additionalHeaders:additionalHeaders
                       jsonData:jsonData
         authenticationRequired:YES
                           task:task
                completionBlock: ^(MendeleyResponse *response, NSError *error) {
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithMendeleyObject:nil
                                         syncInfo:nil
                                            error:error];
         }
         else
         {
             [modeller parseJSONData:response.responseBody expectedType:objectTypeString completionBlock: ^(MendeleyObject *object, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithMendeleyObject:nil
                                                  syncInfo:nil
                                                     error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithMendeleyObject:object
                                                  syncInfo:response.syncHeader
                                                     error:nil];
                  }
              }];
         }
     }];
}

- (void)updateMendeleyObject:(MendeleyObject *)updatedMendeleyObject
                         api:(NSString *)apiString
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self updateMendeleyObject:updatedMendeleyObject
                           api:apiString
             additionalHeaders:nil
                          task:task
               completionBlock:completionBlock];
}

- (void)updateMendeleyObject:(MendeleyObject *)updatedMendeleyObject
                         api:(NSString *)apiString
           additionalHeaders:(NSDictionary *)additionalHeaders
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:updatedMendeleyObject argumentName:@"updatedMendeleyObject"];
    [NSError assertArgumentNotNil:apiString argumentName:@"apiString"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSError *serialiseError = nil;
    MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithCompletionBlock:completionBlock];
    MendeleyModeller *modeller = [MendeleyModeller sharedInstance];

    NSData *jsonData = [modeller jsonObjectFromModelOrModels:updatedMendeleyObject error:&serialiseError];
    if (nil == jsonData)
    {
        [blockExec executeWithBool:NO
                             error:serialiseError];
        return;
    }
    id <MendeleyNetworkProvider> networkProvider = [self provider];
    NSURL *baseAPIURL = [self URL];
    [networkProvider invokePATCH:baseAPIURL
                             api:apiString
               additionalHeaders:additionalHeaders
                        jsonData:jsonData
          authenticationRequired:YES
                            task:task
                 completionBlock: ^(MendeleyResponse *response, NSError *error) {
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithBool:NO
                                  error:error];
         }
         else
         {
             [blockExec executeWithBool:YES
                                  error:nil];
         }
     }];
}

- (void)updateMendeleyObject:(MendeleyObject *)updatedMendeleyObject
                         api:(NSString *)apiString
           additionalHeaders:(NSDictionary *)additionalHeaders
                expectedType:(NSString *)objectTypeString
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:updatedMendeleyObject argumentName:@"updatedMendeleyObject"];
    [NSError assertArgumentNotNil:apiString argumentName:@"apiString"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithObjectCompletionBlock:completionBlock];
    MendeleyModeller *modeller = [MendeleyModeller sharedInstance];

    NSError *serialiseError = nil;
    NSData *jsonData = [modeller jsonObjectFromModelOrModels:updatedMendeleyObject error:&serialiseError];
    if (nil == jsonData)
    {
        [blockExec executeWithMendeleyObject:nil
                                    syncInfo:nil
                                       error:serialiseError];
        return;
    }
    id <MendeleyNetworkProvider> networkProvider = [self provider];
    NSURL *baseAPIURL = [self URL];
    [networkProvider invokePATCH:baseAPIURL
                             api:apiString
               additionalHeaders:additionalHeaders
                        jsonData:jsonData
          authenticationRequired:YES
                            task:task
                 completionBlock: ^(MendeleyResponse *response, NSError *error) {
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithMendeleyObject:nil
                                         syncInfo:nil
                                            error:error];
         }
         else
         {
             [modeller parseJSONData:response.responseBody expectedType:objectTypeString completionBlock: ^(MendeleyObject *object, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithMendeleyObject:nil
                                                  syncInfo:nil
                                                     error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithMendeleyObject:object
                                                  syncInfo:response.syncHeader
                                                     error:nil];
                  }
              }];
         }
     }];
}

- (void)deleteMendeleyObjectWithAPI:(NSString *)apiString
                               task:(MendeleyTask *)task
                    completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertStringArgumentNotNilOrEmpty:apiString argumentName:@"apiString"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    id <MendeleyNetworkProvider> networkProvider = [self provider];
    NSURL *baseAPIURL = [self URL];
    [networkProvider invokeDELETE:baseAPIURL
                              api:apiString
                additionalHeaders:nil
                   bodyParameters:nil
           authenticationRequired:YES
                             task:task
                  completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithCompletionBlock:completionBlock];
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithBool:NO
                                  error:error];
         }
         else
         {
             [blockExec executeWithBool:YES
                                  error:nil];
         }
     }];
}

- (void)downloadFileWithAPI:(NSString *)apiString
                  saveToURL:(NSURL *)fileURL
                       task:(MendeleyTask *)task
              progressBlock:(MendeleyResponseProgressBlock)progressBlock
            completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertStringArgumentNotNilOrEmpty:apiString argumentName:@"apiString"];
    [NSError assertArgumentNotNil:fileURL argumentName:@"fileURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    [self.provider invokeDownloadToFileURL:fileURL
                                   baseURL:[self URL]
                                       api:apiString
                         additionalHeaders:nil
                           queryParameters:nil
                    authenticationRequired:YES
                                      task:task
                             progressBlock:progressBlock
                           completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithCompletionBlock:completionBlock];
         if (![self isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithBool:NO
                                  error:error];
         }
         else if (![[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
         {
             NSError *pathError = [NSError errorWithCode:kMendeleyPathNotFoundErrorCode];
             [blockExec executeWithBool:NO
                                  error:pathError];
         }
         else
         {
             [blockExec executeWithBool:YES
                                  error:nil];
         }
     }];
}

#pragma mark -
#pragma mark Private methods

- (id <MendeleyNetworkProvider> )provider
{
    id <MendeleyNetworkProvider> provider = [self.delegate networkProvider];

    [NSError assertArgumentNotNil:provider argumentName:@"networkProvider"];
    return provider;
}

- (NSURL *)URL
{
    NSURL *url = [self.delegate baseAPIURL];

    [NSError assertArgumentNotNil:url argumentName:@"baseAPIURL"];
    return url;
}

@end
