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

#import "MendeleyPerformanceMeter.h"
#import "MendeleyTimer.h"
#import "MendeleyPerformanceMeterSession.h"


#define kSpareTimersSessionName @"Single Job Session"

@interface MendeleyPerformanceMeter ()

@property (nonatomic, strong) NSMutableDictionary *onGoingSessions;
@property (nonatomic, strong) dispatch_queue_t benchmarkQueue;

@end

@implementation MendeleyPerformanceMeter

- (instancetype)init
{
    self = [super init];
    if (self != nil)
    {
        _configuration = kMendeleyPerformanceMeterConfigurationDeactivated;
        _onGoingSessions = [NSMutableDictionary dictionary];
        MendeleyPerformanceMeterSession *spareTimersSession = [MendeleyPerformanceMeterSession sessionWithName:kSpareTimersSessionName];
        [_onGoingSessions addEntriesFromDictionary:@{ kSpareTimersSessionName: spareTimersSession }];
        _benchmarkQueue = dispatch_queue_create("com.mendeley.performance", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

+ (MendeleyPerformanceMeter *)sharedMeter
{
    static MendeleyPerformanceMeter *sharedMyManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
                      sharedMyManager = [[self alloc] init];
                  });
    return sharedMyManager;
}

- (NSString *)createSimpleTimerWithName:(NSString *)timerName
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        return [self addTimerWithName:timerName ToSession:kSpareTimersSessionName];
    }
    else
    {
        return nil;
    }
}

- (void)startSimpleTimerWithID:(NSString *)timerID
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        [self startTimerWithID:timerID inSession:kSpareTimersSessionName];
    }
}

- (NSString *)stopAndSaveSimpleTimerWithID:(NSString *)timerID
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        [self stopTimerWithID:timerID inSession:kSpareTimersSessionName];
        NSDictionary *timerReport =  [self reportForTimerWithID:timerID];
        if (self.configuration == kMendeleyPerformanceMeterConfigurationConsoleAndDiskReport)
        {
            NSString *filePath = [self getFullPerformanceReportPath];

            [self saveDictionary:timerReport InAFileAsynchronously:filePath];
            return filePath;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

- (NSDictionary *)reportForTimerWithID:(NSString *)timerID
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        return [self reportForTimerWithID:timerID inSession:kSpareTimersSessionName];
    }
    else
    {
        return nil;
    }
}

- (NSString *)createNewSessionWithName:(NSString *)sessionName
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        MendeleyPerformanceMeterSession *aSession = [MendeleyPerformanceMeterSession sessionWithName:sessionName];

        [self.onGoingSessions addEntriesFromDictionary:@{ aSession.sessionID: aSession }];
        return aSession.sessionID;
    }
    else
    {
        return nil;
    }
}

- (NSString *)addTimerWithName:(NSString *)timerName ToSession:(NSString *)sessionID
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        if (self.onGoingSessions[sessionID])
        {
            return [(MendeleyPerformanceMeterSession *) self.onGoingSessions[sessionID] createTimerWithName : timerName];
        }
        else
        {
            MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelError, @"No session with ID %@ found", sessionID);
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

- (void)startTimerWithID:(NSString *)timerID inSession:(NSString *)sessionID
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        if (self.onGoingSessions[sessionID])
        {
            [(MendeleyPerformanceMeterSession *) self.onGoingSessions[sessionID] startTimerWithID : timerID];
        }
        else
        {
            MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelError, @"No session with ID %@ found", sessionID);
        }
    }
}

- (void)stopTimerWithID:(NSString *)timerID inSession:(NSString *)sessionID
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        if (self.onGoingSessions[sessionID])
        {
            [(MendeleyPerformanceMeterSession *) self.onGoingSessions[sessionID] stopTimerWithID : timerID];
        }
        else
        {
            MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelError, @"No session with ID %@ found", sessionID);
        }
    }
}

- (NSDictionary *)reportForTimerWithID:(NSString *)timerID inSession:(NSString *)sessionID
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        if (self.onGoingSessions[sessionID])
        {
            return [(MendeleyPerformanceMeterSession *) self.onGoingSessions[sessionID] reportWithTimerID : timerID];
        }
        else
        {
            MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelError, @"No session with ID %@ found", sessionID);
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

- (NSString *)saveReportAndFinalizeSession:(NSString *)sessionID
{
    if (self.configuration != kMendeleyPerformanceMeterConfigurationDeactivated)
    {
        if (self.onGoingSessions[sessionID])
        {
            NSDictionary *sessionReport = [(MendeleyPerformanceMeterSession *) self.onGoingSessions[sessionID] finishSessionAndGetResults];

            [self.onGoingSessions removeObjectForKey:sessionID];

            if (self.configuration == kMendeleyPerformanceMeterConfigurationConsoleAndDiskReport)
            {
                NSString *filePath = [self getFullPerformanceReportPath];
                [self saveDictionary:sessionReport InAFileAsynchronously:filePath];
                return filePath;
            }
            else
            {
                return nil;
            }
        }
        else
        {
            MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelError, @"No session with ID %@ found", sessionID);
            return nil;
        }
    }
    else
    {
        return nil;
    }

}

- (void)saveDictionary:(NSDictionary *)dataDictionary InAFileAsynchronously:(NSString *)path
{
    dispatch_async(self.benchmarkQueue, ^{
                       if (![dataDictionary writeToFile:path
                                             atomically:YES])
                       {
                           MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelError, @"Failed to write performance report file.  No new file created");
                       }
                   });

}

- (NSString *)getFullPerformanceReportPath
{
    NSMutableString *path = [NSMutableString stringWithFormat:@"%@_%@", [self getPerformanceReportPathPrefix], [NSDate date]];
    int lastPathComponentStartingIndex = (int) ([path rangeOfString:@"/" options:NSBackwardsSearch].location);

    [path replaceOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(lastPathComponentStartingIndex, [path length] - lastPathComponentStartingIndex)];
    return path;
}

- (NSString *)getPerformanceReportPathPrefix
{
    NSMutableString *fileName = [NSMutableString stringWithString:kMendeleyPerformanceReportFileNamePrefix];

    [fileName replaceOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [fileName length])];
    return [[self getPerformanceFilesPath] stringByAppendingPathComponent:fileName];
}

- (NSString *)getPerformanceFilesPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    BOOL isDir = NO;

    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory isDirectory:&isDir])
    {
        if (!isDir)
        {
            MendeleyLogMessage(kMendeleyLogDomain, kSDKLogLevelError, @"Directory doesn't exist");
        }
        else
        {
            MendeleyLogMessage(kMendeleyLogDomain, kSDKLogLevelError, @"File path doesn't exist");
        }
        return NSTemporaryDirectory();
    }
    else
    {
        return documentsDirectory;
    }
}

- (void)cleanUpPerformancesReportFiles
{
    NSString *folderPath = [self getPerformanceFilesPath];
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath
                                                                         error:nil];
    NSMutableString *fileName = [NSMutableString stringWithString:kMendeleyPerformanceReportFileNamePrefix];

    [fileName replaceOccurrencesOfString:@" " withString:@"_"
                                 options:NSCaseInsensitiveSearch
                                   range:NSMakeRange(0, [fileName length])];
    NSArray *filesWithSelectedPrefix = [files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH[cd] %@", fileName]];
    for (NSString *reportFile in filesWithSelectedPrefix)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:reportFile]
                                                   error:&error];
        if (error)
        {
            MendeleyLogMessageWithError(kMendeleyPerformanceDomain, error);
        }
    }
}

@end
