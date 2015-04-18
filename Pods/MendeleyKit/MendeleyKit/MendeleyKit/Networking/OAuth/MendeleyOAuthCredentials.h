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

@interface MendeleyOAuthCredentials : NSObject <NSSecureCoding>
@property (nonatomic, strong) NSString *access_token;
@property (nonatomic, strong) NSString *refresh_token;
@property (nonatomic, strong) NSString *token_type;
@property (nonatomic, strong) NSNumber *expires_in;
/**
   @name MendeleyAPIOAuthCredentials the OAuth credentials as returned from the server
 */

/**
   @return the authentication header as dictionary
 */
- (NSDictionary *)authenticationHeader;

/**
   @return YES if access token is expired, NO otherwise
 */
- (BOOL)oauthCredentialIsExpired;
@end
