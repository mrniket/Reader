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
#import "MendeleyError.h"

@interface NSError (MendeleyKit)
/**
   @name NSError (MendeleyKit)
   provides convenience methods to create Mendeley specific errors
 */
/**
   @param code
   @param localizedDescription
   @return an error with default Mendeley SDK domain
 */
+ (id)errorWithCode:(MendeleyErrorCode)code localizedDescription:(NSString *)localizedDescription;

/**
   @param code
   @return an error object with default Mendeley Error domain
 */
+ (id)errorWithCode:(MendeleyErrorCode)code;

/**
   @param response
   @param url
   @return an error with default Mendeley Error domain
 */
+ (id)errorWithMendeleyResponse:(MendeleyResponse *)response requestURL:(NSURL *)url;

/**
   @param response
   @param url
   @param body
   @return an error with default Mendeley Error domain
 */
+ (id)errorWithMendeleyResponse:(MendeleyResponse *)response requestURL:(NSURL *)url failureBody:(NSData *)body;

@end
