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

#import "MendeleyDefaultOAuthProvider.h"
#import "MendeleyOAuthConstants.h"
#import "MendeleyOAuthCredentials.h"
#import "MendeleyOAuthStore.h"
#import "MendeleyKitConfiguration.h"
#import "MendeleyModeller.h"
#import "NSError+MendeleyError.h"
#import "MendeleyURLBuilder.h"
#import "MendeleyBlockExecutor.h"

@interface MendeleyDefaultOAuthProvider ()
@property (nonatomic, strong, readwrite) NSURL *oauth2BaseURL;
@property (nonatomic, assign, readwrite) BOOL isTrustedSSLServer;
@property (nonatomic, copy) MendeleyOAuthCompletionBlock completionBlock;
@property (nonatomic, strong) NSString *baseURL;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, strong) MendeleyOAuthCredentials *oauthCredentials;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectURI;
@end

@implementation MendeleyDefaultOAuthProvider
+ (MendeleyDefaultOAuthProvider *)sharedInstance
{
    static MendeleyDefaultOAuthProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[MendeleyDefaultOAuthProvider alloc] init];

    });
    return sharedInstance;

}

- (void)configureOAuthWithParameters:(NSDictionary *)parameters
{
    [NSError assertArgumentNotNil:parameters argumentName:@"parameters"];
    id idObject = [parameters objectForKey:kMendeleyOAuth2ClientIDKey];

    if (nil != idObject && [idObject isKindOfClass:[NSString class]])
    {
        self.clientID = (NSString *) idObject;
    }

    id secretObj = [parameters objectForKey:kMendeleyOAuth2ClientSecretKey];
    if (nil != secretObj && [secretObj isKindOfClass:[NSString class]])
    {
        self.clientSecret = (NSString *) secretObj;
    }

    id redirectURI = [parameters objectForKey:kMendeleyOAuth2RedirectURLKey];
    if (nil != redirectURI && [redirectURI isKindOfClass:[NSString class]])
    {
        self.redirectURI = redirectURI;
    }
}

- (BOOL)urlStringIsRedirectURI:(NSString *)urlString
{
    return [urlString hasPrefix:self.redirectURI];
}


- (void)authenticateWithUserName:(NSString *)username
                        password:(NSString *)password
                 completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:username argumentName:@"username"];
    [NSError assertArgumentNotNil:password argumentName:@"password"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSDictionary *parameters = @{ kMendeleyOAuth2Username: username,
                                  kMendeleyOAuth2Password: password,
                                  kMendeleyOAuthAuthorizationCodeKey: kMendeleyOAuth2Password,
                                  kMendeleyOAuth2ScopeKey: kMendeleyOAuth2Scope,
                                  kMendeleyOAuth2ClientIDKey: self.clientID,
                                  kMendeleyOAuth2ClientSecretKey: self.clientSecret };
    NSDictionary *requestHeader = @{ kMendeleyRESTRequestContentType : kMendeleyRESTRequestURLType,
                                     kMendeleyRESTRequestAccept : kMendeleyRESTRequestJSONType };
    NSURL *baseURL = [MendeleyKitConfiguration sharedInstance].baseAPIURL;
    NSURL *oauthURL = [NSURL URLWithString:kMendeleyOAuthPathOAuth2Token relativeToURL:baseURL];
    id<MendeleyNetworkProvider>networkProvider = [MendeleyKitConfiguration sharedInstance].networkProvider;
    [networkProvider invokePOST:oauthURL
                            api:nil
              additionalHeaders:requestHeader
                 bodyParameters:parameters
                         isJSON:NO
         authenticationRequired:NO
                           task:nil
                completionBlock:^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithCompletionBlock:completionBlock];

         if (nil == response)
         {
             [blockExec executeWithBool:NO
                                  error:error];
         }
         else
         {
             MendeleyModeller *modeller = [MendeleyModeller sharedInstance];
             [modeller parseJSONData:response.responseBody expectedType:kMendeleyModelOAuthCredentials completionBlock:^(MendeleyOAuthCredentials *credentials, NSError *parseError) {
                  if (nil != credentials)
                  {
                      MendeleyOAuthStore *oauthStore = [[MendeleyOAuthStore alloc] init];
                      BOOL success = [oauthStore storeOAuthCredentials:credentials];
                      if (success)
                      {
                          [blockExec executeWithBool:YES
                                               error:nil];
                      }
                      else
                      {
                          NSError *innerError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
                          [blockExec executeWithBool:NO
                                               error:innerError];
                      }
                  }
                  else
                  {
                      [blockExec executeWithBool:NO
                                           error:parseError];
                  }
              }];

         }

     }];

}


- (void)authenticateWithAuthenticationCode:(NSString *)authenticationCode
                           completionBlock:(MendeleyOAuthCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:authenticationCode argumentName:@"authenticationCode"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSDictionary *requestBody = @{ kMendeleyOAuthAuthorizationCodeKey : kMendeleyOAuthAuthorizationCode,
                                   kMendeleyOAuth2RedirectURLKey : self.redirectURI,
                                   kMendeleyOAuth2ResponseType : authenticationCode,
                                   kMendeleyOAuth2ClientSecretKey : self.clientSecret,
                                   kMendeleyOAuth2ClientIDKey : self.clientID };

    NSDictionary *requestHeader = @{ kMendeleyRESTRequestContentType : kMendeleyRESTRequestURLType,
                                     kMendeleyRESTRequestAccept : kMendeleyRESTRequestJSONType };

    [self executeAuthenticationRequestWithRequestHeader:requestHeader
                                            requestBody:requestBody
                                        completionBlock:completionBlock];
}


- (void)refreshTokenWithOAuthCredentials:(MendeleyOAuthCredentials *)credentials
                         completionBlock:(MendeleyOAuthCompletionBlock)completionBlock
{
    [self refreshTokenWithOAuthCredentials:credentials
                                      task:nil
                           completionBlock:completionBlock];
}

- (void)refreshTokenWithOAuthCredentials:(MendeleyOAuthCredentials *)credentials
                                    task:(id)task
                         completionBlock:(MendeleyOAuthCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:credentials argumentName:@"credentials"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSDictionary *requestBody = @{ kMendeleyOAuthAuthorizationCodeKey: kMendeleyOAuth2RefreshToken,
                                   kMendeleyOAuth2RefreshToken : credentials.refresh_token,
                                   kMendeleyOAuth2ClientSecretKey : self.clientSecret,
                                   kMendeleyOAuth2ClientIDKey : self.clientID };
    
    NSDictionary *requestHeader = @{ kMendeleyRESTRequestContentType : kMendeleyRESTRequestURLType,
                                     kMendeleyRESTRequestAccept : kMendeleyRESTRequestJSONType };
    [self executeAuthenticationRequestWithTask:task
                                 requestHeader:requestHeader
                                            requestBody:requestBody
                                        completionBlock:completionBlock];
}

- (void)authenticateClientWithCompletionBlock:(MendeleyOAuthCompletionBlock)completionBlock
{
    NSDictionary *requestBody = @{ kMendeleyOAuthAuthorizationCodeKey : kMendeleyOAuthClientCredentials,
                                   kMendeleyOAuth2ScopeKey : kMendeleyOAuth2Scope,
                                   kMendeleyOAuth2ClientSecretKey : self.clientSecret,
                                   kMendeleyOAuth2ClientIDKey : self.clientID };
    NSDictionary *requestHeader = @{ kMendeleyRESTRequestContentType : kMendeleyRESTRequestURLType,
                                     kMendeleyRESTRequestAccept : kMendeleyRESTRequestJSONType };

    [self executeAuthenticationRequestWithRequestHeader:requestHeader
                                            requestBody:requestBody
                                        completionBlock:completionBlock];
}


#pragma mark private methods

- (void)executeAuthenticationRequestWithTask:(MendeleyTask *)task
                               requestHeader:(NSDictionary *)requestHeader
                                          requestBody:(NSDictionary *)requestBody
                                      completionBlock:(MendeleyOAuthCompletionBlock)completionBlock
{
    id<MendeleyNetworkProvider>networkProvider = [MendeleyKitConfiguration sharedInstance].networkProvider;
    [networkProvider invokePOST:[MendeleyKitConfiguration sharedInstance].baseAPIURL
                            api:kMendeleyOAuthPathOAuth2Token
              additionalHeaders:requestHeader
                 bodyParameters:requestBody
                         isJSON:NO
         authenticationRequired:NO
                           task:task
                completionBlock:^(MendeleyResponse *response, NSError *error) {
                    MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithOAuthCompletionBlock:completionBlock];
                    if (nil == response)
                    {
                        [blockExec executeWithCredentials:nil error:error];
                    }
                    else
                    {
                        MendeleyModeller *modeller = [MendeleyModeller sharedInstance];
                        [modeller parseJSONData:response.responseBody expectedType:kMendeleyModelOAuthCredentials completionBlock:^(MendeleyOAuthCredentials *credentials, NSError *parseError) {
                            [blockExec executeWithCredentials:credentials error:parseError];
                        }];
                        
                    }
                    
                }];
}

- (void)executeAuthenticationRequestWithRequestHeader:(NSDictionary *)requestHeader
                                          requestBody:(NSDictionary *)requestBody
                                      completionBlock:(MendeleyOAuthCompletionBlock)completionBlock
{
    [self executeAuthenticationRequestWithTask:nil requestHeader:requestHeader requestBody:requestBody completionBlock:completionBlock];
}


@end
