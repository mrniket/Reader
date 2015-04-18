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

@interface MendeleyQueryRequestParameters : NSObject

@property (nonatomic, strong) NSNumber *limit;
@property (nonatomic, strong) NSDate *deleted_since;
@property (nonatomic, strong) NSNumber *include_trashed;
@property (nonatomic, strong) NSString *group_id;
/**
   This method convers parameters defined in the request parameter objects into a
   string-key/value based map - for use as query parameters in API calls.

   NOTE: this method will return limit as a parameter.
 */
- (NSDictionary *)valueStringDictionary;

/**
   As above, this method returns a map of string-key objects and non-nil values to be used
   as query parameters in API calls.
   NOTE: this method will NOT contain limit as a parameter
 */
- (NSDictionary *)valueStringDictionaryWithNoLimit;

/**
   checks if a property with the provided name exists in the MendeleyQueryRequestParameters object
   and the subclass calling it
   @param propertyName
 */
- (BOOL)hasQueryParameterWithName:(NSString *)queryParameterName;
@end

@interface MendeleyDocumentParameters : MendeleyQueryRequestParameters
@property (nonatomic, strong) NSDate *modified_since;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *order;
@property (nonatomic, strong) NSNumber *reverse;
@property (nonatomic, strong) NSString *view;
@end

@interface MendeleyFileParameters : MendeleyQueryRequestParameters
@property (nonatomic, strong) NSDate *added_since;
@property (nonatomic, strong) NSString *document_id;
@end

@interface MendeleyFolderParameters : MendeleyQueryRequestParameters
@property (nonatomic, strong) NSString *profile_id;
@end

@interface MendeleyAnnotationParameters : MendeleyQueryRequestParameters
@property (nonatomic, strong) NSString *document_id;
@property (nonatomic, strong) NSString *profile_id;
@property (nonatomic, strong) NSDate *modified_since;
@end

@interface MendeleyMetadataParameters : MendeleyQueryRequestParameters
@property (nonatomic, strong) NSString *arxiv;
@property (nonatomic, strong) NSString *doi;
@property (nonatomic, strong) NSString *pmid;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *filehash;
@property (nonatomic, strong) NSString *authors;
@property (nonatomic, strong) NSString *year;
@property (nonatomic, strong) NSString *source;
@end


@interface MendeleyCatalogParameters : MendeleyQueryRequestParameters
@property (nonatomic, strong) NSString *arxiv;
@property (nonatomic, strong) NSString *doi;
@property (nonatomic, strong) NSString *isbn;
@property (nonatomic, strong) NSString *issn;
@property (nonatomic, strong) NSString *pmid;
@property (nonatomic, strong) NSString *scopus;
@property (nonatomic, strong) NSString *filehash;
@property (nonatomic, strong) NSString *view;
@end

@interface MendeleyGroupParameters : MendeleyQueryRequestParameters
@end

@interface MendeleyRecentlyReadParameters : MendeleyQueryRequestParameters
@end
