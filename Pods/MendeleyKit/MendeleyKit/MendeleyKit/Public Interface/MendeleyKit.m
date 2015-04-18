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

#import "MendeleyKit.h"
#import "MendeleyModels.h"
#import "MendeleyOAuthStore.h"
#import "MendeleyOAuthCredentials.h"
#import "MendeleyDefaultNetworkProvider.h"
#import "MendeleyDefaultOAuthProvider.h"
#import "MendeleyOAuthTokenHelper.h"
#import "MendeleyKitConfiguration.h"
#import "MendeleySyncInfo.h"
#import "MendeleyQueryRequestParameters.h"
#import "MendeleyBlockExecutor.h"
#import "MendeleyAcademicStatusesAPI.h"
#import "MendeleyAnnotationsAPI.h"
#import "MendeleyDocumentsAPI.h"
#import "MendeleyFilesAPI.h"
#import "MendeleyFoldersAPI.h"
#import "MendeleyGroupsAPI.h"
#import "MendeleyMetadataAPI.h"
#import "NSError+MendeleyError.h"
#import "MendeleyProfilesAPI.h"
#import "MendeleyDisciplinesAPI.h"


@interface MendeleyKit ()

@property (nonatomic, assign, readwrite) BOOL loggedIn;
@property (nonatomic, strong) MendeleyKitConfiguration *configuration;
@property (nonatomic, strong) id <MendeleyNetworkProvider> networkProvider;
@property (nonatomic, strong) MendeleyAnnotationsAPI *annotationsAPI;
@property (nonatomic, strong) MendeleyDocumentsAPI *documentsAPI;
@property (nonatomic, strong) MendeleyFilesAPI *filesAPI;
@property (nonatomic, strong) MendeleyFoldersAPI *foldersAPI;
@property (nonatomic, strong) MendeleyGroupsAPI *groupsAPI;
@property (nonatomic, strong) MendeleyMetadataAPI *metedataAPI;
@property (nonatomic, strong) MendeleyProfilesAPI *profilesAPI;
@property (nonatomic, strong) MendeleyDisciplinesAPI *disciplinesAPI;
@property (nonatomic, strong) MendeleyAcademicStatusesAPI *academicStatusesAPI;
@end

@implementation MendeleyKit


#pragma mark -
#pragma mark SDK configuration

+ (MendeleyKit *)sharedInstance
{
    static MendeleyKit *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[MendeleyKit alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _configuration = [MendeleyKitConfiguration sharedInstance];
        _networkProvider =  [MendeleyKitConfiguration sharedInstance].networkProvider;
        [self updateConfiguration];
        [self initialLoginStatus];
    }
    return self;
}

- (void)changeNetworkProviderWithClassName:(NSString *)networkProviderClassName
{
    NSDictionary *providerDict = @{ kMendeleyNetworkProviderKey : networkProviderClassName };

    [self.configuration changeConfigurationWithParameters:providerDict];
    self.networkProvider = self.configuration.networkProvider;
    [self updateConfiguration];
}

- (void)updateConfiguration
{
    NSURL *baseURL = self.configuration.baseAPIURL;

    self.documentsAPI = [[MendeleyDocumentsAPI alloc]
                         initWithNetworkProvider:self.networkProvider
                                         baseURL:baseURL];

    self.filesAPI = [[MendeleyFilesAPI alloc]
                     initWithNetworkProvider:self.networkProvider
                                     baseURL:baseURL];

    self.foldersAPI = [[MendeleyFoldersAPI alloc]
                       initWithNetworkProvider:self.networkProvider
                                       baseURL:baseURL];

    self.groupsAPI = [[MendeleyGroupsAPI alloc]
                      initWithNetworkProvider:self.networkProvider
                                      baseURL:baseURL];

    self.annotationsAPI = [[MendeleyAnnotationsAPI alloc]
                           initWithNetworkProvider:self.networkProvider
                                           baseURL:baseURL];

    self.metedataAPI = [[MendeleyMetadataAPI alloc]
                        initWithNetworkProvider:self.networkProvider
                                        baseURL:baseURL];

    self.profilesAPI = [[MendeleyProfilesAPI alloc]
                        initWithNetworkProvider:self.networkProvider
                                        baseURL:baseURL];

    self.disciplinesAPI = [[MendeleyDisciplinesAPI alloc]
                           initWithNetworkProvider:self.networkProvider
                                           baseURL:baseURL];

    self.academicStatusesAPI = [[MendeleyAcademicStatusesAPI alloc]
                                initWithNetworkProvider:self.networkProvider
                                                baseURL:baseURL];

}

- (BOOL)isAuthenticated
{
    MendeleyOAuthStore *store = [[MendeleyOAuthStore alloc] init];
    MendeleyOAuthCredentials *credentials = [store retrieveOAuthCredentials];

    _loggedIn = (nil != credentials);
    return _loggedIn;
}

- (void)initialLoginStatus
{
    MendeleyOAuthStore *store = [[MendeleyOAuthStore alloc] init];
    MendeleyOAuthCredentials *credentials = [store retrieveOAuthCredentials];

    if (nil != credentials)
    {
        self.loggedIn = YES;
    }
    else
    {
        self.loggedIn = NO;
    }
}

- (void)clearAuthentication
{
    MendeleyOAuthStore *store = [[MendeleyOAuthStore alloc] init];

    [store removeOAuthCredentials];
}

- (MendeleyTask *)checkAuthorisationStatusWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    if (!self.isAuthenticated)
    {
        if (completionBlock)
        {
            NSError *error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:kMendeleyUnauthorizedErrorCode];
            completionBlock(NO, error);
        }
        return nil;
    }
    MendeleyTask *task = [MendeleyTask new];
    MendeleyOAuthStore *store = [[MendeleyOAuthStore alloc] init];
    MendeleyOAuthCredentials *credentials = [store retrieveOAuthCredentials];
    MendeleyKitConfiguration *configuration = [MendeleyKitConfiguration sharedInstance];
    [configuration.oauthProvider refreshTokenWithOAuthCredentials:credentials task:task completionBlock:^(MendeleyOAuthCredentials *credentials, NSError *error) {
        if (nil != completionBlock)
        {
            BOOL success = (nil != credentials);
            completionBlock(success, error);
        }
    }];
    return task;
}



- (MendeleyTask *)pagedListOfObjectsWithLinkedURL:(NSURL *)linkURL
                                    expectedModel:(NSString *)expectedModel
                                  completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    if ([expectedModel isEqualToString:NSStringFromClass([MendeleyDocument class])])
    {
        return [self documentListWithLinkedURL:linkURL
                               completionBlock:completionBlock];
    }
    else if ([expectedModel isEqualToString:NSStringFromClass([MendeleyFolder class])])
    {
        return [self folderListWithLinkedURL:linkURL
                             completionBlock:completionBlock];
    }
    else if ([expectedModel isEqualToString:NSStringFromClass([MendeleyGroup class])])
    {
        return [self groupListWithLinkedURL:linkURL
                            completionBlock:completionBlock];
    }
    else if ([expectedModel isEqualToString:NSStringFromClass([MendeleyFile class])])
    {
        return [self fileListWithLinkedURL:linkURL
                           completionBlock:completionBlock];
    }
    else if ([expectedModel isEqualToString:kMendeleyModelDocumentId])
    {
        return [self documentListInFolderWithLinkedURL:linkURL
                                       completionBlock:completionBlock];
    }
    else if ([expectedModel isEqualToString:NSStringFromClass([MendeleyAnnotation class])])
    {
        return [self annotationListWithLinkedURL:linkURL
                                 completionBlock:completionBlock];
    }
    else
    {
        NSError *error = [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain
                                                                           code:kMendeleyPagingNotProvidedForThisType];
        completionBlock(nil, nil, error);
        return nil;
    }
}

#pragma mark -
#pragma mark Academic Status
- (MendeleyTask *)academicStatusesWithCompletionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    [self.academicStatusesAPI academicStatusesWithTask:task
                                       completionBlock:completionBlock];

    return task;
}


#pragma mark -
#pragma mark Disciplines
- (MendeleyTask *)disciplinesWithCompletionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    [self.disciplinesAPI disciplinesWithTask:task
                             completionBlock:completionBlock];
    return task;

}

#pragma mark -
#pragma mark Profiles

- (MendeleyTask *)pullMyProfile:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock:^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.profilesAPI pullMyProfileWithTask:task
                                         completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)pullProfile:(NSString *)profileID
              completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock:^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.profilesAPI pullProfile:profileID
                                          task:task
                               completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}
- (MendeleyTask *)profileIconForProfile:(MendeleyProfile *)profile
                               iconType:(MendeleyIconType)iconType
                        completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock
{
    /*
       Note: this call doesn't require an authentication header
     */
    MendeleyTask *task = [MendeleyTask new];

    [self.profilesAPI profileIconForProfile:profile iconType:iconType
                                       task:task
                            completionBlock:completionBlock];
    return task;
}

- (MendeleyTask *)profileIconForIconURLString:(NSString *)iconURLString
                              completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock
{
    /*
       Note: this call doesn't require an authentication header
     */
    MendeleyTask *task = [MendeleyTask new];

    [self.profilesAPI profileIconForIconURLString:iconURLString
                                             task:task
                                  completionBlock:completionBlock];
    return task;

}

- (MendeleyTask *)createProfile:(MendeleyNewProfile *)profile
                completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    [self.profilesAPI createProfile:profile
                               task:task
                    completionBlock:completionBlock];
    return task;
}

- (MendeleyTask *)updateMyProfile:(MendeleyAmendmentProfile *)myProfile
                  completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.profilesAPI updateMyProfile:myProfile
                                              task:task
                                   completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;

}


#pragma mark -
#pragma mark Documents

- (MendeleyTask *)documentListWithLinkedURL:(NSURL *)linkURL
                            completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI documentListWithLinkedURL:linkURL
                                                         task:task
                                              completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)documentListWithQueryParameters:(MendeleyDocumentParameters *)queryParameters
                                  completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI documentListWithQueryParameters:queryParameters
                                                               task:task
                                                    completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)documentWithDocumentID:(NSString *)documentID
                         completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI documentWithDocumentID:documentID
                                                      task:task
                                           completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}


- (MendeleyTask *)catalogDocumentWithCatalogID:(NSString *)catalogID
                               completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock:^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI catalogDocumentWithCatalogID:catalogID
                                                            task:task
                                                 completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)catalogDocumentWithParameters:(MendeleyCatalogParameters *)queryParameters
                                completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock:^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI catalogDocumentWithParameters:queryParameters
                                                             task:task
                                                  completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;

}

- (MendeleyTask *)createDocument:(MendeleyDocument *)mendeleyDocument
                 completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI createDocument:mendeleyDocument
                                              task:task
                                   completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)updateDocument:(MendeleyDocument *)updatedDocument
                 completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock:^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI updateDocument:updatedDocument
                                              task:task
                                   completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}


- (MendeleyTask *)deleteDocumentWithID:(NSString *)documentID
                       completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI deleteDocumentWithID:documentID
                                                    task:task
                                         completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)trashDocumentWithID:(NSString *)documentID
                      completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI trashDocumentWithID:documentID
                                                   task:task
                                        completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)deletedDocumentsSince:(NSDate *)deletedSince
                        completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    return [self deletedDocumentsSince:deletedSince
                               groupID:nil
                       completionBlock:completionBlock];
}

- (MendeleyTask *)deletedDocumentsSince:(NSDate *)deletedSince
                                groupID:(NSString *)groupID
                        completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI deletedDocumentsSince:deletedSince
                                                  groupID:groupID
                                                     task:task
                                          completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)trashedDocumentListWithLinkedURL:(NSURL *)linkURL
                                   completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI trashedDocumentListWithLinkedURL:linkURL
                                                                task:task
                                                     completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)trashedDocumentListWithQueryParameters:(MendeleyDocumentParameters *)queryParameters
                                         completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI trashedDocumentListWithQueryParameters:queryParameters
                                                                      task:task
                                                           completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)deleteTrashedDocumentWithID:(NSString *)documentID
                              completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI deleteTrashedDocumentWithID:documentID
                                                           task:task
                                                completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)restoreTrashedDocumentWithID:(NSString *)documentID
                               completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI restoreTrashedDocumentWithID:documentID
                                                            task:task
                                                 completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)trashedDocumentWithDocumentID:(NSString *)documentID
                                completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI trashedDocumentWithDocumentID:documentID
                                                             task:task
                                                  completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)documentFromFileWithURL:(NSURL *)fileURL
                                 mimeType:(NSString *)mimeType
                          completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI documentFromFileWithURL:fileURL
                                                   mimeType:mimeType
                                                       task:task
                                            completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}


#pragma mark -
#pragma mark Metadata

- (MendeleyTask *)metadataLookupWithQueryParameters:(MendeleyMetadataParameters *)queryParameters
                                    completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.metedataAPI metadataLookupWithQueryParameters:queryParameters
                                                                task:task
                                                     completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

#pragma mark -
#pragma mark Document Types

- (MendeleyTask *)documentTypesWithCompletionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI documentTypesWithTask:task
                                          completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

#pragma mark -
#pragma mark Document Identifiers

- (MendeleyTask *)identifierTypesWithCompletionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.documentsAPI identifierTypesWithTask:task
                                            completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

#pragma mark -
#pragma mark Files

- (MendeleyTask *)fileListWithQueryParameters:(MendeleyFileParameters *)queryParameters
                              completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI fileListWithQueryParameters:queryParameters
                                                       task:task
                                            completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)fileWithFileID:(NSString *)fileID
                       saveToURL:(NSURL *)fileURL
                   progressBlock:(MendeleyResponseProgressBlock)progressBlock
                 completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI fileWithFileID:fileID saveToURL:fileURL
                                          task:task
                                 progressBlock:progressBlock
                               completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *) createFile:(NSURL *)fileURL
    relativeToDocumentURLPath:(NSString *)documentURLPath
                progressBlock:(MendeleyResponseProgressBlock)progressBlock
              completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [self createFile:fileURL
                                 filename:nil
                              contentType:nil
                relativeToDocumentURLPath:documentURLPath
                            progressBlock:progressBlock
                          completionBlock:completionBlock];

    return task;
}

- (MendeleyTask *) createFile:(NSURL *)fileURL
                     filename:(NSString *)filename
                  contentType:(NSString *)contentType
    relativeToDocumentURLPath:(NSString *)documentURLPath
                progressBlock:(MendeleyResponseProgressBlock)progressBlock
              completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI createFile:fileURL
                                   filename:filename
                                contentType:contentType
                  relativeToDocumentURLPath:documentURLPath
                                       task:task
                              progressBlock:progressBlock
                            completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}


- (MendeleyTask *)deleteFileWithID:(NSString *)fileID
                   completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI deleteFileWithID:fileID
                                            task:task
                                 completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)fileListWithLinkedURL:(NSURL *)linkURL
                        completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI fileListWithLinkedURL:linkURL
                                                 task:task
                                      completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)deletedFilesSince:(NSDate *)deletedSince
                    completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    return [self deletedFilesSince:deletedSince
                           groupID:nil
                   completionBlock:completionBlock];
}

- (MendeleyTask *)deletedFilesSince:(NSDate *)deletedSince
                            groupID:(NSString *)groupID
                    completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI deletedFilesSince:deletedSince
                                          groupID:groupID
                                             task:task
                                  completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)recentlyReadWithParameters:(MendeleyRecentlyReadParameters *)queryParameters
                             completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI recentlyReadWithParameters:queryParameters
                                                      task:task
                                           completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)addRecentlyRead:(MendeleyRecentlyRead *)recentlyRead
                  completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI addRecentlyRead:recentlyRead
                                           task:task
                                completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;

}

/**
   Note: this service is not yet available
   - (MendeleyTask *)updateRecentlyRead:(MendeleyRecentlyRead *)recentlyRead
                     completionBlock:(MendeleySecureObjectCompletionBlock)completionBlock
   {
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.filesAPI updateRecentlyRead:recentlyRead
                                              task:task
                                   completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
   }
 */

#pragma mark -
#pragma mark Folder

- (MendeleyTask *)documentListFromFolderWithID:(NSString *)folderID
                                    parameters:(MendeleyFolderParameters *)queryParameters
                               completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI documentListFromFolderWithID:folderID
                                                    parameters:queryParameters
                                                          task:task
                                               completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)addDocument:(NSString *)mendeleyDocumentId
                     folderID:(NSString *)folderID
              completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI addDocument:mendeleyDocumentId
                                     folderID:folderID
                                         task:task
                              completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)createFolder:(MendeleyFolder *)mendeleyFolder
               completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI createFolder:mendeleyFolder
                                          task:task
                               completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)folderListWithLinkedURL:(NSURL *)linkURL
                          completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI folderListWithLinkedURL:linkURL
                                                     task:task
                                          completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)documentListInFolderWithLinkedURL:(NSURL *)linkURL
                                    completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI documentListInFolderWithLinkedURL:linkURL
                                                               task:task
                                                    completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)folderListWithQueryParameters:(MendeleyFolderParameters *)queryParameters
                                completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI folderListWithQueryParameters:queryParameters
                                                           task:task
                                                completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)folderWithFolderID:(NSString *)folderID
                     completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI folderWithFolderID:folderID
                                                task:task
                                     completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)deleteFolderWithID:(NSString *)folderID
                     completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI deleteFolderWithID:folderID
                                                task:task
                                     completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)updateFolder:(MendeleyFolder *)updatedFolder
               completionBlock:(MendeleyCompletionBlock)completionBlock;
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI updateFolder:updatedFolder
                                          task:task
                               completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)deleteDocumentWithID:(NSString *)documentID fromFolderWithID:(NSString *)folderID completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.foldersAPI deleteDocumentWithID:documentID
                                      fromFolderWithID:folderID
                                                  task:task
                                       completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

#pragma mark -
#pragma mark Groups
- (MendeleyTask *)groupListWithQueryParameters:(MendeleyGroupParameters *)queryParameters
                                      iconType:(MendeleyIconType)iconType
                               completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.groupsAPI groupListWithQueryParameters:queryParameters
                                                     iconType:iconType
                                                         task:task
                                              completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;

}

- (MendeleyTask *)groupListWithLinkedURL:(NSURL *)linkURL
                                iconType:(MendeleyIconType)iconType
                         completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.groupsAPI groupListWithLinkedURL:linkURL
                                               iconType:iconType
                                                   task:task
                                        completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;

}

- (MendeleyTask *)groupWithGroupID:(NSString *)groupID
                          iconType:(MendeleyIconType)iconType
                   completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.groupsAPI groupWithGroupID:groupID
                                         iconType:iconType
                                             task:task
                                  completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;

}

- (MendeleyTask *)groupListWithQueryParameters:(MendeleyGroupParameters *)queryParameters
                               completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.groupsAPI groupListWithQueryParameters:queryParameters
                                                         task:task
                                              completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)groupListWithLinkedURL:(NSURL *)linkURL
                         completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.groupsAPI groupListWithLinkedURL:linkURL
                                                   task:task
                                        completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)groupWithGroupID:(NSString *)groupID
                   completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.groupsAPI groupWithGroupID:groupID
                                             task:task
                                  completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)groupIconForGroup:(MendeleyGroup *)group
                           iconType:(MendeleyIconType)iconType
                    completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock
{
    /*
       Note: this call doesn't require an authentication header
     */
    MendeleyTask *task = [MendeleyTask new];

    [self.groupsAPI groupIconForGroup:group iconType:iconType
                                 task:task
                      completionBlock:completionBlock];
    return task;
}


- (MendeleyTask *)groupIconForIconURLString:(NSString *)iconURLString
                            completionBlock:(MendeleyBinaryDataCompletionBlock)completionBlock
{
    /*
       Note: this call doesn't require an authentication header
     */
    MendeleyTask *task = [MendeleyTask new];

    [self.groupsAPI groupIconForIconURLString:iconURLString
                                         task:task
                              completionBlock:completionBlock];
    return task;

}


#pragma mark -
#pragma mark Annotations

- (MendeleyTask *)annotationWithAnnotationID:(NSString *)annotationID
                             completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.annotationsAPI annotationWithAnnotationID:annotationID task:task
                                                 completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)deleteAnnotationWithID:(NSString *)annotationID
                         completionBlock:(MendeleyCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.annotationsAPI deleteAnnotationWithID:annotationID task:task
                                             completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(NO, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(NO, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)updateAnnotation:(MendeleyAnnotation *)updatedMendeleyAnnotation
                   completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.annotationsAPI updateAnnotation:updatedMendeleyAnnotation task:task
                                       completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)createAnnotation:(MendeleyAnnotation *)mendeleyAnnotation
                   completionBlock:(MendeleyObjectCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.annotationsAPI createAnnotation:mendeleyAnnotation task:task
                                       completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)annotationListWithLinkedURL:(NSURL *)linkURL
                              completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock:^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.annotationsAPI annotationListWithLinkedURL:linkURL task:task
                                                  completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;

}


- (MendeleyTask *)annotationListWithQueryParameters:(MendeleyAnnotationParameters *)queryParameters
                                    completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.annotationsAPI annotationListWithQueryParameters:queryParameters task:task
                                                        completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (MendeleyTask *)deletedAnnotationsSince:(NSDate *)deletedSince
                          completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    return [self deletedAnnotationsSince:deletedSince
                                 groupID:nil
                         completionBlock:completionBlock];
}

- (MendeleyTask *)deletedAnnotationsSince:(NSDate *)deletedSince
                                  groupID:(NSString *)groupID
                          completionBlock:(MendeleyArrayCompletionBlock)completionBlock
{
    MendeleyTask *task = [MendeleyTask new];

    if (self.isAuthenticated)
    {
        [MendeleyOAuthTokenHelper refreshTokenWithRefreshBlock: ^(BOOL success, NSError *error) {
             if (success)
             {
                 [self.annotationsAPI deletedAnnotationsSince:deletedSince
                                                      groupID:groupID
                                                         task:task
                                              completionBlock:completionBlock];
             }
             else
             {
                 completionBlock(nil, nil, error);
             }
         }];
    }
    else
    {
        NSError *unauthorisedError = [NSError errorWithCode:kMendeleyUnauthorizedErrorCode];
        completionBlock(nil, nil, unauthorisedError);
    }

    return task;
}

- (void) cancelTask:(MendeleyTask *)task
    completionBlock:(MendeleyCompletionBlock)completionBlock
{
    [self.networkProvider cancelTask:task
                     completionBlock:completionBlock];
}

- (void)cancelAllTasks:(MendeleyCompletionBlock)completionBlock
{
    [self.networkProvider cancelAllTasks:completionBlock];
}

@end
