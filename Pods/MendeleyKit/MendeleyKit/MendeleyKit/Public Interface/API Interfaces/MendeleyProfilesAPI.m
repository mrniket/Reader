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

#import "MendeleyProfilesAPI.h"
#import "MendeleyKitConfiguration.h"
#import "MendeleyOAuthCredentials.h"

@implementation MendeleyProfilesAPI

- (NSDictionary *)newProfileRequestHeaderFromCredentials:(MendeleyOAuthCredentials *)credentials
{
    if (nil == credentials)
    {
        return nil;
    }
    NSDictionary *authenticationHeader = [credentials authenticationHeader];
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithDictionary:authenticationHeader];
    [requestHeader setObject:kMendeleyRESTRequestJSONProfilesType
                      forKey:kMendeleyRESTRequestAccept];

    [requestHeader setObject:kMendeleyRESTRequestJSONNewProfilesType
                      forKey:kMendeleyRESTRequestContentType];

    return requestHeader;
}

- (NSDictionary *)updateProfileRequestHeader
{
    NSMutableDictionary *requestHeader = [NSMutableDictionary new];

    [requestHeader addEntriesFromDictionary:[self defaultServiceRequestHeaders]];

    [requestHeader setObject:kMendeleyRESTRequestJSONProfileUpdateType
                      forKey:kMendeleyRESTRequestContentType];

    return requestHeader;
}

- (NSDictionary *)defaultServiceRequestHeaders
{
    return @{ kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONProfilesType };
}

- (void)pullMyProfileWithTask:(MendeleyTask *)task completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [self.helper mendeleyObjectOfType:kMendeleyModelUserProfile
                           parameters:nil
                                  api:kMendeleyRESTAPIProfilesMe
                    additionalHeaders:[self defaultServiceRequestHeaders]
                                 task:task
                      completionBlock:completionBlock];
}

- (void)pullProfile:(NSString *)profileID
               task:(MendeleyTask *)task
    completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:profileID argumentName:@"profileID"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *apiEndpoint = [NSString stringWithFormat:kMendeleyRESTAPIProfilesWithID, profileID];
    [self.helper mendeleyObjectOfType:kMendeleyModelProfile
                           parameters:nil
                                  api:apiEndpoint
                    additionalHeaders:[self defaultServiceRequestHeaders]
                                 task:task
                      completionBlock:completionBlock];
}

- (void)profileIconForProfile:(MendeleyProfile *)profile
                     iconType:(MendeleyIconType)iconType
                         task:(MendeleyTask *)task
              completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:profile argumentName:@"profile"];
    NSError *error = nil;
    NSString *linkURLString = [self linkFromPhoto:profile.photo
                                         iconType:iconType
                                             task:task
                                            error:&error];
    if (nil == linkURLString)
    {
        error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain
                                                                  code:kMendeleyDataNotAvailableErrorCode];
        completionBlock(nil, error);
    }
    else
    {
        [self profileIconForIconURLString:linkURLString task:task completionBlock:completionBlock];
    }
}

- (void)profileIconForIconURLString:(NSString *)iconURLString
                               task:(MendeleyTask *)task
                    completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:iconURLString argumentName:@"iconURLString"];
    NSURL *url = [NSURL URLWithString:iconURLString];
    NSDictionary *requestHeader = [self requestHeaderForImageLink:iconURLString];
    [self.provider invokeGET:url
                         api:nil
           additionalHeaders:requestHeader
             queryParameters:nil
      authenticationRequired:NO
                        task:task
             completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithBinaryDataCompletionBlock:completionBlock];
         if (![self.helper isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithBinaryData:nil
                                        error:error];
         }
         else
         {
             id bodyData = response.responseBody;
             if ([bodyData isKindOfClass:[NSData class]])
             {
                 [blockExec executeWithBinaryData:bodyData
                                            error:nil];
             }
             else
             {
                 [blockExec executeWithBinaryData:nil
                                            error:error];
             }
         }
     }];
}

- (void)createProfile:(MendeleyNewProfile *)profile
                 task:(MendeleyTask *)task
      completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:profile argumentName:@"profile"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    [[MendeleyKitConfiguration sharedInstance].oauthProvider authenticateClientWithCompletionBlock: ^(MendeleyOAuthCredentials *credentials, NSError *error) {
         if (nil == credentials)
         {
             completionBlock(nil, nil, error);
         }
         else
         {
             NSDictionary *requestHeader = [self newProfileRequestHeaderFromCredentials:credentials];

             MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithObjectCompletionBlock:completionBlock];
             MendeleyModeller *modeller = [MendeleyModeller sharedInstance];

             NSError *serialiseError = nil;
             NSData *jsonData = [modeller jsonObjectFromModelOrModels:profile error:&serialiseError];
             if (nil == jsonData)
             {
                 [blockExec executeWithMendeleyObject:nil
                                             syncInfo:nil
                                                error:serialiseError];
                 return;
             }
             id <MendeleyNetworkProvider> networkProvider = [self provider];
             [networkProvider invokePOST:self.baseURL
                                     api:kMendeleyRESTAPIProfiles
                       additionalHeaders:requestHeader
                                jsonData:jsonData
                  authenticationRequired:NO
                                    task:task
                         completionBlock: ^(MendeleyResponse *response, NSError *error) {
                  if (![self.helper isSuccessForResponse:response error:&error])
                  {
                      [blockExec executeWithMendeleyObject:nil
                                                  syncInfo:nil
                                                     error:error];
                  }
                  else
                  {
                      [modeller parseJSONData:response.responseBody expectedType:kMendeleyModelProfile completionBlock: ^(MendeleyObject *object, NSError *parseError) {
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
     }];
}

- (void)updateMyProfile:(MendeleyAmendmentProfile *)myProfile
                   task:(MendeleyTask *)task
        completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:myProfile argumentName:@"myProfile"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [self.helper updateMendeleyObject:myProfile
                                  api:kMendeleyRESTAPIProfilesMe
                    additionalHeaders:[self updateProfileRequestHeader]
                         expectedType:kMendeleyModelProfile
                                 task:task
                      completionBlock:completionBlock];
}

@end