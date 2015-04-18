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

#import "MendeleyObject.h"

@interface MendeleyCatalogDocument : MendeleyObject
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSNumber *reader_count;
@property (nonatomic, strong) NSDictionary *reader_count_by_academic_status;
@property (nonatomic, strong) NSDictionary *reader_count_by_subdiscipline;
@property (nonatomic, strong) NSDictionary *reader_count_by_country;
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

/**
   NSArray types (Person)
 */
@property (nonatomic, strong) NSArray *authors;
@property (nonatomic, strong) NSArray *editors;
@property (nonatomic, strong) NSArray *websites;
@property (nonatomic, strong) NSArray *keywords;

/**
   NSDictionary type (Identifiers, e.g. arxiv)
 */
@property (nonatomic, strong) NSDictionary *identifiers;

/**
   NSDate types (stringDate)
 */
@property (nonatomic, strong) NSDate *created;

/**
   NSString types (string)
 */
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *revision;
@property (nonatomic, strong) NSString *abstract;
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
@end
