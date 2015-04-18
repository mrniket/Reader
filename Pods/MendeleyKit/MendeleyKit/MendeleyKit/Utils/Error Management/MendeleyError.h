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

#ifndef MendeleyKit_MendeleyError_h
#define MendeleyKit_MendeleyError_h

/***********************************************
   @name Mendeley Error Codes And Descriptions
   // TODO: change
***********************************************/
/**
   Error codes
   - 11xx region JSON
   - 12xx region Model
   - 13xx region unexpected data types
   - 14xx region authentication and networking
   - 15xx General
 */
typedef NS_ENUM (int, MendeleyErrorCode)
{
    kMendeleyJSONTypeUnrecognisedErrorCode = 1100,
    kMendeleyJSONTypeNotMappedToModelErrorCode,
    kMendeleyJSONTypeObjectNilErrorCode,

    kMendeleyUnrecognisedModelErrorCode = 1200,
    kMendeleyModelOrPropertyNilErrorCode,

    kMendeleyUnexpectedMimeTypeErrorCode = 1300,
    kMendeleyUnknownDataTypeErrorCode,
    kMendeleyPagingNotProvidedForThisType,

    kMendeleyNetworkGenericError = 1400,
    kMendeleyUnauthorizedErrorCode,
    kMendeleyInvalidAccessTokenErrorCode,
    kMendeleyCancelledRequestErrorCode,
    kMendeleyNetworkUnreachable,
    kMendeleyFileNotAvailableForTransfer,
    kMendeleyConnectionCannotBeStarted,
    kMendeleyConnectionFinishedWithError,
    kMendeleyDataNotAvailableErrorCode,
    kMendeleyMissingDataProvidedErrorCode,

    kMendeleyResponseTypeUnknownErrorCode = 1500,
    kMendeleyPathNotFoundErrorCode
};

/**
   error domain
 */
#define kMendeleyErrorDomain @"com.MendeleyKit.error"

#endif /* ifndef MendeleyKit_MendeleyError_h */
