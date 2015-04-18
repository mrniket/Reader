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


@interface MendeleyConnectionReachability : NSObject
/**
   @name MendeleyConnectionReachability checks the availability of the Mendeley server.
   The class also provides helper methods to check the availability of individual API calls
   e.g. /documents
 */

/**
   returns a singleton
 */
+ (MendeleyConnectionReachability *)sharedInstance;

/**
   @return YES if an Internet connection is available, NO otherwise.
 */
- (BOOL)isNetworkReachable;

/**
   @return YES if the Internet connection is over WiFi, NO otherwise (2G,3G,4G, etc.).
 */
- (BOOL)isWifiConnection;

/**
   this method check the availability of the Mendeley Server
   @param completionBlock
 */
- (void)mendeleyServerIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   this method check the availability of the Mendeley Documents Endpoint
   @param completionBlock
 */
- (void)mendeleyDocumentServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   this method check the availability of the Mendeley Folders Endpoint
   @param completionBlock
 */
- (void)mendeleyFolderServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   this method check the availability of the Mendeley Annotations Endpoint
   @param completionBlock
 */
- (void)mendeleyAnnotationServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   this method check the availability of the Mendeley Groups Endpoint
   @param completionBlock
 */
- (void)mendeleyGroupServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   this method check the availability of the Mendeley Files Endpoint
   @param completionBlock
 */
- (void)mendeleyFileServiceIsReachableWithCompletionBlock:(MendeleyCompletionBlock)completionBlock;

@end
