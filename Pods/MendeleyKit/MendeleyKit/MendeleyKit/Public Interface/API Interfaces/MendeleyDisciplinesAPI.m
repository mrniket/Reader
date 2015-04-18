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

#import "MendeleyDisciplinesAPI.h"
#import "MendeleyKitConfiguration.h"
#import "MendeleyOAuthCredentials.h"

@implementation MendeleyDisciplinesAPI
- (NSDictionary *)defaultServiceRequestHeadersFromCredentials:(MendeleyOAuthCredentials *)credentials
{
    NSDictionary *authenticationHeader = [credentials authenticationHeader];
    NSMutableDictionary *requestHeader = [NSMutableDictionary dictionaryWithDictionary:authenticationHeader];

    [requestHeader setObject:kMendeleyRESTRequestJSONDisciplineType forKey:kMendeleyRESTRequestAccept];
    return requestHeader;
}

- (void)disciplinesWithTask:(MendeleyTask *)task
            completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    [[MendeleyKitConfiguration sharedInstance].oauthProvider authenticateClientWithCompletionBlock:^(MendeleyOAuthCredentials *credentials, NSError *error){

         if (nil == credentials)
         {
             completionBlock(nil, nil, error);
         }
         else
         {
             NSDictionary *requestHeader = [self defaultServiceRequestHeadersFromCredentials:credentials];

             MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithArrayCompletionBlock:completionBlock];

             id <MendeleyNetworkProvider> networkProvider = [self provider];
             [networkProvider invokeGET:self.baseURL
                                    api:kMendeleyRESTAPIDisciplines
                      additionalHeaders:requestHeader
                        queryParameters:nil
                 authenticationRequired:NO
                                   task:task
                        completionBlock: ^(MendeleyResponse *response, NSError *error) {
                  if (![self.helper isSuccessForResponse:response error:&error])
                  {
                      [blockExec executeWithArray:nil
                                         syncInfo:nil
                                            error:error];
                  }
                  else
                  {
                      MendeleyModeller *jsonModeller = [MendeleyModeller sharedInstance];
                      [jsonModeller parseJSONData:response.responseBody
                                     expectedType:kMendeleyModelDiscipline
                                  completionBlock: ^(NSArray *disciplines, NSError *parseError) {
                           if (nil != parseError)
                           {
                               [blockExec executeWithArray:nil
                                                  syncInfo:nil
                                                     error:parseError];
                           }
                           else
                           {
                               [blockExec executeWithArray:disciplines
                                                  syncInfo:response.syncHeader
                                                     error:nil];
                           }
                       }];
                  }
              }];

         }
     }];

}

@end
