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

#import "MendeleyConnectionReachability.h"
#import "NSError+MendeleyError.h"
#import "MendeleyRequest.h"
#import "MendeleyKitConfiguration.h"
#import "MendeleyReachability.h"

@interface MendeleyConnectionReachability ()

@property (nonatomic, strong) MendeleyKitConfiguration *sdkConfiguration;

@end

@implementation MendeleyConnectionReachability

+ (MendeleyConnectionReachability *)sharedInstance
{
    static MendeleyConnectionReachability *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
                      sharedInstance = [[[self class] alloc] init];
                  });

    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _sdkConfiguration = [MendeleyKitConfiguration sharedInstance];
    }
    return self;
}

- (BOOL)isWifiConnection
{
    MendeleyReachability *r = [MendeleyReachability reachabilityForLocalWiFi];
    NetworkStatus status = [r currentReachabilityStatus];
    return status == ReachableViaWiFi;
}

- (BOOL)isNetworkReachable
{
    MendeleyReachability *r = [MendeleyReachability reachabilityForInternetConnection];
    NetworkStatus status = [r currentReachabilityStatus];
    return status;
}

- (void)mendeleyServerIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self mendeleyService:@"" isReachableWithCompletionBlock:completionBlock];
}

- (void)mendeleyDocumentServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self mendeleyService:kMendeleyRESTAPIDocuments isReachableWithCompletionBlock:completionBlock];
}

- (void)mendeleyFolderServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self mendeleyService:kMendeleyRESTAPIFolders isReachableWithCompletionBlock:completionBlock];
}

- (void)mendeleyAnnotationServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self mendeleyService:kMendeleyRESTAPIAnnotations isReachableWithCompletionBlock:completionBlock];
}

- (void)mendeleyGroupServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self mendeleyService:kMendeleyRESTAPIGroups isReachableWithCompletionBlock:completionBlock];
}

- (void)mendeleyFileServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self mendeleyService:kMendeleyRESTAPIFiles isReachableWithCompletionBlock:completionBlock];
}

#pragma mark -
#pragma mark Private methods

- (void)mendeleyService:(NSString *)apiString isReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    NSString *remoteHostName = [NSString stringWithFormat:@"%@/%@", self.sdkConfiguration.baseAPIURL, apiString];

    if ([self isNetworkReachable])
    {
        BOOL serviceReachable = ([MendeleyReachability reachabilityWithHostName:remoteHostName] != nil);
        completionBlock(serviceReachable, nil);
    }
    else
    {
        completionBlock(NO, nil);
    }
}

@end
