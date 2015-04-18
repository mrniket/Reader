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

@interface NSError (Exceptions)

/**
   asserts that an argument is not nil. If a required argument is nil, this is considered a fatal error, and the SDK will throw an exception.
   This will most likely cause the app to exit/crash.
   @param argument
   @param argumentName
 */
+ (void)assertArgumentNotNil:(id)argument argumentName:(NSString *)argumentName;

/**
   asserts that an argument is not nil. If a required argument is nil, this is considered a fatal error, and the SDK will throw an exception.
   This will most likely cause the app to exit/crash.
   @param argument
   @param argumentName
 */
+ (void)assertStringArgumentNotNilOrEmpty:(NSString *)argument argumentName:(NSString *)argumentName;

/**
   asserts that an argument is not nil. If a required argument is nil, this is considered a fatal error, and the SDK will throw an exception.
   This will most likely cause the app to exit/crash.
   @param argument
   @param argumentName
 */
+ (void)assertURLArgumentNotNilOrMissing:(NSURL *)argument argumentName:(NSString *)argumentName;

@end
