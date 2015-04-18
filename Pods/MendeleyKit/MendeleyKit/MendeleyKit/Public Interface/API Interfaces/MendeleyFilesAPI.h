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

@class MendeleyFileParameters;

@interface MendeleyFilesAPI : MendeleyObjectAPI
/**
   @name MendeleyFilesAPI
   This class provides access methods to the REST file API
   All of the methods are accessed via MendeleyKit.
   Developers should use the methods provided in MendeleyKit rather
   than the methods listed here.
 */

/**
   obtains a list of files for the first page.
   @param parameters the parameter set to be used in the request
   @param task
   @param completionBlock
 */
- (void)fileListWithQueryParameters:(MendeleyFileParameters *)queryParameters
                               task:(MendeleyTask *)task
                    completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   obtains a file for given ID from the library
   @param fileID
   @param fileURL
   @param task
   @param progressBlock
   @param completionBlock
 */
- (void)fileWithFileID:(NSString *)fileID
             saveToURL:(NSURL *)fileURL
                  task:(MendeleyTask *)task
         progressBlock:(MendeleyResponseProgressBlock)progressBlock
       completionBlock:(MendeleyCompletionBlock)completionBlock;


/**
   this creates a file based on the mendeley object model provided in the argument.
   The server will respond with the JSON data structure for the new object
   @param fileURL
   @param filename the name of the file to be given when uploading. maybe different from fileURL
   @param contentType the contentType to be used. If none is provided, PDF will be taken
   @param documentURLPath
   @param task
   @param progressBlock
   @param completionBlock
 */
- (void)           createFile:(NSURL *)fileURL
                     filename:(NSString *)filename
                  contentType:(NSString *)contentType
    relativeToDocumentURLPath:(NSString *)documentURLPath
                         task:(MendeleyTask *)task
                progressBlock:(MendeleyResponseProgressBlock)progressBlock
              completionBlock:(MendeleyObjectCompletionBlock)completionBlock;


/**
   this method will remove a file with given ID permanently. The file data cannot be retrieved.
   However, the user will be able to get a list of permanently removed IDs
   @param documentID
   @param task
   @param completionBlock
 */
- (void)deleteFileWithID:(NSString *)fileID
                    task:(MendeleyTask *)task
         completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   @param linkURL
   @param task
   @param completionBlock
 */
- (void)fileListWithLinkedURL:(NSURL *)linkURL
                         task:(MendeleyTask *)task
              completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   This method returns a list of files IDs that were permanently deleted. The list of deleted IDs will be kept on
   the server for a limited period of time.
   @param deletedSince the parameter set to be used in the request
   @param task
   @param completionBlock
 */
- (void)deletedFilesSince:(NSDate *)deletedSince
                  groupID:(NSString *)groupID
                     task:(MendeleyTask *)task
          completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   This method returns a list of recently showed files on any device running a version
   of Mendeley (or a third part app) that support this feature.
   The objects are sorted by date with the most recent first.
   By default 20 items are returned.
   The number of records saved on the server is limited.
   @param queryParameters the parameter set to be used in the request
   @param task
   @param completionBlock
 */
- (void)recentlyReadWithParameters:(MendeleyRecentlyReadParameters *)queryParameters
                              task:(MendeleyTask *)task
                   completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   This method create/replace an entry of recently read for a file.
   Any existing entry with a matching id if present is removed, and a new one is created.
   The new one is inserted into the list at a position determined by the
   current server time or at the time provided by the client if specified.
   @param recentlyRead the recently read object to create
   @param task
   @param completionBlock
 */
- (void)addRecentlyRead:(MendeleyRecentlyRead *)recentlyRead
                   task:(MendeleyTask *)task
        completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   NOTE: this service is not yet available!
   This method update the entry of recently read for a file.
   If an entry with the given id exists in the history for this user,
   its position (page and vertical_position values) are updated.
   It is not brought to the top of the history.
   If there is no entry with matching id in the recent history, it returns an error.
   @param recentlyRead the recently read object to update
   @param task
   @param completionBlock
   - (void)updateRecentlyRead:(MendeleyRecentlyRead *)recentlyRead
                      task:(MendeleyTask *)task
           completionBlock:(MendeleySecureObjectCompletionBlock)completionBlock;
 */
@end
