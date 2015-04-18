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

#import "MendeleyNSURLRequestDownloadHelper.h"

#define NSURLResponseUnknownLength ((long long) -1)


@interface MendeleyNSURLRequestDownloadHelper ()
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, copy) MendeleyResponseProgressBlock progressBlock;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) unsigned long long bytesExpected;
@property (nonatomic, assign) unsigned long long bytesDownloaded;
@end


@implementation MendeleyNSURLRequestDownloadHelper
- (id)initWithMendeleyRequest:(MendeleyRequest *)mendeleyRequest
                    toFileURL:(NSURL *)toFileURL
                progressBlock:(MendeleyResponseProgressBlock)progressBlock
              completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    self = [super initWithMendeleyRequest:mendeleyRequest completionBlock:completionBlock];
    if (nil != self)
    {
        _progressBlock = progressBlock;
        _fileURL = toFileURL;
        _bytesDownloaded = 0;
        _bytesExpected = 0;
    }
    return self;
}

- (BOOL)startRequest
{
    if (nil == self.fileURL)
    {
        if (nil != self.completionBlock)
        {
            NSError *error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:kMendeleyFileNotAvailableForTransfer];
            self.completionBlock(nil, error);
        }
        self.progressBlock = nil;
        self.completionBlock = nil;
        return NO;
    }
    NSString *filePath = [self.fileURL path];
    self.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
    return [super startRequest];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection
             willSendRequest:(NSURLRequest *)request
            redirectResponse:(NSURLResponse *)response
{
    NSInteger statusCode = 0;

    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        statusCode = httpResponse.statusCode;
    }

    NSURLRequest *updatedRequest = [request copy];

    if (303 == statusCode)
    {
        updatedRequest = [NSURLRequest requestWithURL:request.URL];
    }

    return updatedRequest;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [super connection:connection didReceiveResponse:response];
    if (self.bytesExpected == 0 && response.expectedContentLength != NSURLResponseUnknownLength)
    {
        self.bytesExpected = response.expectedContentLength;
    }
    self.bytesDownloaded = 0;
    self.mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:response fileURL:self.fileURL];
    if (nil != self.outputStream)
    {
        BOOL isStreamReady = self.outputStream.streamStatus == NSStreamStatusOpen;
        if (!isStreamReady)
        {
            [self.outputStream open];
            isStreamReady = self.outputStream.streamStatus == NSStreamStatusOpen;
        }

        if (!isStreamReady)
        {
            [connection cancel];

            if (self.completionBlock)
            {
                NSError *error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:kMendeleyJSONTypeObjectNilErrorCode];
                self.completionBlock(nil, error);
            }
            self.completionBlock = nil;
            self.thisConnection = nil;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (self.outputStream == nil)
    { // if there is no outputStream then store data in memory in self.data
        [super connection:connection didReceiveData:data];
    }
    else
    {
        const uint8_t *bytes = data.bytes;
        NSUInteger length = data.length;
        NSUInteger offset = 0;
        do
        {
            NSUInteger written = [self.outputStream write:&bytes[offset] maxLength:length - offset];
            if (written <= 0)
            {
                [connection cancel];
                return;
            }
            else
            {
                offset += written;
            }
        }
        while (offset < length);
    }

    self.bytesDownloaded += data.length;
    if (self.progressBlock)
    {
        double progressValue = -1.0;
        if (-1 != self.bytesExpected)
        {
            progressValue = (double) self.bytesDownloaded / (double) self.bytesExpected;
            NSNumber *progressNumber = [NSNumber numberWithDouble:progressValue];
            self.progressBlock(progressNumber);
        }
    }

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self.outputStream close];

    self.progressBlock = nil;

    [super connection:connection didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.outputStream close];

    self.progressBlock = nil;

    if (nil != self.completionBlock)
    {
        NSError *error = nil;
        if (nil == self.mendeleyResponse)
        {
            error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:kMendeleyNetworkGenericError];
        }
        self.completionBlock(self.mendeleyResponse, error);
    }

    self.completionBlock = nil;

    self.thisConnection = nil;


}

- (void)cancelConnection
{
    [self.outputStream close];

    self.progressBlock = nil;
    [super cancelConnection];
}
@end
