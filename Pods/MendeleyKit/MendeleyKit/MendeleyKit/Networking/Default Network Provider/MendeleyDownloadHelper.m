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

#import "MendeleyDownloadHelper.h"
#import "MendeleyResponse.h"
#import "MendeleyNetworkTask.h"

@implementation MendeleyDownloadHelper

- (void)           URLSession:(NSURLSession *)session
                 downloadTask:(MendeleyNetworkDownloadTask *)downloadTask
                 didWriteData:(int64_t)bytesWritten
            totalBytesWritten:(int64_t)totalBytesWritten
    totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    if ([downloadTask respondsToSelector:@selector(progressBlock)] && downloadTask.progressBlock)
    {
        dispatch_queue_t queue = dispatch_get_main_queue();

        dispatch_async(queue, ^{
                           double progressValue = -1.0;
                           if (totalBytesExpectedToWrite != -1)
                           {
                               progressValue = (double) totalBytesWritten / (double) totalBytesExpectedToWrite;
                           }
                           downloadTask.progressBlock(([NSNumber numberWithDouble:progressValue]));
                       });
    }
}

- (void)           URLSession:(NSURLSession *)session
                 downloadTask:(MendeleyNetworkDownloadTask *)downloadTask
    didFinishDownloadingToURL:(NSURL *)location
{
    NSError *errorWhileMovingFile = nil;

    [[NSFileManager defaultManager] moveItemAtURL:location
                                            toURL:downloadTask.fileURL
                                            error:&errorWhileMovingFile];

}

@end
