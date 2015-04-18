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
#import "MendeleyObject.h"
#import "MendeleyDocumentType.h"

@interface MendeleyDocument : MendeleyObject
/**
   NSNumber types (integer)
 */
@property (nonatomic, strong) NSNumber *month;
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) NSNumber *day;

/**
   NSNumber types (boolean)
 */
@property (nonatomic, strong) NSNumber *file_attached;
@property (nonatomic, strong) NSNumber *read;
@property (nonatomic, strong) NSNumber *starred;
@property (nonatomic, strong) NSNumber *authored;
@property (nonatomic, strong) NSNumber *confirmed;
@property (nonatomic, strong) NSNumber *hidden;

/**
   NSArray types
 */
@property (nonatomic, strong) NSArray *authors;
@property (nonatomic, strong) NSArray *editors;
@property (nonatomic, strong) NSArray *translators;
@property (nonatomic, strong) NSArray *websites;
@property (nonatomic, strong) NSArray *keywords;
@property (nonatomic, strong) NSArray *tags;

/**
   NSDictionary type (Identifiers, e.g. arxiv)
 */
@property (nonatomic, strong) NSDictionary *identifiers;

/**
   NSDate types (stringDate)
 */
@property (nonatomic, strong) NSDate *last_modified;
@property (nonatomic, strong) NSDate *created;

/**
   NSString types (string)
 */
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *group_id;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *revision;
@property (nonatomic, strong) NSString *abstract;
@property (nonatomic, strong) NSString *profile_id;
@property (nonatomic, strong) NSString *pages;
@property (nonatomic, strong) NSString *volume;
@property (nonatomic, strong) NSString *issue;
@property (nonatomic, strong) NSString *publisher;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *edition;
@property (nonatomic, strong) NSString *institution;
@property (nonatomic, strong) NSString *series;
@property (nonatomic, strong) NSString *chapter;
@property (nonatomic, strong) NSString *accessed;

@property (nonatomic, strong) NSString *citation_key;
@property (nonatomic, strong) NSString *source_type;
@property (nonatomic, strong) NSString *language;
@property (nonatomic, strong) NSString *short_title;
@property (nonatomic, strong) NSString *reprint_edition;
@property (nonatomic, strong) NSString *genre;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *series_editor;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *medium;
@property (nonatomic, strong) NSString *user_context;
@property (nonatomic, strong) NSString *department;
@property (nonatomic, strong) NSString *patent_owner;
@property (nonatomic, strong) NSString *patent_application_number;
@property (nonatomic, strong) NSString *patent_legal_status;

@end


