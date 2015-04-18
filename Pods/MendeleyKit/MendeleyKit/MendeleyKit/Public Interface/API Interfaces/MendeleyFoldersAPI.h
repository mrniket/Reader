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

@class MendeleyDocumentId;
@class MendeleyFolderParameters;
@class MendeleyFolder;

@interface MendeleyFoldersAPI : MendeleyObjectAPI
/**
   @name MendeleyFoldersAPI
   This class provides access methods to the REST folders API
   All of the methods are accessed via MendeleyKit.
   Developers should use the methods provided in MendeleyKit rather
   than the methods listed here.
 */


/**
   Obtain a list of documents belonging to a specific folder.
   @param folderID
   @param parameters
   @param task
   @param completionBlock - the array contained in the completionBlock will be an array of strings
 */
- (void)documentListFromFolderWithID:(NSString *)folderID
                          parameters:(MendeleyFolderParameters *)parameters
                                task:(MendeleyTask *)task
                     completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   this is getting the list of document IDs in a paged form
   @param linkURL
   @param task
   @param completionBlock - the array contained in the completionBlock will be an array of strings
 */
- (void)documentListInFolderWithLinkedURL:(NSURL *)linkURL
                                     task:(MendeleyTask *)task
                          completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   Add a previously created document in a specific folder
   @param mendeleyDocumentId
   @param folderID
   @param task
   @param completionBlock
 */
- (void)addDocument:(NSString *)mendeleyDocumentId
           folderID:(NSString *)folderID
               task:(MendeleyTask *)task
    completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   Create a folder
   @param mendeleyFolder
   @param task
   @param completionBlock
 */
- (void)createFolder:(MendeleyFolder *)mendeleyFolder
                task:(MendeleyTask *)task
     completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   This method is only used when paging through a list of folders on the server.
   All required parameters are provided in the linkURL, which should not be modified

   @param linkURL the full HTTP link to the document listings page
   @param task
   @param completionBlock
 */
- (void)folderListWithLinkedURL:(NSURL *)linkURL
                           task:(MendeleyTask *)task
                completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   Obtain a list of folders for the logged-in user
   @param queryParameters
   @param task
   @param completionBlock
 */
- (void)folderListWithQueryParameters:(MendeleyFolderParameters *)queryParameters
                                 task:(MendeleyTask *)task
                      completionBlock:(MendeleyArrayCompletionBlock)completionBlock;

/**
   Obtain a folder identified by the given folderID
   @param folderID
   @param task
   @param completionBlock
 */
- (void)folderWithFolderID:(NSString *)folderID
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyObjectCompletionBlock)completionBlock;

/**
   Delete a folder identified by the given folderID
   @param folderID
   @param task
   @param completionBlock
 */
- (void)deleteFolderWithID:(NSString *)folderID
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   Update a folder's name, or move it to a new parent
   @param updatedFolder
   @param task
   @param completionBlock
 */
- (void)updateFolder:(MendeleyFolder *)updatedFolder
                task:(MendeleyTask *)task
     completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   Delete a document identified by the given documentID and belonging to a folder identified by the given folderID
   @param documentID
   @param folderID
   @param task
   @param completionBlock
 */
- (void)deleteDocumentWithID:(NSString *)documentID
            fromFolderWithID:(NSString *)folderID
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyCompletionBlock)completionBlock;

@end
