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

#import "MendeleyNSURLRequestUploadHelper.h"

@interface MendeleyNSURLRequestUploadHelper ()
@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, copy) MendeleyResponseProgressBlock progressBlock;
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, assign) unsigned long long bytesExpected;
@property (nonatomic, assign) unsigned long long bytesUploaded;
@end

/**
 This class is the some kind of mirror to the MendeleyNSURLRequestDownloadHelper
 However, there is one important difference.
 If we set the HTTPBodyStream property to the request, the NSURLConnection will close the stream
 for us. Therefore, we do not include an [self.inputStream close] message in this code
 */

@implementation MendeleyNSURLRequestUploadHelper
- (id)initWithMendeleyRequest:(MendeleyRequest *)mendeleyRequest
                  fromFileURL:(NSURL *)fromFileURL
                progressBlock:(MendeleyResponseProgressBlock)progressBlock
              completionBlock:(MendeleyResponseCompletionBlock)completionBlock
{
    self = [super initWithMendeleyRequest:mendeleyRequest completionBlock:completionBlock];
    if (nil != self)
    {
        _progressBlock = progressBlock;
        _fileURL = fromFileURL;
        _bytesUploaded = 0;
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
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:filePath])
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
    NSError *error = nil;
    NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filePath error:&error];
    self.bytesExpected = -1;
    if (nil != fileAttributes)
    {
        NSNumber *fileSize = [fileAttributes valueForKey:@"NSFileSize"];
        if (nil != fileSize)
        {
            self.bytesExpected = [fileSize unsignedLongLongValue];
        }
    }
    
    self.inputStream = [NSInputStream inputStreamWithFileAtPath:filePath];
    if (nil != self.mendeleyRequest && nil != self.mendeleyRequest.mutableURLRequest)
    {
        self.mendeleyRequest.mutableURLRequest.HTTPBodyStream = self.inputStream;
        return [super startRequest];
    }

    if (nil != self.completionBlock)
    {
        NSError *error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:kMendeleyConnectionCannotBeStarted];
        self.completionBlock(nil, error);
    }
    self.progressBlock = nil;
    self.completionBlock = nil;
    
    return NO;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [super connection:connection didReceiveResponse:response];
    
    self.bytesUploaded = 0;
}

- (void)connection:(NSURLConnection *)connection
   didSendBodyData:(NSInteger)bytesWritten
 totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if (nil != self.progressBlock)
    {
        if (0 < self.bytesExpected)
        {
            double progressValue = (double) self.bytesUploaded / (double) self.bytesExpected;
            NSNumber *progressNumber = [NSNumber numberWithDouble:progressValue];
            self.progressBlock(progressNumber);
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [super connection:connection didFailWithError:error];
    
    self.progressBlock = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];
    self.progressBlock = nil;
}

@end
