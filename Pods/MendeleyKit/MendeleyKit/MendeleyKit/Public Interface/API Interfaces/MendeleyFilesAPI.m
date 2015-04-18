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

#import "MendeleyFilesAPI.h"
#import "MendeleyModels.h"

@implementation MendeleyFilesAPI

#pragma mark Private methods

- (NSDictionary *)defaultServiceRequestHeaders
{
    return @{ kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONFileType };
}

- (NSDictionary *)recentlyReadServiceHeaders
{
    return @{ kMendeleyRESTRequestContentType: kMendeleyRESTRequestJSONRecentlyRead,
              kMendeleyRESTRequestAccept : kMendeleyRESTRequestJSONRecentlyRead };
}

- (NSDictionary *)uploadFileHeadersWithLinkRel:(NSString *)linkRel
                                      filename:(NSString *)filename
                                   contentType:(NSString *)contentType
{
    NSString *fileAttachment = nil;

    if (nil == filename)
    {
        fileAttachment = [NSString stringWithFormat:@"; filename=\"example.pdf\""];
    }
    else
    {
        fileAttachment = [NSString stringWithFormat:@"; filename=\"%@\"", filename];
    }

    if (nil == contentType)
    {
        contentType = kMendeleyRESTRequestValuePDF;
    }
    NSString *contentDisposition = [kMendeleyRESTRequestValueAttachment stringByAppendingString:fileAttachment];

    return @{ kMendeleyRESTRequestContentDisposition: contentDisposition,
              kMendeleyRESTRequestContentType: contentType,
              kMendeleyRESTRequestLink: linkRel,
              kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONFileType };
}

- (NSDictionary *)defaultQueryParameters
{
    return [[MendeleyFileParameters new] valueStringDictionary];
}

#pragma mark -

- (void)fileListWithQueryParameters:(MendeleyFileParameters *)queryParameters
                               task:(MendeleyTask *)task
                    completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    NSDictionary *query = [queryParameters valueStringDictionary];

    [self.helper mendeleyObjectListOfType:kMendeleyModelFile
                                      api:kMendeleyRESTAPIFiles
                               parameters:[NSDictionary dictionaryByMerging:query with:[self defaultQueryParameters]]
                        additionalHeaders:[self defaultServiceRequestHeaders]
                                     task:task
                          completionBlock:completionBlock];
}

- (void)fileWithFileID:(NSString *)fileID
             saveToURL:(NSURL *)fileURL
                  task:(MendeleyTask *)task
         progressBlock:(MendeleyResponseProgressBlock)progressBlock
       completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:fileID argumentName:@"fileID"];
    NSString *apiEndpoint = [NSString stringWithFormat:kMendeleyRESTAPIFileWithID, fileID];
    [self.helper downloadFileWithAPI:apiEndpoint
                           saveToURL:fileURL
                                task:task
                       progressBlock:progressBlock
                     completionBlock:completionBlock];
}

- (void)           createFile:(NSURL *)fileURL
                     filename:(NSString *)filename
                  contentType:(NSString *)contentType
    relativeToDocumentURLPath:(NSString *)documentURLPath
                         task:(MendeleyTask *)task
                progressBlock:(MendeleyResponseProgressBlock)progressBlock
              completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertURLArgumentNotNilOrMissing:fileURL argumentName:@"fileURL"];
    [NSError assertStringArgumentNotNilOrEmpty:documentURLPath argumentName:@"documentURLPath"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    MendeleyModeller *modeller = [MendeleyModeller sharedInstance];
    NSString *linkRel = [NSString stringWithFormat:@"<%@>; rel=\"document\"", documentURLPath];
    NSDictionary *uploadHeader = [self uploadFileHeadersWithLinkRel:linkRel
                                                           filename:filename
                                                        contentType:contentType];

    [self.provider invokeUploadForFileURL:fileURL
                                  baseURL:self.baseURL
                                      api:kMendeleyRESTAPIFiles
                        additionalHeaders:uploadHeader
                   authenticationRequired:YES
                                     task:task
                            progressBlock:progressBlock
                          completionBlock: ^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithObjectCompletionBlock:completionBlock];
         if (![self.helper isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithMendeleyObject:nil
                                         syncInfo:nil
                                            error:error];
         }
         else
         {
             [modeller parseJSONData:response.responseBody expectedType:kMendeleyModelFile completionBlock: ^(MendeleyFile *file, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithMendeleyObject:nil
                                                  syncInfo:nil
                                                     error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithMendeleyObject:file
                                                  syncInfo:response.syncHeader
                                                     error:nil];
                  }
              }];
         }
     }];

}


- (void)deleteFileWithID:(NSString *)fileID
                    task:(MendeleyTask *)task
         completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:fileID argumentName:@"fileID"];
    NSString *apiEndpoint = [NSString stringWithFormat:kMendeleyRESTAPIFileWithID, fileID];
    [self.helper deleteMendeleyObjectWithAPI:apiEndpoint
                                        task:task
                             completionBlock:completionBlock];
}

- (void)fileListWithLinkedURL:(NSURL *)linkURL
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
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelFile completionBlock: ^(NSArray *documents, NSError *parseError) {
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

- (void)deletedFilesSince:(NSDate *)deletedSince
                  groupID:(NSString *)groupID
                     task:(MendeleyTask *)task
          completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:deletedSince argumentName:@"deletedSince"];
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    NSString *deletedSinceString = [[MendeleyObjectHelper jsonDateFormatter] stringFromDate:deletedSince];
    NSMutableDictionary *query = [NSMutableDictionary dictionaryWithDictionary:@{ kMendeleyRESTAPIQueryDeletedSince : deletedSinceString }];
    if (groupID)
    {
        [query addEntriesFromDictionary:@{ kMendeleyRESTAPIQueryGroupID:groupID }];
    }
    [self.provider invokeGET:self.baseURL
                         api:kMendeleyRESTAPIFiles
           additionalHeaders:[self defaultServiceRequestHeaders]
             queryParameters:[NSDictionary dictionaryByMerging:query with:[self defaultQueryParameters]]
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
                 [jsonModeller parseJSONArrayOfIDDictionaries:jsonArray completionBlock: ^(NSArray *arrayOfStrings, NSError *parseError) {
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

- (void)recentlyReadWithParameters:(MendeleyRecentlyReadParameters *)queryParameters
                              task:(MendeleyTask *)task
                   completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];

    [self.provider invokeGET:self.baseURL
                         api:kMendeleyRESTAPIRecentlyRead
           additionalHeaders:[self recentlyReadServiceHeaders]
             queryParameters:[queryParameters valueStringDictionary]
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
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelRecentlyRead completionBlock: ^(NSArray *recentlyReadList, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithArray:nil
                                         syncInfo:nil
                                            error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithArray:recentlyReadList
                                         syncInfo:response.syncHeader
                                            error:nil];
                  }
              }];
         }
     }];
}

- (void)addRecentlyRead:(MendeleyRecentlyRead *)recentlyRead
                   task:(MendeleyTask *)task
        completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [NSError assertArgumentNotNil:recentlyRead argumentName:@"recentlyRead"];

    MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc]
                                        initWithObjectCompletionBlock:completionBlock];
    MendeleyModeller *modeller = [MendeleyModeller sharedInstance];

    NSError *serialiseError = nil;
    NSData *jsonData = [modeller jsonObjectFromModelOrModels:recentlyRead
                                                       error:&serialiseError];
    if (nil == jsonData)
    {
        [blockExec executeWithMendeleyObject:nil
                                    syncInfo:nil
                                       error:serialiseError];
        return;
    }


    [self.provider invokePOST:self.baseURL
                          api:kMendeleyRESTAPIRecentlyRead
            additionalHeaders:[self recentlyReadServiceHeaders]
                     jsonData:jsonData
       authenticationRequired:YES
                         task:task
              completionBlock: ^(MendeleyResponse *response, NSError *error) {
         if (![self.helper isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithMendeleyObject:nil syncInfo:nil error:error];
         }
         else
         {
             MendeleyModeller *jsonModeller = [MendeleyModeller sharedInstance];
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelRecentlyRead completionBlock: ^(MendeleyRecentlyRead *recentlyRead, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithMendeleyObject:nil
                                                  syncInfo:nil
                                                     error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithMendeleyObject:recentlyRead
                                                  syncInfo:response.syncHeader
                                                     error:nil];
                  }
              }];
         }
     }];
}

/**
   This service is not yet available.
   - (void)updateRecentlyRead:(MendeleyRecentlyRead *)recentlyRead
                      task:(MendeleyTask *)task
           completionBlock:(MendeleySecureObjectCompletionBlock)completionBlock
   {
    [NSError assertArgumentNotNil:completionBlock argumentName:@"completionBlock"];
    [NSError assertArgumentNotNil:recentlyRead argumentName:@"recentlyRead"];

    MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithSecureObjectCompletionBlock:completionBlock];

    NSError *serialiseError = nil;
    MendeleyModeller *modeller = [MendeleyModeller sharedInstance];
    NSData *jsonData = [modeller jsonObjectFromModelOrModels:recentlyRead
                                                       error:&serialiseError];

    if (nil == jsonData)
    {
        [blockExec executeWithMendeleySecureObject:nil
                                          syncInfo:nil
                                             error:serialiseError];
        return;
    }

    [self.provider invokePATCH:self.baseURL
                           api:kMendeleyRESTAPIRecentlyRead
             additionalHeaders:[self recentlyReadServiceHeaders]
                      jsonData:jsonData
        authenticationRequired:YES
                          task:task
               completionBlock: ^(MendeleyResponse *response, NSError *error) {
         if (![self.helper isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithMendeleySecureObject:nil
                                               syncInfo:nil
                                                  error:error];
         }
         else
         {
             MendeleyModeller *jsonModeller = [MendeleyModeller sharedInstance];
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelRecentlyRead completionBlock: ^(MendeleyRecentlyRead *recentlyRead, NSError *parseError) {
                  if (nil != parseError)
                  {
                      [blockExec executeWithMendeleySecureObject:nil
                                                        syncInfo:nil
                                                           error:parseError];
                  }
                  else
                  {
                      [blockExec executeWithMendeleySecureObject:recentlyRead
                                                        syncInfo:response.syncHeader
                                                           error:nil];
                  }
              }];
         }
     }];
   }
 */

@end
