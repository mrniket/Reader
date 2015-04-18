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

#import "MendeleyFoldersAPI.h"
#import "MendeleyModels.h"
#import "MendeleyDocument.h"

@implementation MendeleyFoldersAPI

- (NSDictionary *)defaultServiceRequestHeaders
{
    return @{ kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONFolderType };
}

- (NSDictionary *)defaultUploadRequestHeaders
{
    return @{ kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONFolderType,
              kMendeleyRESTRequestContentType : kMendeleyRESTRequestJSONFolderType };
}

- (NSDictionary *)defaultFolderDocumentIDsRequestHeaders
{
    return @{ kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONDocumentType };
}


- (NSDictionary *)defaultAddDocumentToFolderRequestHeaders
{
    return @{ kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONDocumentType,
              kMendeleyRESTRequestContentType : kMendeleyRESTRequestJSONDocumentType };
}

- (NSDictionary *)defaultQueryParameters
{
    return [[MendeleyFolderParameters new] valueStringDictionary];
}

- (void)documentListFromFolderWithID:(NSString *)folderID
                          parameters:(MendeleyFolderParameters *)parameters
                                task:(MendeleyTask *)task
                     completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    NSDictionary *query = [parameters valueStringDictionary];

    [NSError assertStringArgumentNotNilOrEmpty:folderID argumentName:@"folderID"];
    NSString *apiEndpoint = [NSString stringWithFormat:kMendeleyRESTAPIDocumentsInFolderWithID, folderID];
    [self.helper mendeleyIDStringListForAPI:apiEndpoint
                                 parameters:[NSDictionary dictionaryByMerging:query with:[self defaultQueryParameters]]
                          additionalHeaders:[self defaultFolderDocumentIDsRequestHeaders]
                                       task:task
                            completionBlock:completionBlock];
}

- (void)addDocument:(NSString *)mendeleyDocumentId
           folderID:(NSString *)folderID
               task:(MendeleyTask *)task
    completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertStringArgumentNotNilOrEmpty:mendeleyDocumentId argumentName:@"mendeleyDocumentId"];
    [NSError assertStringArgumentNotNilOrEmpty:folderID argumentName:@"folderID"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *apiEndPoint = [NSString stringWithFormat:kMendeleyRESTAPIDocumentsInFolderWithID, folderID];

    MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithCompletionBlock:completionBlock];
    MendeleyModeller *modeller = [MendeleyModeller sharedInstance];

    NSError *serialiseError = nil;
    NSData *jsonData = [modeller jsonObjectForID:mendeleyDocumentId error:&serialiseError];
    if (nil == jsonData)
    {
        [blockExec executeWithBool:NO
                             error:serialiseError];
        return;
    }
    NSURL *baseAPIURL = self.baseURL;
    [self.provider invokePOST:baseAPIURL
                          api:apiEndPoint
            additionalHeaders:[self defaultAddDocumentToFolderRequestHeaders]
                     jsonData:jsonData
       authenticationRequired:YES
                         task:task
              completionBlock: ^(MendeleyResponse *response, NSError *error) {
         if (![self.helper isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithBool:NO
                                  error:error];
         }
         else
         {
             [blockExec executeWithBool:YES
                                  error:nil];
         }
     }];
}

- (void)createFolder:(MendeleyFolder *)mendeleyFolder
                task:(MendeleyTask *)task
     completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [self.helper createMendeleyObject:mendeleyFolder
                                  api:kMendeleyRESTAPIFolders
                    additionalHeaders:[self defaultUploadRequestHeaders]
                         expectedType:kMendeleyModelFolder
                                 task:task
                      completionBlock:completionBlock];
}

- (void)folderListWithLinkedURL:(NSURL *)linkURL
                           task:(MendeleyTask *)task
                completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:linkURL argumentName:@"linkURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    [self.provider invokeGET:linkURL
                         api:nil
           additionalHeaders:[self defaultServiceRequestHeaders]
             queryParameters:nil
      authenticationRequired:YES
                        task:task
             completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithArrayCompletionBlock:completionBlock];
         if (![self.helper isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithArray:nil
                                syncInfo:nil
                                   error:error];
         }
         else
         {
             MendeleyModeller *jsonModeller = [MendeleyModeller sharedInstance];
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelFolder completionBlock: ^(NSArray *documents, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithArray:nil
                                         syncInfo:nil
                                            error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithArray:documents
                                         syncInfo:response.syncHeader
                                            error:nil];
                  }
              }];
         }
     }];

}

- (void)documentListInFolderWithLinkedURL:(NSURL *)linkURL
                                     task:(MendeleyTask *)task
                          completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:linkURL argumentName:@"linkURL"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    [self.provider invokeGET:linkURL
                         api:nil
           additionalHeaders:[self defaultFolderDocumentIDsRequestHeaders]
             queryParameters:nil
      authenticationRequired:YES
                        task:task
             completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithArrayCompletionBlock:completionBlock];
         if (![self.helper isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithArray:nil
                                syncInfo:nil
                                   error:error];
         }
         else
         {
             MendeleyModeller *jsonModeller = [MendeleyModeller sharedInstance];
             id jsonData = response.responseBody;
             if ([jsonData isKindOfClass:[NSArray class]])
             {
                 NSArray *jsonArray = (NSArray *) jsonData;
                 [jsonModeller parseJSONArrayOfIDDictionaries:jsonArray completionBlock:^(NSArray *arrayOfStrings, NSError *parseError) {
                      if (nil != parseError)
                      {
                          [blockExec executeWithArray:nil
                                             syncInfo:nil
                                                error:parseError];
                      }
                      else
                      {
                          [blockExec executeWithArray:arrayOfStrings
                                             syncInfo:response.syncHeader
                                                error:nil];
                      }
                  }];
             }
         }
     }];

}


- (void)folderListWithQueryParameters:(MendeleyFolderParameters *)queryParameters
                                 task:(MendeleyTask *)task
                      completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    NSDictionary *query = [queryParameters valueStringDictionary];

    [self.helper mendeleyObjectListOfType:kMendeleyModelFolder
                                      api:kMendeleyRESTAPIFolders
                               parameters:[NSDictionary dictionaryByMerging:query with:[self defaultQueryParameters]]
                        additionalHeaders:[self defaultServiceRequestHeaders]
                                     task:task
                          completionBlock:completionBlock];
}

- (void)folderWithFolderID:(NSString *)folderID
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:folderID argumentName:@"folderID"];
    NSString *apiEndpoint = [NSString stringWithFormat:kMendeleyRESTAPIFolderWithID, folderID];
    [self.helper mendeleyObjectOfType:kMendeleyModelFolder
                           parameters:nil
                                  api:apiEndpoint
                    additionalHeaders:[self defaultServiceRequestHeaders]
                                 task:task
                      completionBlock:completionBlock];
}

- (void)deleteFolderWithID:(NSString *)folderID
                      task:(MendeleyTask *)task
           completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:folderID argumentName:@"folderID"];
    NSString *apiEndpoint = [NSString stringWithFormat:kMendeleyRESTAPIFolderWithID, folderID];
    [self.helper deleteMendeleyObjectWithAPI:apiEndpoint
                                        task:task
                             completionBlock:completionBlock];
}

- (void)updateFolder:(MendeleyFolder *)updatedFolder
                task:(MendeleyTask *)task
     completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:updatedFolder argumentName:@"updatedFolder"];
    NSString *apiEndpoint = [NSString stringWithFormat:kMendeleyRESTAPIFolderWithID, updatedFolder.object_ID];
    [self.helper updateMendeleyObject:updatedFolder
                                  api:apiEndpoint
                    additionalHeaders:[self defaultUploadRequestHeaders]
                                 task:task
                      completionBlock:completionBlock];
}

- (void)deleteDocumentWithID:(NSString *)documentID
            fromFolderWithID:(NSString *)folderID
                        task:(MendeleyTask *)task
             completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:documentID argumentName:@"documentID"];
    [NSError assertArgumentNotNil:folderID argumentName:@"folderID"];
    NSString *apiEndpoint = [NSString stringWithFormat:kMendeleyRESTAPIDocumentWithIDInFolderWithID, folderID, documentID];
    [self.helper deleteMendeleyObjectWithAPI:apiEndpoint
                                        task:task
                             completionBlock:completionBlock];
}

@end
