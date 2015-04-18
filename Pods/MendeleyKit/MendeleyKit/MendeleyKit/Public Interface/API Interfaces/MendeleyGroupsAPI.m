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

#import "MendeleyGroupsAPI.h"

@implementation MendeleyGroupsAPI

- (NSDictionary *)defaultServiceRequestHeaders
{
    return @{ kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONGroupType };
}

- (NSDictionary *)membersRequestHeaders
{
    return @{ kMendeleyRESTRequestAccept: kMendeleyRESTRequestJSONUserRoleType };
}

- (NSDictionary *)defaultQueryParameters
{
    return [[MendeleyGroupParameters new] valueStringDictionary];
}

- (void)groupListWithQueryParameters:(MendeleyGroupParameters *)queryParameters
                            iconType:(MendeleyIconType)iconType
                                task:(MendeleyTask *)task
                     completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    NSDictionary *query = [queryParameters valueStringDictionary];
    NSDictionary *mergedQuery = [NSDictionary dictionaryByMerging:query with:[self defaultQueryParameters]];

    [self.provider invokeGET:self.baseURL
                         api:kMendeleyRESTAPIGroups
           additionalHeaders:[self defaultServiceRequestHeaders]
             queryParameters:mergedQuery
      authenticationRequired:YES
                        task:task
             completionBlock:^(MendeleyResponse *response, NSError *error) {
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
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelGroup completionBlock: ^(NSArray *groups, NSError *parseError) {
                  MendeleySyncInfo *syncInfo = (nil != parseError) ? nil : response.syncHeader;
                  if (nil != groups)
                  {
                      NSUInteger firstIndex = 0;
                      [self groupIconsForGroupArray:groups
                                         groupIndex:firstIndex
                                           iconType:iconType
                                      previousError:nil
                                               task:task
                                    completionBlock:^(BOOL success, NSError *error) {
                           [blockExec executeWithArray:groups
                                              syncInfo:syncInfo
                                                 error:parseError];
                       }];
                  }
                  else
                  {
                      [blockExec executeWithArray:nil
                                         syncInfo:syncInfo
                                            error:parseError];
                  }
              }];
         }
     }];
}




- (void)groupListWithLinkedURL:(NSURL *)linkURL
                      iconType:(MendeleyIconType)iconType
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
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelGroup completionBlock: ^(NSArray *groups, NSError *parseError) {
                  MendeleySyncInfo *syncInfo = (nil != parseError) ? nil : response.syncHeader;
                  if (nil != groups)
                  {
                      NSUInteger firstIndex = 0;
                      [self groupIconsForGroupArray:groups
                                         groupIndex:firstIndex
                                           iconType:iconType
                                      previousError:nil
                                               task:task
                                    completionBlock:^(BOOL success, NSError *error) {
                           [blockExec executeWithArray:groups
                                              syncInfo:syncInfo
                                                 error:parseError];
                       }];
                  }
                  else
                  {
                      [blockExec executeWithArray:nil
                                         syncInfo:syncInfo
                                            error:parseError];
                  }
              }];
         }
     }];
}

- (void)groupWithGroupID:(NSString *)groupID
                iconType:(MendeleyIconType)iconType
                    task:(MendeleyTask *)task
         completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertStringArgumentNotNilOrEmpty:groupID argumentName:@"groupID "];
    NSString *apiEndPoint = [NSString stringWithFormat:kMendeleyRESTAPIGroupWithID, groupID];

    [self.provider invokeGET:self.baseURL
                         api:apiEndPoint
           additionalHeaders:[self defaultServiceRequestHeaders]
             queryParameters:nil
      authenticationRequired:YES
                        task:task
             completionBlock:^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithObjectCompletionBlock:completionBlock];
         MendeleyModeller *jsonModeller = [MendeleyModeller sharedInstance];
         [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelGroup completionBlock: ^(id mendeleyObject, NSError *parseError) {
              MendeleySyncInfo *syncInfo = (nil != parseError) ? nil : response.syncHeader;

              if (nil != mendeleyObject)
              {
                  __block MendeleyGroup *group = (MendeleyGroup *) mendeleyObject;
                  [self groupIconForGroup:group
                                 iconType:iconType
                                     task:task
                          completionBlock:^(NSData *binaryData, NSError *dataError) {
                       if (nil != binaryData)
                       {
                           switch (iconType)
                           {
                               case StandardIcon:
                                   group.photo.standardImageData = binaryData;
                                   break;
                               case SquareIcon:
                                   group.photo.squareImageData = binaryData;
                                   break;
                               case OriginalIcon:
                                   group.photo.originalImageData = binaryData;
                                   break;
                           }
                       }
                       [blockExec executeWithMendeleyObject:group
                                                   syncInfo:syncInfo
                                                      error:nil];
                   }];
              }
              else
              {
                  [blockExec executeWithMendeleyObject:nil
                                              syncInfo:syncInfo
                                                 error:parseError];
              }
          }];

     }];
}

- (void)groupMemberListWithGroupID:(NSString *)groupID
                        parameters:(MendeleyGroupParameters *)queryParameters
                              task:(MendeleyTask *)task
                   completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    NSDictionary *query = [queryParameters valueStringDictionary];

    [NSError assertStringArgumentNotNilOrEmpty:groupID argumentName:@"groupID"];
    NSString *apiEndPoint = [NSString stringWithFormat:kMendeleyRESTAPIMembersInGroupWithID, groupID];
    [self.helper mendeleyObjectListOfType:kMendeleyModelUserRole
                                      api:apiEndPoint
                               parameters:[NSDictionary dictionaryByMerging:query with:[self defaultQueryParameters]]
                        additionalHeaders:[self membersRequestHeaders]
                                     task:task
                          completionBlock:completionBlock];
}


- (void)groupListWithQueryParameters:(MendeleyGroupParameters *)queryParameters
                                task:(MendeleyTask *)task
                     completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    NSDictionary *query = [queryParameters valueStringDictionary];
    NSDictionary *mergedQuery = [NSDictionary dictionaryByMerging:query with:[self defaultQueryParameters]];

    [self.provider invokeGET:self.baseURL
                         api:kMendeleyRESTAPIGroups
           additionalHeaders:[self defaultServiceRequestHeaders]
             queryParameters:mergedQuery
      authenticationRequired:YES
                        task:task
             completionBlock:^(MendeleyResponse *response, NSError *error) {
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
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelGroup completionBlock: ^(NSArray *groups, NSError *parseError) {
                  MendeleySyncInfo *syncInfo = (nil != parseError) ? nil : response.syncHeader;
                  [blockExec executeWithArray:groups syncInfo:syncInfo
                                        error:parseError];
              }];
         }
     }];

}

- (void)groupListWithLinkedURL:(NSURL *)linkURL
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
             [jsonModeller parseJSONData:response.responseBody expectedType:kMendeleyModelGroup completionBlock: ^(NSArray *groups, NSError *parseError) {
                  MendeleySyncInfo *syncInfo = (nil != parseError) ? nil : response.syncHeader;
                  [blockExec executeWithArray:groups
                                     syncInfo:syncInfo
                                        error:parseError];
              }];
         }
     }];
}

- (void)groupWithGroupID:(NSString *)groupID
                    task:(MendeleyTask *)task
         completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    [NSError assertStringArgumentNotNilOrEmpty:groupID argumentName:@"groupID "];
    NSString *apiEndPoint = [NSString stringWithFormat:kMendeleyRESTAPIGroupWithID, groupID];
    [self.helper mendeleyObjectOfType:kMendeleyModelGroup
                           parameters:nil
                                  api:apiEndPoint
                    additionalHeaders:[self defaultServiceRequestHeaders]
                                 task:task
                      completionBlock:completionBlock];

}


- (void)groupIconsForGroupArray:(NSArray *)groups
                     groupIndex:(NSUInteger)groupIndex
                       iconType:(MendeleyIconType)iconType
                  previousError:(NSError *)previousError
                           task:(MendeleyTask *)task
                completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:groups argumentName:@"groups"];
    if (groups.count <= groupIndex)
    {
        if (completionBlock)
        {
            completionBlock(nil == previousError, previousError);
        }
        return;
    }
    __block MendeleyGroup *group = [groups objectAtIndex:groupIndex];
    [self groupIconForGroup:group
                   iconType:iconType
                       task:task
            completionBlock:^(NSData *imageData, NSError *error) {
         NSError *nextError = nil;
         NSUInteger nextIndex = groupIndex + 1;
         if (nil == previousError)
         {
             nextError = error;
         }
         else
         {
             nextError = previousError;
         }
         if (nil != imageData)
         {
             switch (iconType)
             {
                 case OriginalIcon:
                     group.photo.originalImageData = imageData;
                     break;
                 case SquareIcon:
                     group.photo.squareImageData = imageData;
                     break;
                 case StandardIcon:
                     group.photo.standardImageData = imageData;
                     break;
             }
         }

         [self groupIconsForGroupArray:groups
                            groupIndex:nextIndex
                              iconType:iconType
                         previousError:nextError
                                  task:task
                       completionBlock:completionBlock];
     }];

}


- (void)groupIconForGroup:(MendeleyGroup *)group
                 iconType:(MendeleyIconType)iconType
                     task:(MendeleyTask *)task
          completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:group argumentName:@"group"];
    NSError *error = nil;
    NSString *linkURLString = [self linkFromPhoto:group.photo
                                         iconType:iconType
                                             task:task
                                            error:&error];
    if (nil == linkURLString)
    {
        error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain
                                                                  code:kMendeleyDataNotAvailableErrorCode];
        completionBlock(nil, error);
    }
    else
    {
        [self groupIconForIconURLString:linkURLString task:task completionBlock:completionBlock];
    }
}


- (void)groupIconForIconURLString:(NSString *)iconURLString
                             task:(MendeleyTask *)task
                  completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock
{
    [NSError assertArgumentNotNil:iconURLString argumentName:@"iconURLString"];
    NSURL *url = [NSURL URLWithString:iconURLString];
    NSDictionary *requestHeader = [self requestHeaderForImageLink:iconURLString];
    [self.provider invokeGET:url
                         api:nil
           additionalHeaders:requestHeader
             queryParameters:nil
      authenticationRequired:NO
                        task:task
             completionBlock:^(MendeleyResponse *response, NSError *error) {
         MendeleyBlockExecutor *blockExec = [[MendeleyBlockExecutor alloc] initWithBinaryDataCompletionBlock:completionBlock];
         if (![self.helper isSuccessForResponse:response error:&error])
         {
             [blockExec executeWithBinaryData:nil
                                        error:error];
         }
         else
         {
             id bodyData = response.responseBody;
             if ([bodyData isKindOfClass:[NSData class]])
             {
                 [blockExec executeWithBinaryData:bodyData
                                            error:nil];
             }
             else
             {
                 [blockExec executeWithBinaryData:nil
                                            error:error];
             }
         }
     }];
}

@end
