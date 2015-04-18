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

@class MendeleyOAuthCredentials;

@interface MendeleyRequest : NSObject
@property (nonatomic, strong, readonly) NSData *mendeleyRequestBody;
@property (nonatomic, strong, readonly) NSData *mendeleyRequestHeader;
@property (nonatomic, strong) NSMutableURLRequest *mutableURLRequest;
@property (nonatomic, strong, readonly) MendeleyOAuthCredentials *validCredentials;

/**
   requestWithBaseURL
   Generates a basic container for MendeleyRequest
   @param baseURL
   @param api - if nil, then it is assumed that the baseURL gives the full path
   @param requestType
   @return a MendeleyRequest with a basic NSURLRequest property
 */
+ (MendeleyRequest *)requestWithBaseURL:(NSURL *)baseURL
                                    api:(NSString *)api
                            requestType:(MendeleyHTTPRequestType)requestType;

/**
   requestWithBaseURL
   Generates a basic authenticated container for MendeleyRequest
   @param baseURL
   @param api - if nil, then it is assumed that the baseURL gives the full path
   @param requestType
   @return a MendeleyRequest with a basic authenticated NSURLRequest property
 */
+ (MendeleyRequest *)authenticatedRequestWithBaseURL:(NSURL *)baseURL
                                                 api:(NSString *)api
                                         requestType:(MendeleyHTTPRequestType)requestType;

/**
   add parameters to the URL
   @param parameters a dictionary of parameters to be added to the URL Request
   @param isQuery if true the URL will take the form <HTTP>://baseURL/api?parameter list
 */
- (void)addParametersToURL:(NSDictionary *)parameters isQuery:(BOOL)isQuery;

/**
   adds a header to the request
   @param headerParameters
 */
- (void)addHeaderWithParameters:(NSDictionary *)headerParameters;

/**
   adds a list of parameters to the request body.
   Note: this method should only be used when adding JSON (or similar) request parameters to the body instead of
   header. It must NOT be used for uploading data
   @param bodyParameters
   @param isJSON
 */
- (void)addBodyWithParameters:(NSDictionary *)bodyParameters isJSON:(BOOL)isJSON;

/**
   adds body data to the request
 */
- (void)addBodyData:(NSData *)data;

@end
