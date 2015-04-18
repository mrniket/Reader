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

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif


@interface MendeleyAnnotation : MendeleyObject
@property (nonatomic, strong) NSDate *created;

#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIColor *color;
#else
@property (nonatomic, strong) NSColor *color;
#endif

@property (nonatomic, strong) NSString *document_id;
@property (nonatomic, strong) NSString *filehash;
@property (nonatomic, strong) NSDate *last_modified;
@property (nonatomic, strong) NSArray *positions;
@property (nonatomic, strong) NSString *privacy_level;
@property (nonatomic, strong) NSString *profile_id;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *type;

/**
   Annotations have color components, which are stored as map<string, integer>, where string is
   either r,g,b
   This method converts the color JSON map into a UIColor object (iOS) or NSColor object (Mac OSX)
   @param colorParameters
   @param error
   @return a UIColor/NSColor object or nil if error
 */
+ (id)colorFromParameters:(NSDictionary *)colorParameters error:(NSError **)error;

/**
   converts a color object (UIColor/NSColor) back into JSON
   @param color
   @param error
   @return JSON map of color components
 */
+ (NSDictionary *)jsonColorFromColor:(id)color error:(NSError **)error;
@end


@interface MendeleyHighlightBox : MendeleySecureObject
@property (nonatomic, assign) CGRect box;
@property (nonatomic, strong) NSNumber *page;

/**
   Annotations store position details as a map with parameters such as top_left etc.
   This converts a JSON map containing position metadata into a MendeleyHighlightBox object
   @param boxParameters
   @param error
   @return a highlight box object
 */
+ (MendeleyHighlightBox *)boxFromJSONParameters:(NSDictionary *)boxParameters error:(NSError **)error;

/**
   converts a highlight box object back into a NSDictionary (JSON map)
   @param box
   @param error
   @return a map to be used in JSON
 */
+ (NSDictionary *)jsonBoxFromHighlightBox:(MendeleyHighlightBox *)box error:(NSError **)error;
@end

