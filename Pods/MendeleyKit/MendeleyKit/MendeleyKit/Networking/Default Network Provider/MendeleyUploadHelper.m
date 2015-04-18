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

#import "MendeleyUploadHelper.h"
#import "MendeleyNetworkTask.h"

@implementation MendeleyUploadHelper

- (void)          URLSession:(NSURLSession *)session
                        task:(MendeleyNetworkUploadTask *)uploadTask
             didSendBodyData:(int64_t)bytesSent
              totalBytesSent:(int64_t)totalBytesSent
    totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    if ([uploadTask respondsToSelector:@selector(progressBlock)] && uploadTask.progressBlock)
    {
        dispatch_queue_t queue = dispatch_get_main_queue();

        dispatch_async(queue, ^{
                           uploadTask.progressBlock(([NSNumber numberWithDouble:(double) totalBytesSent / (double) totalBytesExpectedToSend]));
                       });
    }

}

@end
