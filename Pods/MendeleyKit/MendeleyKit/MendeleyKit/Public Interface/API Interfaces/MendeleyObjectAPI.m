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

#import "MendeleyObjectAPI.h"

@implementation MendeleyObjectAPI

- (instancetype)initWithNetworkProvider:(id <MendeleyNetworkProvider> )provider
                                baseURL:(NSURL *)baseURL
{
    self = [super init];
    if (nil != self)
    {
        _provider = provider;
        _baseURL = baseURL;
        _helper = [[MendeleyKitHelper alloc] initWithDelegate:self];
    }
    return self;
}

- (id <MendeleyNetworkProvider> )networkProvider
{
    return self.provider;
}

- (NSURL *)baseAPIURL
{
    return self.baseURL;
}

- (NSString *)linkFromPhoto:(MendeleyPhoto *)photo
                   iconType:(MendeleyIconType)iconType
                       task:(MendeleyTask *)task
                      error:(NSError **)error
{
    if (nil == photo)
    {
        if (NULL != *error)
        {
            *error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain
                                                                       code:kMendeleyMissingDataProvidedErrorCode];
        }
        return nil;
    }
    
    NSString *link = nil;
    switch (iconType)
    {
        case OriginalIcon:
            link = photo.original;
            break;
        case SquareIcon:
            link = photo.square;
            break;
        case StandardIcon:
            link = photo.standard;
            break;
    }
    if (nil == link)
    {
        if (NULL != *error)
        {
            *error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain
                                                                       code:kMendeleyMissingDataProvidedErrorCode];
            return nil;
        }
    }
    return link;
}

- (NSDictionary *)requestHeaderForImageLink:(NSString *)link
{
    if ([link hasSuffix:@".jpg"])
    {
        return @{ kMendeleyRESTRequestAccept : kMendeleyRESTRequestJPEGType };
    }
    else if ([link hasSuffix:@".png"])
    {
        return @{ kMendeleyRESTRequestAccept : kMendeleyRESTRequestPNGType };
    }
    return @{ kMendeleyRESTRequestAccept : kMendeleyRESTRequestBinaryType };
}


@end
