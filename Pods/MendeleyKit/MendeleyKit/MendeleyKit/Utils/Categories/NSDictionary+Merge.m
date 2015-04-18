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

#import "NSDictionary+Merge.h"

@implementation NSDictionary (Merge)

+ (NSDictionary *)dictionaryByMerging:(NSDictionary *)dict1 with:(NSDictionary *)dict2
{
    if (nil == dict1)
    {
        return dict2;
    }

    if (nil == dict2)
    {
        return dict1;
    }

    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dict1];

    [dict2 enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
         if (![dict1 objectForKey:key])
         {
             if ([obj isKindOfClass:[NSDictionary class]])
             {
                 NSDictionary *newVal = [[dict1 objectForKey:key] dictionaryByMergingWith:(NSDictionary *) obj];
                 [result setObject:newVal forKey:key];
             }
             else
             {
                 [result setObject:obj forKey:key];
             }
         }
     }];

    return (NSDictionary *) [result mutableCopy];
}
- (NSDictionary *)dictionaryByMergingWith:(NSDictionary *)dict
{
    return [[self class] dictionaryByMerging:self with:dict];
}

@end
