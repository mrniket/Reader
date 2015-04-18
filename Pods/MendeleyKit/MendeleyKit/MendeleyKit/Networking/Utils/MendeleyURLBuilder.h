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

@interface MendeleyURLBuilder : NSObject
/**
   @param baseURL to be appended
   @param parameters list of parameters to append to URL
   @param query if YES the list of parameters starts with ?
 */
+ (NSURL *)urlWithBaseURL:(NSURL *)baseURL
               parameters:(NSDictionary *)parameters
                    query:(BOOL)query;


/**
   returns a list of key=value pairs separated by &
   @param parameters both key and value must be NSString objects
   @return the NSData using UTF8String encoding
 */
+ (NSData *)httpBodyFromParameters:(NSDictionary *)parameters;

/**
   returns a list of key=value pairs separated by &
   @param parameters both key and value must be NSString objects
   @return the NSString using UTF8String encoding
 */
+ (NSString *)httpBodyStringFromParameters:(NSDictionary *)parameters;

/**
   @return a default header to be used in HTTP requests
 */
+ (NSDictionary *)defaultHeader;
@end
