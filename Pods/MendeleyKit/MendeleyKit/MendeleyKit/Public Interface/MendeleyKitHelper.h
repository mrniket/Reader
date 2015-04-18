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

@protocol MendeleyKitHelperDelegate <NSObject>

@required
/**
   returns a valid network provider
 */
- (id <MendeleyNetworkProvider> )networkProvider;

/**
   returns the base API URL.
   By default the following API address will be assumed
   https://api.mendeley.com
   It is highly recommended NOT to change this
 */
- (NSURL *)baseAPIURL;

@end

@class MendeleyQueryRequestParameters;
@class MendeleyKitHelperDelegate;

@interface MendeleyKitHelper : NSObject
/**
   @name MendeleyKitHelper
   This class provides generic helper methods used in various API calls/callbacks
 */
/**
   @param delegate
   @return an instance of the helper
 */
- (instancetype)initWithDelegate:(id <MendeleyKitHelperDelegate> )delegate;

/**
   checks whether a MendeleyResponse can be marked as successful or whether an error has occurred
   @param response
   @param error
 */
- (BOOL)isSuccessForResponse:(MendeleyResponse *)response
                       error:(NSError **)error;

/**
   Used in GET REST API calls: this gets a list of Mendeley Objects from the server
   @param objectTypeString e.g. MendeleyDocument
   @param apiString e.g. documents
   @param queryParameters
   @param additionalHeaders - this usually includes the Accept:"****+1.json" type header to accept API specific JSON responses
   @param completionBlock
 */
- (void)mendeleyObjectListOfType:(NSString *)objectTypeString
                             api:(NSString *)apiString
                      parameters:(NSDictionary *)queryParameters
               additionalHeaders:(NSDictionary *)additionalHeaders
                            task:(MendeleyTask *)task
                 completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   Used in GET REST API calls. A specific call to get a list of ID strings from the server
   (e.g. /folders/{folderID}/documents)
   @param apiString e.g. documents
   @param queryParameters
   @param additionalHeaders - this usually includes the Accept:"****+1.json" type header to accept API specific JSON responses
   @param completionBlock
 */
- (void)mendeleyIDStringListForAPI:(NSString *)apiString
                        parameters:(NSDictionary *)queryParameters
                 additionalHeaders:(NSDictionary *)additionalHeaders
                              task:(MendeleyTask *)task
                   completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   Used in GET REST API calls: obtains a single Mendeley Object
   @param objectTypeString e.g. MendeleyDocument
   @param queryParameters
   @param apiString e.g. documents
   @param additionalHeaders - this usually includes the Accept:"****+1.json" type header to accept API specific JSON responses
   @param completionBlock
 */
- (void)mendeleyObjectOfType:(NSString *)objectTypeString
                  parameters:(NSDictionary *)queryParameters
                         api:(NSString *)apiString
           additionalHeaders:(NSDictionary *)additionalHeaders
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   This creates a new MendeleyObject on the server
   @param mendeleyObject
   @param apiString e.g. documents
   @param completionBlock
 */
- (void)createMendeleyObject:(MendeleyObject *)mendeleyObject
                         api:(NSString *)apiString
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   Used in POST REST API calls
   @param mendeleyObject
   @param apiString e.g. documents
   @param additionalHeaders - this usually includes the Accept:"****+1.json" type header to accept API specific JSON responses
   @param objectTypeString e.g. MendeleyDocument
   @param completionBlock
 */
- (void)createMendeleyObject:(MendeleyObject *)mendeleyObject
                         api:(NSString *)apiString
           additionalHeaders:(NSDictionary *)additionalHeaders
                expectedType:(NSString *)objectTypeString
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   Used in PATCH REST API calls
   This updates an existing Mendeley Object on the server
   @param updatedMendeleyObject
   @param apiString e.g. documents
   @param completionBlock
 */
- (void)updateMendeleyObject:(MendeleyObject *)updatedMendeleyObject
                         api:(NSString *)apiString
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   Used in PATCH REST API calls
   This updates an existing Mendeley Object on the server
   @param mendeleyObject
   @param apiString e.g. documents
   @param additionalHeaders - this usually includes the Accept:"****+1.json" type header to accept API specific JSON responses
   @param completionBlock
 */
- (void)updateMendeleyObject:(MendeleyObject *)updatedMendeleyObject
                         api:(NSString *)apiString
           additionalHeaders:(NSDictionary *)additionalHeaders
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyCompletionBlock)completionBlock;


/**
   Used in PATCH REST API calls
   This updates an existing Mendeley Object on the server, returning the updated object in the completionBlock
   @param mendeleyObject
   @param apiString e.g. documents
   @param additionalHeaders - this usually includes the Accept:"****+1.json" type header to accept API specific JSON responses
   @param objectTypeString e.g. MendeleyDocument
   @param completionBlock
 */
- (void)updateMendeleyObject:(MendeleyObject *)updatedMendeleyObject
                         api:(NSString *)apiString
           additionalHeaders:(NSDictionary *)additionalHeaders
                expectedType:(NSString *)objectTypeString
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   Used in DELETE REST API calls. This deletes an object on the server
   @param apiString e.g. documents
   @param completionBlock
 */
- (void)deleteMendeleyObjectWithAPI:(NSString *)apiString
                               task:(MendeleyTask *)task
                    completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   This is a specific GET request to download a file (typically a PDF file) to a specified location
   @param apiString e.g. documents
   @param fileURL the location to save the downloaded file in
   @param progressBlock
   @param completionBlock
 */
- (void)downloadFileWithAPI:(NSString *)apiString
                  saveToURL:(NSURL *)fileURL
                       task:(MendeleyTask *)task
              progressBlock:(MendeleyResponseProgressBlock)progressBlock
            completionBlock:(MendeleyCompletionBlock)completionBlock;

@end
