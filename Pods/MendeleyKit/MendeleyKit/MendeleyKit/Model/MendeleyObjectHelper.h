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

@interface MendeleyObjectHelper : NSObject

/**
   the standard JSON data type for parsing/writing JSON dates
 */
+ (NSDateFormatter *)jsonDateFormatter;

/**
   a dictionary containing a map between JSON property names and model properties where 1-2-1 isn't possible
 */
+ (NSDictionary *)jsonPropertyDictionary;

/**
   a dictionary containing a map between model property names and JSON properties where 1-2-1 isn't possible
 */
+ (NSDictionary *)modelPropertyDictionary;

/**
   this dictionary maps JSON arrays to model classes
 */
+ (NSDictionary *)arrayToModelDictionary;

/**
   @param model the model object to parse
   @return a dictionary containing the property names and their values (if nil). Maybe empty if none are found
 */
+ (NSDictionary *)propertiesAndAttributesForModel:(id)model;

/**
   @param model the model object to parse
   @return an array containing all property names (including superclass)
 */
+ (NSArray *)propertyNamesForModel:(id)model;

/**
   This method matches the JSON property name to a model class name
   In most cases this will simply return the JSON property name. In some, e.g. "id" the JSON name
   cannot be used as it would clash with Objective C keywords and types. In these cases the property names
   returned will be a match to the model class property name.
   @param key the JSON property name
   @return the matched name if found or the JSON name if not
 */
+ (NSString *)matchedKeyForJSONKey:(NSString *)key;

/**
   This method maps the model property name to a JSON property name. As in the matchedKeyForJSONKey method
   this will be mostly a one to one mapping. Where this is not possible, a proper match will be provided
   (e.g. JSON property "id" is mapped to "object_ID")
   @param key the Model class property name
   @return the matched JSON name if found or the model name if not
 */
+ (NSString *)matchedJSONKeyForKey:(NSString *)key;

/**
   creates a model instance from a class name
   @param className the name of the model class
   @param error will be nil if method call is successful
   @return an instance of the model class or nil if unsuccessful
 */
+ (id)modelFromClassName:(NSString *)className error:(NSError **)error;

/**
   Returns a Boolean value that indicates whether the receiving propertyName for a specific model object contains a custom object or not.
   @param modelObject the model object
   @param propertyName the property name
   @param error will be nill if method call is successfull
   @return YES if the propertyName of the model object contains a custom object, otherwise NO.
 */
+ (BOOL)isCustomizableModelObject:(id)modelObject
                  forPropertyName:(NSString *)propertyName
                            error:(NSError **)error;

/**
   Returns a custom initialized object corresponding to the receiving raw value for a specific model object and propertyName.
   @param rawValue the raw object to be converted
   @param modelObject the model object
   @param propertyName the property name
   @param error will be nill if method call is successfull
   @return the custom initialized value if the propertyName of the model object contains a custom object.
 */
+ (id)customObjectFromRawValue:(id)rawValue
                   modelObject:(id)modelObject
                  propertyName:(NSString *)propertyName
                         error:(NSError **)error;

/**
   Returns a raw value corresponding to the receiving custom object for a specific model object and propertyName.
   @param customObject the custom object to be converted
   @param modelObject the model object
   @param propertyName the property name
   @param error will be nill if method call is successfull
   @return the raw value if the propertyName of the model object contains a custom object.
 */
+ (id)rawValueFromCustomObject:(id)customObject
                   modelObject:(id)modelObject
                  propertyName:(NSString *)propertyName
                         error:(NSError **)error;

@end
