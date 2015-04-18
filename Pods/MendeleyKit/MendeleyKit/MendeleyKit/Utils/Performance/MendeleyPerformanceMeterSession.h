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
#import "MendeleyTimer.h"

@interface MendeleyPerformanceMeterSession : NSObject

@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) NSString *name;

/**
 returns a performance meter session with given name
 @param sessionName
 */
+ (MendeleyPerformanceMeterSession *)sessionWithName:(NSString *)sessionName;

/**
 creates a timer with a gien name
 @param timerName
 @return timer Id
 */
- (NSString *)createTimerWithName:(NSString *)timerName;

/**
 @param timerID
 */
- (void)startTimerWithID:(NSString *)timerID;

/**
 @param timerID
 */
- (void)stopTimerWithID:(NSString *)timerID;

/**
 returns a report for a given timerID as dictionary
 @param timerID
 */
- (NSDictionary *)reportWithTimerID:(NSString *)timerID;

/**
 returns the results for a session as dictionary
 */
- (NSDictionary *)finishSessionAndGetResults;

@end
