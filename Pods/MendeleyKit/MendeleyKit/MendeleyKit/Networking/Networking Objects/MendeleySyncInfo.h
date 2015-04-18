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

@interface MendeleySyncInfo : NSObject <NSCoding>
/**
   @name MendeleySyncInfo
   This class is a wrapper for HTTP response headers to REST API request calls.
   It encapsulates
   - Date the sync time stamp from the server. This time stamp should be used when making queries with modified_since
   - Link paging information (see below)
   - totalCount the total number of items in the library/group
   - modelVersion the version number of the JSON response returned by the server

   If present, the Link header parameter will be parsed into an NSDictionary object, where the key value pairs
   are of type:
   Key (NSString *) : Value (NSURL *)
   Valid keys are:
   - first
   - next
   - previous
   - last
 */

@property (nonatomic, strong, readonly) NSDate *syncDate;
@property (nonatomic, strong, readonly) NSDictionary *linkDictionary;
@property (nonatomic, strong, readonly) NSNumber *totalCount;
@property (nonatomic, strong, readonly) NSString *modelVersion;

/**
   creates a sync header out of an HTTP header
   @param allHeaderFields
 */
- (id)initWithAllHeaderFields:(NSDictionary *)allHeaderFields;
@end
