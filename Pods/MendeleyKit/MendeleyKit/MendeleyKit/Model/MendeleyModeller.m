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

#import "MendeleyModeller.h"
#import "MendeleyOAuthCredentials.h"
#import "MendeleyObjectHelper.h"
#import "NSError+MendeleyError.h"
#import "MendeleyModels.h"
#import "MendeleyObject.h"

@implementation MendeleyModeller

#pragma mark public modeller methods
+ (MendeleyModeller *)sharedInstance
{
    static MendeleyModeller *modeller = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
                      modeller = [[MendeleyModeller alloc] init];
                  });
    return modeller;
}

- (void)parseJSONData:(id)jsonData
         expectedType:(NSString *)expectedType
      completionBlock:(void (^) (id parsedObject, NSError *error))completionBlock
{
    NSError *parseError = nil;

    if ([jsonData isKindOfClass:[NSArray class]])
    {
        NSArray *models = [self objectArrayFromJSONArray:(NSArray *) jsonData
                                            expectedType:expectedType
                                                   error:&parseError];
        completionBlock(models, parseError);
    }
    else if ([jsonData isKindOfClass:[NSDictionary class]])
    {
        id model = [self objectModelFromJSONDictionary:(NSDictionary *) jsonData
                                          expectedType:expectedType
                                                 error:&parseError];
        completionBlock(model, parseError);
    }
    else
    {
        NSError *error = [NSError errorWithCode:kMendeleyJSONTypeUnrecognisedErrorCode];
        completionBlock(nil, error);
    }
}

- (NSData *)jsonObjectFromModelOrModels:(id)model error:(NSError **)error
{
    if ([model isKindOfClass:[NSArray class]])
    {
        return [self jsonArrayFromObjects:(NSArray *) model error:error];
    }
    else if ([model isKindOfClass:[MendeleyObject class]] || [model isKindOfClass:[MendeleySecureObject class]])
    {
        return [self jsonDictionaryFromModel:model error:error];
    }

    if (NULL != error)
    {
        *error = [NSError errorWithCode:kMendeleyJSONTypeNotMappedToModelErrorCode];
    }
    return nil;
}

- (void)parseJSONArrayOfIDDictionaries:(NSArray *)jsonArray
                       completionBlock:(MendeleyStringArrayCompletionBlock)completionBlock
{
    if (nil == jsonArray)
    {
        if (nil != completionBlock)
        {
            NSError *error = [NSError errorWithCode:kMendeleyJSONTypeObjectNilErrorCode];
            completionBlock(nil, error);
            return;
        }
    }
    __block NSMutableArray *array = [NSMutableArray array];
    [jsonArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[NSDictionary class]])
         {
             NSDictionary *dictionary = (NSDictionary *) obj;
             NSString *idString = [dictionary objectForKey:kMendeleyJSONID];
             if (nil != idString)
             {
                 [array addObject:idString];
             }
         }
     }];


    if (nil != completionBlock)
    {
        completionBlock(array, nil);
    }
}

- (NSData *)jsonObjectForID:(NSString *)objectID error:(NSError *__autoreleasing *)error
{
    if (nil == objectID || 0 == objectID.length)
    {
        if (NULL != *error)
        {
            *error = [NSError errorWithCode:kMendeleyJSONTypeObjectNilErrorCode];
        }
        return nil;
    }
    NSDictionary *dictionary = @{ kMendeleyJSONID: objectID };
    return [NSJSONSerialization dataWithJSONObject:dictionary
                                           options:NSJSONWritingPrettyPrinted
                                             error:error];
}

#pragma mark serializing to JSON methods
- (NSData *)jsonArrayFromObjects:(NSArray *)objects error:(NSError **)error
{
    NSArray *serializedData = [self arrayFromModelArray:objects error:error];

    if (nil != serializedData)
    {
        return [NSJSONSerialization dataWithJSONObject:serializedData
                                               options:NSJSONWritingPrettyPrinted
                                                 error:error];
    }
    return nil;
}

- (NSData *)jsonDictionaryFromModel:(id)model error:(NSError **)error
{
    NSDictionary *jsonDictionary = [self dictionaryFromModel:model error:error];

    if (nil != jsonDictionary)
    {
        return [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                               options:NSJSONWritingPrettyPrinted
                                                 error:error];
    }
    else
    {
        return nil;
    }
}

- (NSDictionary *)dictionaryFromModel:(id)model error:(NSError **)error
{
    __block NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    NSArray *propertyNames = [MendeleyObjectHelper propertyNamesForModel:model];

    [propertyNames enumerateObjectsUsingBlock: ^(NSString *name, NSUInteger idx, BOOL *stop) {
         id value = [model valueForKey:name];
         if (nil != value)
         {
             NSString *matchedName = [MendeleyObjectHelper matchedJSONKeyForKey:name];
             if ([MendeleyObjectHelper isCustomizableModelObject:model forPropertyName:name error:error])
             {
                 [properties setObject:[MendeleyObjectHelper rawValueFromCustomObject:value modelObject:model propertyName:name error:error] forKey:matchedName];
             }

             else if ([value isKindOfClass:[NSDate class]])
             {
                 NSString *stringValue = [[MendeleyObjectHelper jsonDateFormatter] stringFromDate:(NSDate *) value];
                 [properties setObject:stringValue forKey:matchedName];
             }
             else if ([value isKindOfClass:[NSArray class]])
             {
                 NSArray *arrayValue = [self arrayFromModelArray:value error:error];
                 if (nil != arrayValue)
                 {
                     [properties setObject:arrayValue forKey:matchedName];
                 }
             }
             else
             {
                 [properties setObject:value forKey:matchedName];
             }
         }
     }];
    return properties;
}

- (NSArray *)arrayFromModelArray:(NSArray *)modelArray error:(NSError **)error
{
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:modelArray.count];

    [modelArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
         if ([obj isKindOfClass:[MendeleyObject class]])
         {
             NSDictionary *dictionary = [self dictionaryFromModel:obj error:error];
             if (nil != dictionary)
             {
                 [array addObject:dictionary];
             }
         }
         else if ([obj isKindOfClass:[NSArray class]])
         {
             NSArray *subArray = [self arrayFromModelArray:obj error:error];
             [array addObject:subArray];
         }
         else
         {
             [array addObject:obj];
         }
     }];
    return array;
}

#pragma mark deserializing from JSON methods

- (NSArray *)objectArrayFromJSONArray:(NSArray *)jsonArray
                         expectedType:(NSString *)expectedType
                                error:(NSError **)error
{
    if (nil == jsonArray || nil == expectedType)
    {
        if (NULL != error)
        {
            *error = [NSError errorWithCode:kMendeleyJSONTypeObjectNilErrorCode];
        }
        return nil;
    }

    if ([expectedType isEqualToString:@"NSArray"])
    {
        return jsonArray;
    }
    NSMutableArray *objects = [NSMutableArray array];

    [jsonArray enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[NSDictionary class]])
         {
             id model = [self objectModelFromJSONDictionary:(NSDictionary *) obj expectedType:expectedType error:error];
             if (nil != model)
             {
                 [objects addObject:model];
             }
         }
         else if ([obj isKindOfClass:[NSArray class]])
         {
             NSArray *modelArray = [self objectArrayFromJSONArray:(NSArray *) obj expectedType:expectedType error:error];
             if (nil != modelArray)
             {
                 [objects addObject:modelArray];
             }
         }
     }];
    return objects;
}

- (id)objectModelFromJSONDictionary:(NSDictionary *)jsonDictionary
                       expectedType:(NSString *)expectedType
                              error:(NSError **)error
{
    if (nil == jsonDictionary || nil == expectedType)
    {
        if (NULL != error)
        {
            *error = [NSError errorWithCode:kMendeleyJSONTypeObjectNilErrorCode];
        }
        return nil;
    }

    id modelObject = [MendeleyObjectHelper modelFromClassName:expectedType error:error];

    if (nil == modelObject)
    {
        return nil;
    }

    NSDictionary *modelAttributes = [MendeleyObjectHelper propertiesAndAttributesForModel:modelObject];

    [jsonDictionary enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
         if ([key isKindOfClass:[NSString class]])
         {
             NSString *matchedKey = [MendeleyObjectHelper matchedKeyForJSONKey:(NSString *) key];
             id valueToBeAdded = nil;
             if ([MendeleyObjectHelper isCustomizableModelObject:modelObject forPropertyName:key error:error])
             {
                 valueToBeAdded = [MendeleyObjectHelper customObjectFromRawValue:obj modelObject:modelObject propertyName:key error:error];
             }
             else if ([obj isKindOfClass:[NSArray class]])
             {
                 NSString *type = [[MendeleyObjectHelper arrayToModelDictionary] objectForKey:matchedKey];
                 if (nil != type)
                 {
                     NSError *parseError = nil;
                     NSArray *objects = [self objectArrayFromJSONArray:(NSArray *) obj expectedType:type error:&parseError];
                     if (nil == parseError)
                     {
                         valueToBeAdded = objects;
                     }
                 }
             }

             else
             {
                 valueToBeAdded = obj;
             }
             BOOL propertyExists = [modelAttributes.allKeys containsObject:matchedKey];
             if (nil != valueToBeAdded && propertyExists)
             {
                 NSString *attribute = [modelAttributes objectForKey:matchedKey];
                 if ([attribute rangeOfString:@"NSDate"].location != NSNotFound)
                 {
                     NSString *dateString = (NSString *) valueToBeAdded;
                     NSDate *date = [[MendeleyObjectHelper jsonDateFormatter] dateFromString:dateString];
                     [modelObject setValue:date forKey:matchedKey];
                 }
                 else
                 {
                     [modelObject setValue:valueToBeAdded forKey:matchedKey];
                 }
             }
         }
     }];
    return modelObject;
}

@end
