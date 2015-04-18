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

#import "MendeleyRequest.h"
#import "MendeleyURLBuilder.h"
#import "NSError+MendeleyError.h"
#import "MendeleyOAuthStore.h"
#import "MendeleyOAuthCredentials.h"

@interface MendeleyRequest ()

@property (nonatomic, strong, readwrite) NSData *mendeleyRequestBody;
@property (nonatomic, strong, readwrite) NSData *mendeleyRequestHeader;
@property (nonatomic, strong, readwrite) MendeleyOAuthCredentials *validCredentials;
@property (nonatomic, strong) NSURL *apiURL;

@end

@implementation MendeleyRequest

+ (MendeleyRequest *)requestWithBaseURL:(NSURL *)baseURL api:(NSString *)api requestType:(MendeleyHTTPRequestType)requestType authenticationRequired:(BOOL)authenticationRequired
{
    [NSError assertArgumentNotNil:baseURL argumentName:@"baseURL"];
    MendeleyRequest *request = [[MendeleyRequest alloc] init];
    NSURL *url = (nil != api) ? [NSURL URLWithString:api relativeToURL:baseURL] : baseURL;
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
                                                              cachePolicy:kMendeleyDefaultCachePolicy
                                                          timeoutInterval:kMendeleyDefaultTimeOut];

    request.mutableURLRequest = urlRequest;
    request.mutableURLRequest.HTTPMethod = [[self class]requestMethodForType:requestType];
    request.apiURL = url;
    request.mutableURLRequest.allHTTPHeaderFields = [[MendeleyURLBuilder defaultHeader] copy];
    if (requestType == HTTP_PUT || requestType == HTTP_PATCH)
    {
        if (nil == [request.mutableURLRequest.allHTTPHeaderFields objectForKey:kMendeleyRESTRequestContentType])
        {
            [request.mutableURLRequest setValue:kMendeleyRESTRequestURLType forHTTPHeaderField:kMendeleyRESTRequestContentType];
        }
        if (nil == [request.mutableURLRequest.allHTTPHeaderFields objectForKey:kMendeleyRESTRequestAccept])
        {
            [request.mutableURLRequest setValue:kMendeleyRESTRequestJSONType forHTTPHeaderField:kMendeleyRESTRequestAccept];
        }
    }
    if (authenticationRequired)
    {
        MendeleyOAuthStore *store = [[MendeleyOAuthStore alloc] init];
        MendeleyOAuthCredentials *credentials = [store retrieveOAuthCredentials];
        if (nil != credentials && ![credentials oauthCredentialIsExpired])
        {
            request.validCredentials = credentials;
            [request addHeaderWithParameters:[credentials authenticationHeader]];
        }
    }
    return request;
}

+ (MendeleyRequest *)requestWithBaseURL:(NSURL *)baseURL api:(NSString *)api requestType:(MendeleyHTTPRequestType)requestType
{
    return [[self class] requestWithBaseURL:baseURL api:api requestType:requestType authenticationRequired:NO];
}


+ (MendeleyRequest *)authenticatedRequestWithBaseURL:(NSURL *)baseURL api:(NSString *)api requestType:(MendeleyHTTPRequestType)requestType
{
    return [[self class] requestWithBaseURL:baseURL api:api requestType:requestType authenticationRequired:YES];
}

- (void)addParametersToURL:(NSDictionary *)parameters isQuery:(BOOL)isQuery
{
    self.mutableURLRequest.URL = [MendeleyURLBuilder urlWithBaseURL:self.apiURL
                                                         parameters:parameters
                                                              query:isQuery];
}
- (void)addHeaderWithParameters:(NSDictionary *)headerParameters
{
    if (nil == headerParameters)
    {
        return;
    }
    [headerParameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
         [self.mutableURLRequest setValue:value forHTTPHeaderField:key];
     }];

}
- (void)addBodyWithParameters:(NSDictionary *)bodyParameters isJSON:(BOOL)isJSON
{
    if (nil == bodyParameters)
    {
        return;
    }
    NSData *bodyData = nil;
    if (isJSON)
    {
        NSError *error = nil;
        bodyData = [NSJSONSerialization dataWithJSONObject:bodyParameters
                                                   options:kNilOptions
                                                     error:&error];
    }
    else
    {
        bodyData = [MendeleyURLBuilder httpBodyFromParameters:bodyParameters];
    }
    if (nil != bodyData)
    {
        [self.mutableURLRequest setHTTPBody:bodyData];
        NSString *length = [NSString stringWithFormat:@"%lu", (unsigned long) [bodyData length]];
        [self.mutableURLRequest addValue:length forHTTPHeaderField:kMendeleyRESTRequestContentLength];
    }
    if ([self.mutableURLRequest.HTTPMethod isEqualToString:@"PUT"] || [self.mutableURLRequest.HTTPMethod isEqualToString:@"PATCH"])
    {
        if (nil == [self.mutableURLRequest.allHTTPHeaderFields objectForKey:kMendeleyRESTRequestContentType])
        {
            [self.mutableURLRequest setValue:kMendeleyRESTRequestURLType forHTTPHeaderField:kMendeleyRESTRequestContentType];
        }
    }
}

- (void)addBodyData:(NSData *)data
{
    [self.mutableURLRequest setHTTPBody:data];
    if ([self.mutableURLRequest.HTTPMethod isEqualToString:@"PUT"] || [self.mutableURLRequest.HTTPMethod isEqualToString:@"PATCH"])
    {
        if (nil == [self.mutableURLRequest.allHTTPHeaderFields objectForKey:kMendeleyRESTRequestContentType])
        {
            [self.mutableURLRequest setValue:kMendeleyRESTRequestURLType forHTTPHeaderField:kMendeleyRESTRequestContentType];
        }
    }
}


#pragma mark private methods
+ (NSString *)requestMethodForType:(MendeleyHTTPRequestType)requestType
{
    NSString *method = nil;

    switch (requestType)
    {
        case HTTP_DELETE:
            method = @"DELETE";
            break;
        case HTTP_GET:
            method = @"GET";
            break;
        case HTTP_POST:
            method = @"POST";
            break;
        case HTTP_PUT:
            method = @"PUT";
            break;
        case HTTP_PATCH:
            method = @"PATCH";
            break;
        case HTTP_HEAD:
            method = @"HEAD";
            break;
    }
    return method;
}
@end
