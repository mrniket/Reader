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

// inspirations and references:
// https://developer.apple.com/library/mac/qa/qa1398/_index.html
// http://www.objective-brian.com/334


#import <Foundation/Foundation.h>

@interface MendeleyTimer : NSObject

@property (nonatomic, strong) NSString *timerID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *absoluteStartTime;

/**
 Starts or restarts the timer.
 */
- (void)start;

/**
 Captures the timer.
 */
- (void)stop;

/**
 Returns the elapsed time in nanoseconds of the last capture.
 */
- (UInt64)nsElapsed;

/**
 Returns the elapsed time in milliseconds of the last capture.
 */
- (UInt32)msElapsed;

/**
 Returns a string containing a representation of the elapsed time.
 */
- (NSString *)stringWithElapsedTime;

/**
 returns a timer for a given name
 @param name
 @return the MendeleyTimer object if found
 */
+ (MendeleyTimer *)timerWithName:(NSString *)name;

/**
 invalidates the timer
 */
- (void)invalidate;
@end
