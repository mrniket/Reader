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

#import "NSMutableArray+MaximumSize.h"

@implementation NSMutableArray (MaximumSize)

- (void)addObject:(id)object maximumArraySize:(NSUInteger)maximumSize
{
    if ([self count] < maximumSize)
    {
        [self addObject:object];
    }
    else
    {
        // Will remove first object and insert last object at the back.
        [self removeObjectAtIndex:0];
        [self addObject:object];
    }
}

- (void)addObjectsFromArray:(NSArray *)objects maximumArraySize:(NSUInteger)maximumSize
{
    if ([self count] + [objects count] < maximumSize)
    {
        [self addObjectsFromArray:objects];
    }
    else
    {
        // need to remove objects at the front.
        NSUInteger itemsToBeRemoved = [objects count] + [self count] - (maximumSize + 1);
        [self removeObjectsInRange:NSMakeRange(0, itemsToBeRemoved)];
        [self addObjectsFromArray:objects];
    }
}

@end
