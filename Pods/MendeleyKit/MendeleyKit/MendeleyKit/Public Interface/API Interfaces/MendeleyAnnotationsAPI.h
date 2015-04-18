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

@class MendeleyAnnotation;
@class MendeleyAnnotationParameters;

@interface MendeleyAnnotationsAPI : MendeleyObjectAPI
/**
   @name MendeleyAnnotationsAPI
   This class provides access methods to the REST annotations API
   All of the methods are accessed via MendeleyKit.
   Developers should use the methods provided in MendeleyKit rather
   than the methods listed here.
 */
/**
   @param annotationID
   @param task
   @param completionBlock
 */
- (void)annotationWithAnnotationID:(NSString *)annotationID
                              task:(MendeleyTask *)task
                   completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   @param annotationID
   @param task
   @param completionBlock
 */
- (void)deleteAnnotationWithID:(NSString *)annotationID
                          task:(MendeleyTask *)task
               completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   @param updatedMendeleyAnnotation
   @param task
   @param completionBlock
 */
- (void)updateAnnotation:(MendeleyAnnotation *)updatedMendeleyAnnotation
                    task:(MendeleyTask *)task
         completionBlock:(MendeleyObjectCompletionBlock)completionBlock;
/**
   @param mendeleyAnnotation
   @param task
   @param completionBlock
 */
- (void)createAnnotation:(MendeleyAnnotation *)mendeleyAnnotation
                    task:(MendeleyTask *)task
         completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   @param linkURL
   @param task
   @param completionBlock
 */
- (void)annotationListWithLinkedURL:(NSURL *)linkURL
                               task:(MendeleyTask *)task
                    completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   @param queryParameters
   @param task
   @param completionBlock
 */
- (void)annotationListWithQueryParameters:(MendeleyAnnotationParameters *)queryParameters
                                     task:(MendeleyTask *)task
                          completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   This method returns a list of annotations IDs that were permanently deleted. The list of deleted IDs will be kept on
   the server for a limited period of time.
   @param deletedSince the parameter set to be used in the request
   @param task
   @param completionBlock
 */
- (void)deletedAnnotationsSince:(NSDate *)deletedSince
                        groupID:(NSString *)groupID
                           task:(MendeleyTask *)task
                completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

@end
