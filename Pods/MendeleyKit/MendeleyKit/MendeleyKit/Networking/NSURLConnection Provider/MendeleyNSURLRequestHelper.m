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

#import "MendeleyNSURLRequestHelper.h"
#import "MendeleyErrorManager.h"

@implementation MendeleyNSURLRequestHelper

- (id)initWithMendeleyRequest:(MendeleyRequest *)mendeleyRequest
              completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    self = [super init];
    if (nil != self)
    {
        _mendeleyRequest = mendeleyRequest;
        _completionBlock = completionBlock;
        _thisConnection = nil;
        _response = nil;
        _mendeleyResponse = nil;
    }
    return self;
}

- (BOOL)startRequest
{
    if (nil == self.mendeleyRequest || nil == self.mendeleyRequest.mutableURLRequest)
    {
        if (nil != self.completionBlock)
        {
            NSError *error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:kMendeleyConnectionCannotBeStarted];
            self.completionBlock(nil, error);
        }
        self.completionBlock = nil;
        return NO;
    }
    NSMutableURLRequest *urlRequest = self.mendeleyRequest.mutableURLRequest;
    self.thisConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    if (nil == self.thisConnection)
    {
        if (nil != self.completionBlock)
        {
            NSError *error = nil;
            error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:kMendeleyConnectionCannotBeStarted];
            self.completionBlock(nil, error);
        }
        return NO;
    }

    return YES;
}

#pragma mark --
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response];
    self.responseBody = [[NSMutableData alloc] init];
    if ([response isKindOfClass:NSHTTPURLResponse.class])
    {
        self.response = (NSHTTPURLResponse *) response;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.responseBody appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (self.completionBlock)
    {
        NSError *mendeleyError = nil;
        mendeleyError = [[MendeleyErrorManager sharedInstance] errorFromOriginalError:error error:mendeleyError];
        self.completionBlock(nil, mendeleyError);
    }

    self.completionBlock = nil;

    self.thisConnection = nil;

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.completionBlock)
    {
        NSError *mendeleyError = nil;
        if (nil != self.mendeleyResponse && nil != self.responseBody && 0 < self.responseBody.length)
        {
            [self.mendeleyResponse deserialiseRawResponseData:self.responseBody error:&mendeleyError];
        }
        self.completionBlock(self.mendeleyResponse, mendeleyError);
    }

    self.completionBlock = nil;

    self.thisConnection = nil;

}

#pragma mark --
#pragma mark MendeleyCancellableRequest method(s)

- (void)cancelConnection
{
    if (nil != self.thisConnection)
    {
        MendeleyResponseCompletionBlock completionBlock = self.completionBlock;

        self.completionBlock = nil; // prevent potential NSURLConnection delegate callbacks to invoke the completion block redundantly

        [self.thisConnection cancel];

        self.thisConnection = nil;

        NSError *cancelError = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:kMendeleyCancelledRequestErrorCode];
        if (nil != completionBlock)
        {
            completionBlock(nil, cancelError);
        }
    }
}
@end
