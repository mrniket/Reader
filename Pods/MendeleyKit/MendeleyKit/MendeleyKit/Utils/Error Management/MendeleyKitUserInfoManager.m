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

#import "MendeleyKitUserInfoManager.h"

@implementation MendeleyKitUserInfoManager

- (NSDictionary *)userInfoWithErrorCode:(NSInteger)errorCode
{
    NSString *descriptionString;
    NSString *failureReasonString;
    NSString *recoverySuggestionString;

    switch (errorCode)
    {
        case MendeleyErrorUnknown:
            descriptionString = @"Unknown Error";
            failureReasonString = @"Unknown Error";
            recoverySuggestionString = @"Unknown Error";
            break;
        case kMendeleyJSONTypeUnrecognisedErrorCode:
            descriptionString = @"Unrecognised JSON object";
            failureReasonString = @"Unrecognised JSON object";
            recoverySuggestionString = @"Unrecognised JSON object";
            break;
        case kMendeleyJSONTypeNotMappedToModelErrorCode:
            descriptionString = @"JSON cannot be mapped to a Mendeley model";
            failureReasonString = @"JSON cannot be mapped to a Mendeley model";
            recoverySuggestionString = @"JSON cannot be mapped to a Mendeley model";
            break;
        case kMendeleyJSONTypeObjectNilErrorCode:
            descriptionString = @"The JSON object or array are nil";
            failureReasonString = @"The JSON object or array are nil";
            recoverySuggestionString = @"The JSON object or array are nil";
            break;
        case kMendeleyUnrecognisedModelErrorCode:
            descriptionString = @"The model class or object were not recognised or are nil";
            failureReasonString = @"The model class or object were not recognised or are nil";
            recoverySuggestionString = @"The model class or object were not recognised or are nil";
            break;
        case kMendeleyModelOrPropertyNilErrorCode:
            descriptionString = @"The model and/or property are nil";
            failureReasonString = @"The model and/or property are nil";
            recoverySuggestionString = @"The model and/or property are nil";
            break;
        case kMendeleyUnexpectedMimeTypeErrorCode:
            descriptionString = @"Unexpected MIME type";
            failureReasonString = @"Unexpected MIME type";
            recoverySuggestionString = @"Unexpected MIME type";
            break;
        case kMendeleyUnknownDataTypeErrorCode:
            descriptionString = @"Unknown data type found";
            failureReasonString = @"Unknown data type found";
            recoverySuggestionString = @"Unknown data type found";
            break;
        case kMendeleyUnauthorizedErrorCode:
            descriptionString = @"Unauthorized Access to Mendeley Server";
            failureReasonString = @"Unauthorized Access to Mendeley Server";
            recoverySuggestionString = @"Unauthorized Access to Mendeley Server";
            break;
        case kMendeleyInvalidAccessTokenErrorCode:
            descriptionString = @"Invalid access token";
            failureReasonString = @"Invalid access token";
            recoverySuggestionString = @"Invalid access token";
            break;
        case kMendeleyCancelledRequestErrorCode:
            descriptionString = @"Request was cancelled";
            failureReasonString = @"Request was cancelled";
            recoverySuggestionString = @"Request was cancelled";
            break;
        case kMendeleyResponseTypeUnknownErrorCode:
            descriptionString = @"Unexpected Response";
            failureReasonString = @"Unexpected Response";
            recoverySuggestionString = @"Unexpected Response";
            break;
        case kMendeleyPathNotFoundErrorCode:
            descriptionString = @"The requested path was not found";
            failureReasonString = @"The requested path was not found";
            recoverySuggestionString = @"The requested path was not found";
            break;
        case kMendeleyPagingNotProvidedForThisType:
            descriptionString = @"Paging is not enabled for this type of object";
            failureReasonString = @"Paging is not enabled for this type of object";
            recoverySuggestionString = @"Paging is not enabled for this type of object";
            break;
        case kMendeleyFileNotAvailableForTransfer:
            descriptionString = @"File for upload or downloaded file cannot be found";
            failureReasonString = @"File for upload or downloaded file cannot be found";
            recoverySuggestionString = @"File for upload or downloaded file cannot be found";
            break;
        case kMendeleyConnectionCannotBeStarted:
            descriptionString = @"The network/API call could not be launched";
            failureReasonString = @"The network/API call could not be launched";
            recoverySuggestionString = @"The network/API call could not be launched";
            break;
        case kMendeleyConnectionFinishedWithError:
            descriptionString = @"The network/API call finished with an error";
            failureReasonString = @"The network/API call finished with an error";
            recoverySuggestionString = @"The network/API call finished with an error";
            break;
        case kMendeleyDataNotAvailableErrorCode:
            descriptionString = @"The requested data are not available";
            failureReasonString = @"The requested data are not available";
            recoverySuggestionString = @"The requested data are not available";
            break;
        case kMendeleyMissingDataProvidedErrorCode:
            descriptionString = @"The request failed because one of the properties in the requests is either missing or nil";
            failureReasonString = @"The request failed because one of the properties in the requests is either missing or nil";
            recoverySuggestionString = @"The request failed because one of the properties in the requests is either missing or nil";
            break;
            
        default:
            return nil;
    }
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: descriptionString,
        NSLocalizedFailureReasonErrorKey: failureReasonString,
        NSLocalizedRecoverySuggestionErrorKey: recoverySuggestionString
    };
    return userInfo;
}

@end
