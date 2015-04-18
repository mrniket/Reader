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

#ifndef MendeleyKit_MendeleyGlobals_h
#define MendeleyKit_MendeleyGlobals_h

@class MendeleyResponse, MendeleyOAuthCredentials, MendeleySyncInfo, MendeleyDocument, MendeleyObject, MendeleySecureObject;

/***********************************************
   @name Mendeley Server URLs as strings
***********************************************/
#define kMendeleyKitURL                       @"https://api.mendeley.com"

/***********************************************
   @name Mendeley Server setting keys
***********************************************/
#define kMendeleyBaseAPIURLKey                @"BaseAPIURLKey"
#define kMendeleyTrustedSSLServerKey          @"TrustedSSLServerKey"
#define kMendeleyDocumentViewType             @"DefaultDocumentViewType"

/***********************************************
   @name Mendeley Server Document View Type
***********************************************/
#define kMendeleyDocumentViewTypeDefault      @""
#define kMendeleyDocumentViewTypeBibliography @"bib"
#define kMendeleyDocumentViewTypeClient       @"client"
#define kMendeleyDocumentViewTypeTags         @"tags"
#define kMendeleyDocumentViewTypeAll          @"all"

/***********************************************
   @name Mendeley SDK Provider keys
***********************************************/
#define kMendeleyOAuthProviderKey             @"MendeleyKitOAuthProvider"
#define kMendeleyNetworkProviderKey           @"MendeleyKitNetworkProvider"
#define kMendeleyOAuth2RedirectURLKey         @"redirect_uri"
#define kMendeleyOAuth2ClientSecretKey        @"client_secret"
#define kMendeleyOAuth2ClientIDKey            @"client_id"

/***********************************************
   @name Enums definitions
***********************************************/
typedef NS_ENUM (int, MendeleyHTTPRequestType)
{
    HTTP_GET = 0,
    HTTP_DELETE,
    HTTP_POST,
    HTTP_PUT,
    HTTP_PATCH,
    HTTP_HEAD
};

typedef NS_ENUM (int, MendeleyResponseBodyContentType)
{
    JSONBody = 0,
    PDFBody,
    JPGBody,
    PNGBody,
    BinaryBody,
    UnknownBody
};

typedef NS_ENUM (int, MendeleyIconType)
{
    OriginalIcon = 0,
    SquareIcon,
    StandardIcon
};

/***********************************************
   @name Block definitions
***********************************************/
typedef void (^MendeleyOAuthCompletionBlock)(MendeleyOAuthCredentials *credentials, NSError *error);
typedef void (^MendeleyResponseCompletionBlock)(MendeleyResponse *response, NSError *error);
typedef void (^MendeleyResponseProgressBlock)(NSNumber *progress);
typedef void (^MendeleyCompletionBlock)(BOOL success, NSError *error);
typedef void (^MendeleyArrayCompletionBlock)(NSArray *array, MendeleySyncInfo *syncInfo, NSError *error);
typedef void (^MendeleyObjectCompletionBlock)(MendeleyObject *mendeleyObject, MendeleySyncInfo *syncInfo, NSError *error);
typedef void (^MendeleySecureObjectCompletionBlock)(MendeleySecureObject *object, MendeleySyncInfo *syncInfo, NSError *error);
typedef void (^MendeleyDictionaryResponseBlock)(NSDictionary *dictionary, NSError *error);
typedef void (^MendeleyDeserializedResponseObject)(id deserializedResponseObject, NSError *deserializeError);
typedef void (^MendeleyBinaryDataCompletionBlock)(NSData *binaryData, NSError *dataError);
typedef void (^MendeleyStringArrayCompletionBlock)(NSArray *arrayOfStrings, NSError *error);

/***********************************************
   @name default URL session settings
***********************************************/
#define kMendeleyDefaultCachePolicy                       NSURLRequestReloadIgnoringLocalCacheData
#define kMendeleyDefaultTimeOut                           60.0

/***********************************************
   @name Request keys
***********************************************/
#define kMendeleyRESTRequestAccept                        @"Accept"
#define kMendeleyRESTRequestContentDisposition            @"Content-Disposition"
#define kMendeleyRESTRequestContentType                   @"Content-Type"
#define kMendeleyRESTRequestContentLength                 @"Content-Length"
#define kMendeleyRESTRequestJPEGType                      @"image/jpeg"
#define kMendeleyRESTRequestPNGType                       @"image/png"
#define kMendeleyRESTRequestBinaryType                    @"application/octet-stream"
#define kMendeleyRESTRequestJSONType                      @"application/json"
#define kMendeleyRESTRequestURLType                       @"application/x-www-form-urlencoded"
#define kMendeleyRESTRequestJSONAnnotationType            @"application/vnd.mendeley-annotation.1+json"
#define kMendeleyRESTRequestJSONDocumentType              @"application/vnd.mendeley-document.1+json"
#define kMendeleyRESTRequestJSONMetadataLookupType        @"application/vnd.mendeley-document-lookup.1+json"
#define kMendeleyRESTRequestJSONFileType                  @"application/vnd.mendeley-file.1+json"
#define kMendeleyRESTRequestJSONFolderType                @"application/vnd.mendeley-folder.1+json"
#define kMendeleyRESTRequestJSONFolderDocumentIDsType     @"application/vnd.mendeley-folder-documentids.1+json"
#define kMendeleyRESTRequestJSONGroupType                 @"application/vnd.mendeley-group.1+json"
#define kMendeleyRESTRequestJSONUserRoleType              @"application/vnd.mendeley-membership.1+json"
#define kMendeleyRESTRequestJSONLookup                    @"application/vnd.mendeley-lookup.1+json"
#define kMendeleyRESTRequestJSONProfilesType              @"application/vnd.mendeley-profiles.1+json"
#define kMendeleyRESTRequestJSONNewProfilesType           @"application/vnd.mendeley-new-profile.1+json"
#define kMendeleyRESTRequestJSONProfilesVerificationType  @"application/vnd.mendeley-profile-verification.1+json"
#define kMendeleyRESTRequestJSONProfileUpdateType         @"application/vnd.mendeley-profile-amendment.1+json"
#define kMendeleyRESTRequestJSONDisciplineType            @"application/vnd.mendeley-discipline.1+json"
#define kMendeleyRESTRequestJSONAcademicStatuses          @"application/vnd.mendeley-academic-status.1+json"
#define kMendeleyRESTRequestJSONRecentlyRead              @"application/vnd.mendeley-recently-read.1+json"
#define kMendeleyOAuth2ClientVersionKey                   @"Client-Version"
#define kMendeleyOAuth2UserAgentKey                       @"User-Agent"
#define kMendeleyOAuth2AcceptLanguageKey                  @"Accept-Language"
#define kMendeleyRESTRequestDate                          @"Date"
#define kMendeleyRESTRequestLink                          @"Link"
#define kMendeleyRESTHTTPLinkNext                         @"next"
#define kMendeleyRESTHTTPLinkPrevious                     @"previous"
#define kMendeleyRESTHTTPLinkFirst                        @"first"
#define kMendeleyRESTHTTPLinkLast                         @"last"
#define kMendeleyRESTHTTPTotalCount                       @"Mendeley-Count"

/***********************************************
   @name Request values
***********************************************/
#define kMendeleyRESTRequestValueAttachment               @"attachment"
#define kMendeleyRESTRequestValuePDF                      @"application/pdf"

/***********************************************
   @name REST API endpoints
***********************************************/
#define kMendeleyRESTAPIDocuments                         @"documents"
#define kMendeleyRESTAPIDocumentWithID                    @"documents/%@"
#define kMendeleyRESTAPIDocumentWithIDToTrash             @"documents/%@/trash"
#define kMendeleyRESTAPICatalog                           @"catalog"
#define kMendeleyRESTAPICatalogWithID                     @"catalog/%@"
#define kMendeleyRESTAPIMetadata                          @"metadata"
#define kMendeleyRESTAPITrashedDocuments                  @"trash"
#define kMendeleyRESTAPITrashedDocumentWithID             @"trash/%@"
#define kMendeleyRESTAPIRestoreTrashedDocumentWithID      @"trash/%@/restore"
#define kMendeleyRESTAPIDocumentTypes                     @"document_types"
#define kMendeleyRESTAPIIdentifierTypes                   @"identifier_types"
#define kMendeleyRESTAPIFiles                             @"files"
#define kMendeleyRESTAPIFileWithID                        @"files/%@"
#define kMendeleyRESTAPIFolders                           @"folders"
#define kMendeleyRESTAPIFolderWithID                      @"folders/%@"
#define kMendeleyRESTAPIDocumentWithIDInFolderWithID      @"folders/%@/documents/%@"
#define kMendeleyRESTAPIDocumentsInFolderWithID           @"folders/%@/documents"
#define kMendeleyRESTAPIGroups                            @"groups"
#define kMendeleyRESTAPIGroupWithID                       @"groups/%@"
#define kMendeleyRESTAPIMembersInGroupWithID              @"groups/%@/members"
#define kMendeleyRESTAPIAnnotations                       @"annotations"
#define kMendeleyRESTAPIAnnotationWithID                  @"annotations/%@"
#define kMendeleyRESTAPIAnnotationsSync                   @"documents/%@/annotations_sync"
#define kMendeleyRESTAPIAnnotationsSyncWithID             @"documents/%@/annotations_sync/%@"
#define kMendeleyRESTAPIProfilesMe                        @"profiles/me"
#define kMendeleyRESTAPIProfilesWithID                    @"profiles/%@"
#define kMendeleyRESTAPIProfiles                          @"profiles"
#define kMendeleyRESTAPIDisciplines                       @"disciplines"
#define kMendeleyRESTAPIAcademicStatuses                  @"academic_statuses"
#define kMendeleyRESTAPIRecentlyRead                      @"recently_read"

/***********************************************
   @name REST API Query Parameters
***********************************************/
#define kMendeleyRESTAPIQueryLimit                        @"limit"
#define kMendeleyRESTAPIQueryModifiedSince                @"modified_since"
#define kMendeleyRESTAPIQueryDeletedSince                 @"deleted_since"
#define kMendeleyRESTAPIQueryAddedSince                   @"added_since"
#define kMendeleyRESTAPIQuerySort                         @"sort"
#define kMendeleyRESTAPIQueryOrder                        @"order"
#define kMendeleyRESTAPIQueryReverse                      @"reverse"
#define kMendeleyRESTAPIQueryIncludeTrashed               @"include_trashed"
#define kMendeleyRESTAPIQueryGroupID                      @"group_id"
#define kMendeleyRESTAPIQueryProfileID                    @"profile_id"
#define kMendeleyRESTAPIQueryDocumentID                   @"document_id"
#define kMendeleyRESTAPIQuerySortAsc                      @"asc"
#define kMendeleyRESTAPIQuerySortDesc                     @"desc"
#define kMendeleyRESTAPIQueryOrderByTitle                 @"title"
#define kMendeleyRESTAPIQueryOrderByCreated               @"created"
#define kMendeleyRESTAPIQueryOrderByModified              @"last_modified"
#define kMendeleyRESTAPIQueryDelimiter                    @"&"
#define kMendeleyRESTAPIQueryMarker                       @"?"
#define kMendeleyRESTAPIQueryAssigner                     @"="
#define kMendeleyRESTAPIQueryViewType                     @"view"
#define kMendeleyRESTAPIQueryFilehash                     @"filehash"
#define kMendeleyRESTAPIQueryScopus                       @"scopus"
#define kMendeleyRESTAPIDefaultPageSize                   50
#define kMendeleyRESTAPIMaxPageSize                       200

/***********************************************
   @name Data models
***********************************************/
#define kMendeleyModelDocumentType                        @"MendeleyDocumentType"
#define kMendeleyModelMetadataLookup                      @"MendeleyMetadataLookup"
#define kMendeleyModelIdentifierType                      @"MendeleyIdentifierType"
#define kMendeleyModelDocument                            @"MendeleyDocument"
#define kMendeleyModelDocumentId                          @"MendeleyDocumentId"
#define kMendeleyModelCatalogDocument                     @"MendeleyCatalogDocument"
#define kMendeleyModelPerson                              @"MendeleyPerson"
#define kMendeleyModelFolder                              @"MendeleyFolder"
#define kMendeleyModelFile                                @"MendeleyFile"
#define kMendeleyModelOAuthCredentials                    @"MendeleyOAuthCredentials"
#define kMendeleyModelGroup                               @"MendeleyGroup"
#define kMendeleyModelAnnotation                          @"MendeleyAnnotation"
#define kMendeleyModelUserRole                            @"MendeleyUserRole"
#define kMendeleyModelProfile                             @"MendeleyProfile"
#define kMendeleyModelUserProfile                         @"MendeleyUserProfile"
#define kMendeleyModelEmployment                          @"MendeleyEmployment"
#define kMendeleyModelEducation                           @"MendeleyEducation"
#define kMendeleyModelRecentlyRead                        @"MendeleyRecentlyRead"
#define kMendeleyModelWebsites                            @"NSArray"
#define kMendeleyModelTags                                @"NSArray"
#define kMendeleyModelKeywords                            @"NSArray"
#define kMendeleyModelDiscipline                          @"MendeleyDiscipline"
#define kMendeleyModelAcademicStatus                      @"MendeleyAcademicStatus"
#define kMendeleyModelDisciplines                         @"NSArray"
#define kMendeleyModelSubdisciplines                      @"NSArray"
#define kMendeleyModelPhotos                              @"NSArray"
#define kMendeleyModelReaderCountByCountry                @"NSDictionary"
#define kMendeleyModelReaderCountByDiscipline             @"NSDictionary"
#define kMendeleyModelReaderCountByAcademicStatus         @"NSDictionary"

/***********************************************
   @name JSON keys General
***********************************************/
#define kMendeleyJSONID                                   @"id"
#define kMendeleyJSONDescription                          @"description"
#define kMendeleyJSONDateTimeFormat                       @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
#define kMendeleyHTTPHeaderDateFormat                     @"EEE', 'dd' 'MMM' 'yyyy' 'HH':'mm':'ss' GMT"
#define kMendeleyObjectID                                 @"object_ID"
#define kMendeleyObjectDescription                        @"objectDescription"


/***********************************************
   @name JSON keys Document
***********************************************/
#define kMendeleyJSONType                                 @"type"
#define kMendeleyJSONMonth                                @"month"
#define kMendeleyJSONYear                                 @"year"
#define kMendeleyJSONLastModified                         @"last_modified"
#define kMendeleyJSONDay                                  @"day"
#define kMendeleyJSONGroupID                              @"group_id"
#define kMendeleyJSONSource                               @"source"
#define kMendeleyJSONTitle                                @"title"
#define kMendeleyJSONRevision                             @"revision"
#define kMendeleyJSONAbstract                             @"abstract"
#define kMendeleyJSONIdentifiers                          @"identifiers"
#define kMendeleyJSONProfileID                            @"profile_id"
#define kMendeleyJSONAuthors                              @"authors"
#define kMendeleyJSONTranslators                          @"translators"
#define kMendeleyJSONCreated                              @"created"
#define kMendeleyJSONTrashed                              @"trashed"
#define kMendeleyJSONPages                                @"pages"
#define kMendeleyJSONVolume                               @"volume"
#define kMendeleyJSONIssue                                @"issue"
#define kMendeleyJSONWebsites                             @"websites"
#define kMendeleyJSONPublisher                            @"publisher"
#define kMendeleyJSONCity                                 @"city"
#define kMendeleyJSONEdition                              @"edition"
#define kMendeleyJSONInstitution                          @"institution"
#define kMendeleyJSONSeries                               @"series"
#define kMendeleyJSONChapter                              @"chapter"
#define kMendeleyJSONEditors                              @"editors"
#define kMendeleyJSONRead                                 @"read"
#define kMendeleyJSONStarred                              @"starred"
#define kMendeleyJSONAuthored                             @"authored"
#define kMendeleyJSONConfirmed                            @"confirmed"
#define kMendeleyJSONHidden                               @"hidden"
#define kMendeleyJSONPositions                            @"positions"
#define kMendeleyJSONErrorMessage                         @"message"
#define kMendeleyJSONFileAttached                         @"file_attached"
#define kMendeleyJSONTags                                 @"tags"
#define kMendeleyJSONKeywords                             @"keywords"
#define kMendeleyJSONDisciplines                          @"disciplines"
#define kMendeleyJSONReaderCountByCountry                 @"reader_count_by_country"
#define kMendeleyJSONReaderCountByDiscipline              @"reader_count_by_subdiscipline"
#define kMendeleyJSONReaderCountByAcademicStatus          @"reader_count_by_academic_status"

#define kMendeleyJSONCitationKey                          @"citation_key"
#define kMendeleyJSONSourceType                           @"source_type"
#define kMendeleyJSONLanguage                             @"language"
#define kMendeleyJSONShortTitle                           @"short_title"
#define kMendeleyJSONReprintEdition                       @"reprint_edition"
#define kMendeleyJSONGenre                                @"genre"
#define kMendeleyJSONCountry                              @"country"
#define kMendeleyJSONSeriesEditor                         @"series_editor"
#define kMendeleyJSONCode                                 @"code"
#define kMendeleyJSONMedium                               @"medium"
#define kMendeleyJSONUserContext                          @"user_context"
#define kMendeleyJSONDepartment                           @"department"
#define kMendeleyJSONPatentOwner                          @"patent_owner"
#define kMendeleyJSONPatentApplicationNumber              @"patent_application_number"
#define kMendeleyJSONPatentLegalStatus                    @"patent_legal_status"
#define kMendeleyJSONAccessed                             @"accessed"



/***********************************************
   @name JSON keys File
***********************************************/
#define kMendeleyJSONFileFileName                         @"file_name"
#define kMendeleyJSONFileMimeType                         @"mime_type"
#define kMendeleyJSONFileFileHash                         @"filehash"
#define kMendeleyJSONFileDocumentID                       @"document_id"
#define kMendeleyJSONFileCatalogID                        @"catalog_id"
#define kMendeleyJSONFileSize                             @"size"

/***********************************************
   @name JSON Folder Identifier keys
***********************************************/
#define kMendeleyJSONFolderParentID                       @"parent_id"
#define kMendeleyJSONFolderName                           @"name"
#define kMendeleyJSONFolderGroupID                        @"group_id"

/***********************************************
   @name JSON Document Identifier keys
***********************************************/
#define kMendeleyJSONIdentifierArxiv                      @"arxiv"
#define kMendeleyJSONIdentifierPmid                       @"pmid"
#define kMendeleyJSONIdentifierDoi                        @"doi"
#define kMendeleyJSONIdentifierIsbn                       @"isbn"
#define kMendeleyJSONIdentifierIssn                       @"issn"

/***********************************************
   @name JSON keys Annotations
***********************************************/
#define kMendeleyJSONColor                                @"color"
#define kMendeleyJSONPositions                            @"positions"
#define kMendeleyJSONTopLeft                              @"top_left"
#define kMendeleyJSONBottomRight                          @"bottom_right"
#define kMendeleyJSONPositionX                            @"x"
#define kMendeleyJSONPositionY                            @"y"
#define kMendeleyJSONColorRed                             @"r"
#define kMendeleyJSONColorGreen                           @"g"
#define kMendeleyJSONColorBlue                            @"b"
#define kMendeleyJSONPage                                 @"page"
#define kMendeleyJSONAnnotationDocumentID                 @"document_id"

/***********************************************
   @name JSON keys Group & Photo
***********************************************/
#define kMendeleyJSONLink                                 @"link"
#define kMendeleyJSONPhoto                                @"photo"
#define kMendeleyJSONPhotos                               @"photos"
#define kMendeleyJSONName                                 @"name"
#define kMendeleyJSONOriginal                             @"original"
#define kMendeleyJSONSquare                               @"square"
#define kMendeleyJSONStandard                             @"standard"

/***********************************************
   @name JSON keys Profile
***********************************************/
#define kMendeleyJSONLocation                             @"location"
#define kMendeleyJSONDiscipline                           @"discipline"
#define kMendeleyJSONSubdisciplines                       @"subdisciplines"
#define kMendeleyJSONEmployment                           @"employment"
#define kMendeleyJSONEducation                            @"education"

/***********************************************
   @name JSON keys Person
***********************************************/
/***********************************************
**  Field Definitions: ************************
   surname (string, optional),
   forename (string, optional)
***********************************************/
#define kMendeleyJSONSurname                              @"last_name"
#define kMendeleyJSONForename                             @"first_name"

/***********************************************
   @name Paging
***********************************************/
#define kMendeleyPagingNoSizeInfo                         -1


/***********************************************
   @name Performance Tools
***********************************************/
#define kMendeleyPerformanceReportFileNamePrefix          @"Mendeley Performance Report"
#define kMendeleyPerformanceReportFileKeyTimerTitle       @"Task Name"
#define kMendeleyPerformanceReportFileKeyTimerID          @"Task ID"
#define kMendeleyPerformanceReportFileKeyTimerStartTime   @"Start Time"
#define kMendeleyPerformanceReportFileKeyTimerElapsedTime @"Elapsed Time"
#define kMendeleyPerformanceReportFileKeySessionID        @"Session ID"
#define kMendeleyPerformanceReportFileKeySessionTitle     @"Session Name"
#define kMendeleyPerformanceReportFileKeySessionTotalTime @"Total Time"
#define kMendeleyPerformanceReportFileKeySessionJobList   @"Sub Tasks"

#endif /* ifndef MendeleyKit_MendeleyGlobals_h */
