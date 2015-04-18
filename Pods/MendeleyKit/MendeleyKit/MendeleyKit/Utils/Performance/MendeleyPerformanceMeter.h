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

typedef NS_ENUM (int, MendeleyPerformanceMeterConfiguration)
{
    kMendeleyPerformanceMeterConfigurationDeactivated = 0,
    kMendeleyPerformanceMeterConfigurationConsoleOnly,
    kMendeleyPerformanceMeterConfigurationConsoleAndDiskReport
};


@interface MendeleyPerformanceMeter : NSObject

@property (nonatomic, assign) MendeleyPerformanceMeterConfiguration configuration;

/**
 @return a singleton performance metre object
 */
+ (MendeleyPerformanceMeter *)sharedMeter;

/**
 creates a simple timer 
 @param timerName
 @return string with timerID
 */
- (NSString *)createSimpleTimerWithName:(NSString *)timerName;

/**
 starts the simple timer with timerID
 */
- (void)startSimpleTimerWithID:(NSString *)timerID;

/**
 stops and saves the time for timer with ID
 @param timerID
 @return string ??
 */
- (NSString *)stopAndSaveSimpleTimerWithID:(NSString *)timerID;

/**
 creates a new session with name
 @param sessionName
 @return session ID
 */
- (NSString *)createNewSessionWithName:(NSString *)sessionName;

/**
 adds a timer to a session with given ID
 @param timerName
 @param sessionID
 @return string timerID
 */
- (NSString *)addTimerWithName:(NSString *)timerName ToSession:(NSString *)sessionID;

/**
 starts the timer with timer/session ID
 @param timerID
 @param sessionID
 */
- (void)startTimerWithID:(NSString *)timerID inSession:(NSString *)sessionID;

/**
 stops the timer for timer/session ID
 @param timerID
 @param sessionID
 */
- (void)stopTimerWithID:(NSString *)timerID inSession:(NSString *)sessionID;

/**
 saves the timing report for a given session
 @param sessionID
 @return path to file saved
 */
- (NSString *)saveReportAndFinalizeSession:(NSString *)sessionID;

/**
 removes all performance measurement files
 */
- (void)cleanUpPerformancesReportFiles;

@end