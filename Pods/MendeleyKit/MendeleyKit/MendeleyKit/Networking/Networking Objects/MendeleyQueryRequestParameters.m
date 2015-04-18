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

#import "MendeleyQueryRequestParameters.h"
#import "MendeleyURLBuilder.h"
#import "MendeleyModels.h"
#import "MendeleyObjectHelper.h"
#import "MendeleyKitConfiguration.h"

@implementation MendeleyQueryRequestParameters

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _limit = [NSNumber numberWithInt:kMendeleyRESTAPIDefaultPageSize];
    }
    return self;
}

- (NSDictionary *)valueStringDictionary
{
    NSDictionary *dictionary = [MendeleyObjectHelper propertiesAndAttributesForModel:self];

    __block NSMutableDictionary *values = [NSMutableDictionary dictionary];

    [dictionary enumerateKeysAndObjectsUsingBlock: ^(NSString *propertyName, NSString *attribute, BOOL *stop) {
         id value = [self valueForKey:propertyName];
         NSString *valueString = [self valueStringForProperty:propertyName value:value];
         if (nil != valueString)
         {
             [values setValue:valueString forKey:propertyName];
         }
     }];

    return values;
}

- (NSDictionary *)valueStringDictionaryWithNoLimit
{
    NSDictionary *dictionary = [MendeleyObjectHelper propertiesAndAttributesForModel:self];

    __block NSMutableDictionary *values = [NSMutableDictionary dictionary];

    [dictionary enumerateKeysAndObjectsUsingBlock: ^(NSString *propertyName, NSString *attribute, BOOL *stop) {
         id value = [self valueForKey:propertyName];
         NSString *valueString = [self valueStringForProperty:propertyName value:value];
         if (nil != valueString && ![propertyName isEqualToString:kMendeleyRESTAPIQueryLimit])
         {
             [values setValue:valueString forKey:propertyName];
         }
     }];

    return values;
}

- (BOOL)hasQueryParameterWithName:(NSString *)queryParameterName
{
    NSArray *propertyNames = [MendeleyObjectHelper propertyNamesForModel:self];

    if (nil == propertyNames || 0 == propertyNames.count)
    {
        return NO;
    }
    return [propertyNames containsObject:queryParameterName];
}


- (NSString *)valueStringForProperty:(NSString *)property value:(id)value
{
    if (nil == value || nil == property)
    {
        return nil;
    }
    NSString *valueString = nil;
    if ([value isKindOfClass:[NSDate class]])
    {
        valueString = [self dateValueStringForPropertyWithName:property date:(NSDate *) value];
    }
    else if ([value isKindOfClass:[NSNumber class]])
    {
        if ([property isEqualToString:kMendeleyRESTAPIQueryReverse] || [property isEqualToString:kMendeleyRESTAPIQueryIncludeTrashed])
        {
            valueString = ([(NSNumber *) value boolValue]) ? @"true" : @"false";
        }
        else
        {
            valueString = [NSString stringWithFormat:@"%d", [(NSNumber *) value intValue]];
        }
    }
    else if ([value isKindOfClass:[NSString class]])
    {
        valueString = (NSString *) value;
    }
    if (nil != valueString && 0 == valueString.length)
    {
        valueString = nil;
    }
    return valueString;
}

- (void)addValue:(NSString *)value key:(NSString *)key mutableDictionary:(NSMutableDictionary *)mutableDictionary
{
    if (nil == value || 0 == value.length || nil == mutableDictionary)
    {
        return;
    }

    [mutableDictionary setValue:value forKey:key];
}

- (NSString *)dateValueStringForPropertyWithName:(NSString *)propertyName date:(NSDate *)date
{
    if (nil == propertyName || nil == date)
    {
        return nil;
    }
    NSDateFormatter *isoFormatter = [MendeleyObjectHelper jsonDateFormatter];
    return [isoFormatter stringFromDate:date];
}

- (void)setLimit:(NSNumber *)limitValue
{
    if (nil == limitValue || 0 >= [limitValue intValue])
    {
        _limit = [NSNumber numberWithInt:kMendeleyRESTAPIDefaultPageSize];
    }
    else if (kMendeleyRESTAPIMaxPageSize < [limitValue intValue])
    {
        _limit = [NSNumber numberWithInt:kMendeleyRESTAPIMaxPageSize];
    }
    else
    {
        _limit = limitValue;
    }
}

- (NSNumber *)limitValue
{
    if (nil == _limit || 0 >= [_limit intValue])
    {
        return [NSNumber numberWithInt:kMendeleyRESTAPIDefaultPageSize];
    }
    else if (kMendeleyRESTAPIMaxPageSize < [_limit intValue])
    {
        return [NSNumber numberWithInt:kMendeleyRESTAPIMaxPageSize];
    }
    return _limit;
}

@end

@implementation MendeleyDocumentParameters

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _reverse = nil;
        _sort = nil;
        _order = nil;
        NSString *viewType = [[MendeleyKitConfiguration sharedInstance] documentViewType];
        _view = viewType.length == 0 ? nil : viewType;
    }
    return self;
}

- (void)setSort:(NSString *)sortValue
{
    if (nil == sortValue)
    {
        return;
    }
    if ([sortValue isEqualToString:kMendeleyRESTAPIQuerySortAsc] ||
        [sortValue isEqualToString:kMendeleyRESTAPIQuerySortDesc])
    {
        _sort = sortValue;
    }
    else
    {
        _sort = nil;
    }
}

- (void)setOrder:(NSString *)orderValue
{
    if (nil == orderValue)
    {
        return;
    }
    if ([orderValue isEqualToString:kMendeleyRESTAPIQueryOrderByCreated] || [orderValue isEqualToString:kMendeleyRESTAPIQueryOrderByTitle])
    {
        _order = orderValue;
    }
    else
    {
        _order = nil;
    }
}

- (void)setView:(NSString *)viewType
{
    if ([viewType isEqualToString:kMendeleyDocumentViewTypeBibliography] ||
        [viewType isEqualToString:kMendeleyDocumentViewTypeClient] ||
        [viewType isEqualToString:kMendeleyDocumentViewTypeTags] ||
        [viewType isEqualToString:kMendeleyDocumentViewTypeAll])
    {
        _view = viewType;
    }
    else
    {
        _view = nil;
    }
}
@end


@implementation MendeleyFileParameters
@end

@implementation MendeleyFolderParameters
@end

@implementation MendeleyAnnotationParameters
@end

@implementation MendeleyGroupParameters
@end

@implementation MendeleyMetadataParameters
@end

@implementation MendeleyCatalogParameters
- (id)init
{
    self = [super init];
    if (nil != self)
    {
        NSString *viewType = [[MendeleyKitConfiguration sharedInstance] documentViewType];
        _view = viewType.length == 0 ? nil : viewType;
    }
    return self;
}
@end

@implementation MendeleyRecentlyReadParameters
@end
