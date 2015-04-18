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

@interface MendeleyFile : MendeleyObject
@property (nonatomic, strong) NSString *file_name;
@property (nonatomic, strong) NSString *mime_type;
@property (nonatomic, strong) NSString *document_id;
@property (nonatomic, strong) NSString *filehash;
@property (nonatomic, strong) NSString *catalog_id;
@property (nonatomic, strong) NSNumber *size;
@end

@interface MendeleyRecentlyRead : MendeleyObject
@property (nonatomic, strong) NSString *file_id;
@property (nonatomic, strong) NSNumber *page;
@property (nonatomic, strong) NSNumber *vertical_position;
@property (nonatomic, strong) NSDate *date;
@end
