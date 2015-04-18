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
#import "MendeleyOAuthCredentials.h"
#import "MendeleyTask.h"

@protocol MendeleyOAuthProvider <NSObject>
@property (nonatomic, assign, readonly) BOOL isTrustedSSLServer;
/**
   @name MendeleyOAuthProvider
   A protocol defining methods handling OAuth2 authentication processes.
   Any custom provider must implement ALL methods defined in this protocol to
   ensure correct execution.

   set up the SDK with necessary OAuth configurations.
   Required parameters are
 ** kMendeleyOAuth2ClientIDKey - the client ID as per app registration
 ** kMendeleyOAuth2ClientSecretKey - the client secret as per app registration
 ** kMendeleyOAuth2RedirectURLKey - the redirect URI as per app registration
 */
- (void)configureOAuthWithParameters:(NSDictionary *)parameters;

/**
   Some registered clients may be able to authenticate directly using username/password - instead of
   going through the login web-site.
   @param username
   @param password
   @param completionBlock
 */
- (void)authenticateWithUserName:(NSString *)username
                        password:(NSString *)password
                 completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   used when logging into Mendeley. The completion block returns the OAuth credentials - or nil
   if unsuccessful. When nil, an error object will be provided.
   Threading note: authentication methods are used at login time, typically, from a view controller. It is assumed
   the method is being called on the main thread.
   @param authenticationCode
   @param completionBlock
 */
- (void)authenticateWithAuthenticationCode:(NSString *)authenticationCode
                           completionBlock:(MendeleyOAuthCompletionBlock)completionBlock;

/**
   used when refreshing the access token. The completion block returns the OAuth credentials - or nil
   if unsuccessful. When nil, an error object will be provided.
   Threading note: refresh maybe handled on main as well as background thread.
   @param credentials the current credentials (to be updated with the refresh)
   @param completionBlock
 */
- (void)refreshTokenWithOAuthCredentials:(MendeleyOAuthCredentials *)credentials
                         completionBlock:(MendeleyOAuthCompletionBlock)completionBlock;

/**
 used when refreshing the access token. The completion block returns the OAuth credentials - or nil
 if unsuccessful. When nil, an error object will be provided.
 Threading note: refresh maybe handled on main as well as background thread.
 @param credentials the current credentials (to be updated with the refresh)
 @param task the task corresponding to the current operation
 @param completionBlock
 */
- (void)refreshTokenWithOAuthCredentials:(MendeleyOAuthCredentials *)credentials
                                    task:(MendeleyTask *)task
                         completionBlock:(MendeleyOAuthCompletionBlock)completionBlock;



/**
   checks if the url string given is the Redirect URL
   @param urlString
   @return YES if it is URL string
 */
- (BOOL)urlStringIsRedirectURI:(NSString *)urlString;

/**
   This general authentication method authorises approved/registered MendeleyClients to make
   API calls e.g. to create a new user profile
   @param completionBlock - returns a MemdeleyOAuthCredentials object. This will be transitory only with no ability to refresh.
 */
- (void)authenticateClientWithCompletionBlock:(MendeleyOAuthCompletionBlock)completionBlock;
@end
