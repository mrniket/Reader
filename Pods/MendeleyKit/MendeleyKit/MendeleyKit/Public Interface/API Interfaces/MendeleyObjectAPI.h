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
#import "MendeleyNetworkProvider.h"
#import "NSError+MendeleyError.h"
#import "MendeleyBlockExecutor.h"
#import "MendeleyKitHelper.h"
#import "MendeleyModeller.h"
#import "MendeleyObjectHelper.h"
#import "MendeleyQueryRequestParameters.h"
#import "NSDictionary+Merge.h"

@interface MendeleyObjectAPI : NSObject <MendeleyKitHelperDelegate>
@property (nonatomic, strong) id <MendeleyNetworkProvider> provider;
@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, strong) MendeleyKitHelper *helper;

/**
   A general creator of MendeleyObjectAPI
   @param provider the network provider. By default the MendeleyDefaultNetworkProvider is taken. This is based on NSURLSession
   @param baseURL
 */
- (instancetype)initWithNetworkProvider:(id <MendeleyNetworkProvider> )provider
                                baseURL:(NSURL *)baseURL;

/**
   A convenience method that returns the link for the image of the choosen type passing a MendeleyPhoto Object
   @param the photo object
   @param iconType
   @param task
   @param error
 */

- (NSString *)linkFromPhoto:(MendeleyPhoto *)photo
                   iconType:(MendeleyIconType)iconType
                       task:(MendeleyTask *)task
                      error:(NSError **)error;

/**
   A convenience method that returns the request header for a image download link
 */
- (NSDictionary *)requestHeaderForImageLink:(NSString *)link;


@end
