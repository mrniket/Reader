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
#import "MendeleyNetworkProvider.h"
#import "MendeleyOAuthProvider.h"

@interface MendeleyKitConfiguration : NSObject
@property (nonatomic, assign, readonly) BOOL isTrustedSSLServer;
@property (nonatomic, strong, readonly) NSURL *baseAPIURL;
@property (nonatomic, assign, readonly) NSString *documentViewType;
@property (nonatomic, strong, readonly) id<MendeleyNetworkProvider> networkProvider;
@property (nonatomic, strong, readonly) id<MendeleyOAuthProvider> oauthProvider;
/**
   a singleton to obtain access to default SDK configurations
 */
+ (MendeleyKitConfiguration *)sharedInstance;

/**
   set up the SDK with necessary OAuth configurations.
   Required parameters are
 ** kMendeleyOAuth2ClientIDKey - the client ID as per app registration
 ** kMendeleyOAuth2ClientSecretKey - the client secret as per app registration
 ** kMendeleyOAuth2RedirectURLKey - the redirect URI as per app registration
 */
- (void)configureOAuthWithParameters:(NSDictionary *)parameters;

/**
   this changes the configuration of the SDK based on the parameters provided.
   If valid, these settings will override the default values used throughout the SDK
   Supported parameters are:
 ** kMendeleyBaseAPIURLKey - to set a custom base API URL. Value must be of type NSString
 ** kMendeleyBaseOAuth2URLKey - to set a custom OAuth2 authentication server URL. Value must be of type NSString
 ** kMendeleyBasePublicURLKey - to set a custom public URL API. Value must be of type NSString
 ** kMendeleyTrustedSSLServerKey - to indicate whether the SSL server is trusted. Value must be of type NSNumber
 ** kMendeleyOAuthProviderKey    - the name of the class implementing the MendeleyOAuthDefaultProvider protocol
 ** kMendeleyNetworkProviderKey  - the name of the class implementing the MendeleyNetworkProvider protocol
 ** kMendeleyDocumentViewType    - the type of view to use while calling document related services. Value must be a NSString. Possible values are specified in the globals header.
   @param configurationParameters
 */
- (void)changeConfigurationWithParameters:(NSDictionary *)configurationParameters;

/**
   resets all parameters to default
 */
- (void)resetToDefault;
@end
