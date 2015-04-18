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
#import "MendeleySyncInfo.h"
#import "MendeleyModels.h"

@interface MendeleyBlockExecutor : NSObject

/**
   @name MendeleyBlockExecutor
   There are 3 types of completionBlocks in the SDK. This class is a helper/wrapper
   to ensure that the blocks are executed on the main thread.
   The class must be initialised with one of the 3 init<completionBlockType> methods provided
 */

/**
   @param arrayCompletionBlock
 */
- (instancetype)initWithArrayCompletionBlock:(MendeleyArrayCompletionBlock)arrayCompletionBlock;

/**
   @param stringArrayCompletionBlock
 */
- (instancetype)initWithStringArrayCompletionBlock:(MendeleyStringArrayCompletionBlock)stringArrayCompletionBlock;

/**
   @param completionBlock
 */
- (instancetype)initWithCompletionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   @param objectCompletionBlock
 */
- (instancetype)initWithObjectCompletionBlock:(MendeleyObjectCompletionBlock)objectCompletionBlock;

/**
   @param objectCompletionBlock
 */
- (instancetype)initWithSecureObjectCompletionBlock:(MendeleySecureObjectCompletionBlock)secureObjectCompletionBlock;

/**
   @param dictionaryCompletionBlock
 */
- (instancetype)initWithDictionaryCompletionBlock:(MendeleyDictionaryResponseBlock)dictionaryCompletionBlock;

/**
   @param binaryDataCompletionBlock
 */
- (instancetype)initWithBinaryDataCompletionBlock:(MendeleyBinaryDataCompletionBlock)binaryDataCompletionBlock;

/**
   @param oauthCompletionBlock
 */
- (instancetype)initWithOAuthCompletionBlock:(MendeleyOAuthCompletionBlock)oauthCompletionBlock;

/**
   executes the MendeleyArrayCompletionBlock on the main thread
   @param array
   @param syncInfo
   @param error
 */
- (void)executeWithArray:(NSArray *)array
                syncInfo:(MendeleySyncInfo *)syncInfo
                   error:(NSError *)error;


/**
   executes the MendeleyCompletionBlock on the main thread
   @param success
   @param error
 */
- (void)executeWithBool:(BOOL)success error:(NSError *)error;

/**
   executes the MendeleyObjectCompletionBlock on the main thread
   @param mendeleyObject
   @param syncInfo
   @param error
 */
- (void)executeWithMendeleyObject:(MendeleyObject *)mendeleyObject
                         syncInfo:(MendeleySyncInfo *)syncInfo
                            error:(NSError *)error;

/**
   executes the MendeleySecureObjectCompletionBlock on the main thread
   @param mendeleySecureObject
   @param syncInfo
   @param error
 */
- (void)executeWithMendeleySecureObject:(MendeleySecureObject *)mendeleySecureObject
                               syncInfo:(MendeleySyncInfo *)syncInfo
                                  error:(NSError *)error;

/**
   executes the MendeleyDictionaryCompletionBlock on the main thread
   @param dictionary
   @param error
 */
- (void)executeWithDictionary:(NSDictionary *)dictionary error:(NSError *)error;

/**
   executes the MendeleyDictionaryCompletionBlock on the main thread
   @param binaryData
   @param error
 */
- (void)executeWithBinaryData:(NSData *)binaryData error:(NSError *)error;


/**
   executes the MendeleyOAuthCompletionBlock on the main thread
   @param credentials
   @param error
 */
- (void)executeWithCredentials:(MendeleyOAuthCredentials *)credentials error:(NSError *)error;

@end
