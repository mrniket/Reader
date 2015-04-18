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

#import "MendeleyDataHelper.h"
#import "MendeleyNetworkTask.h"
#import "MendeleyResponse.h"

@implementation MendeleyDataHelper

- (void)    URLSession:(NSURLSession *)session
              dataTask:(MendeleyNetworkTask *)dataTask
    didReceiveResponse:(NSURLResponse *)response
     completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [dataTask setResponse:response];
    if ([dataTask isKindOfClass:[MendeleyNetworkDownloadTask class]])
    {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;

        if (httpResponse.statusCode == 404)
        {
            completionHandler(NSURLSessionResponseCancel);
        }
        else
        {
            completionHandler(NSURLSessionResponseBecomeDownload);
        }
    }
}

- (void)      URLSession:(NSURLSession *)session
                    task:(MendeleyNetworkTask *)task
    didCompleteWithError:(NSError *)error
{
    if ([task respondsToSelector:@selector(completionBlock)] && task.completionBlock)
    {
        MendeleyResponse *mendeleyResponse;
        if ([task isKindOfClass:[MendeleyNetworkDownloadTask class]])
        {
            mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:task.response fileURL:((MendeleyNetworkDownloadTask *) task).fileURL];
        }
        else
        {
            mendeleyResponse = [MendeleyResponse mendeleyReponseForURLResponse:task.response];
        }
        task.completionBlock(mendeleyResponse, error);
    }
}

@end
