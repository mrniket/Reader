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

#import "MendeleyLog.h"
#import "NSMutableArray+MaximumSize.h"

#define MAX_SAVED_LOGS     1000

#pragma mark plist keys

#define entryLevelKey      @"level"
#define entryDomainKey     @"domain"
#define entryMessageKey    @"message"
#define entryDateKey       @"date"
#define entryMethodNameKey @"method"

#define rootDeviceInfoKey  @"info"
#define rootFlowKey        @"flow"
#define rootSummaryKey     @"summary"

@interface MendeleyLog ()

/// Needed for making self.errorLogs threadsafe.
@property (nonatomic, strong) dispatch_queue_t errorLogQueue;
@property (nonatomic, strong, readwrite) NSMutableArray *temporaryLogQueue;

@end

@implementation MendeleyLog

#pragma mark - Utils

+ (MendeleyLog *)sharedInstance
{
    static dispatch_once_t token = 0;
    __strong static id sharedObject = nil;

    dispatch_once(&token, ^{
                      sharedObject = [[self alloc] init];
                  });
    return sharedObject;
}

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        _errorLogQueue = dispatch_queue_create("com.mendeley.logging.errorlogs", DISPATCH_QUEUE_SERIAL);
        _temporaryLogQueue = [NSMutableArray array];
        _consoleLogFilters = [NSDictionary dictionary];
    }
    return self;
}

- (void)logMessageWithDomainString:(NSString *)domain level:(MendeleyLogLevel)level message:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
#ifdef DEBUG
    // Log in console:
    [self logMessageToConsoleWithDomainString:domain level:level message:message];
#endif
    // Log to disk:
    [self logMessageToDiskWithDomain:domain level:level message:message];
}

- (void)logMessageWithDomainString:(NSString *)domain error:(NSError *)error
{
    NSString *message = [[NSString alloc] initWithFormat:@"[ErrorCode:%i] %@: %@", (int) error.code, error.domain, error.localizedDescription];

#ifdef DEBUG
    // Log in console:
    [self logMessageToConsoleWithDomainString:domain level:kSDKLogLevelError message:message];
#endif
    // Log to disk:
    [self logMessageToDiskWithDomain:domain level:kSDKLogLevelError message:message];
}

/// Private method, called from the 'logMessage...' methods.
- (void)logMessageToDiskWithDomain:(NSString *)domain level:(MendeleyLogLevel)level message:(NSString *)message
{
    dispatch_async(self.errorLogQueue, ^{
                       NSDictionary *logEntry = [self createErrorEntryWithDomainString:domain level:level message:message];
                       // TODO: this is relatively slow, using a dictionary is much faster.
                       [self.temporaryLogQueue addObject:logEntry maximumArraySize:MAX_SAVED_LOGS];
                   });
}

/// Private method, called from the 'logMessage...' methods.
/// Will dynamically decide whether or not to print certain messages depending on the specified domain and level.
- (void)logMessageToConsoleWithDomainString:(NSString *)domain level:(MendeleyLogLevel)level message:(NSString *)message
{
    BOOL shouldPrintToConsole = YES;

    // if there is a global log limit, we check that first...
    NSNumber *globalMinimumLoggedLevel = [self.consoleLogFilters objectForKey:kMendeleyLogDomainAllDomains];

    if (globalMinimumLoggedLevel && globalMinimumLoggedLevel.integerValue > level)
    {
        shouldPrintToConsole = NO;
    }

    // ... but specifying a log level for a specific domain overwrites the global value!
    NSNumber *minimumLoggedLevel = [self.consoleLogFilters objectForKey:domain];
    if (minimumLoggedLevel)
    {
        if (minimumLoggedLevel.integerValue > level)
        {
            shouldPrintToConsole = NO;
        }
        else
        {
            // we specifically requested a lower minimum level for this domain, so the global setting is ignored!
            shouldPrintToConsole = YES;
        }
    }

    if (shouldPrintToConsole)
    {
        MLog(@"%@", [NSString stringWithFormat:@"%@: %@ - %@", [self convertLogLevelToString:level], domain, message]);
    }
}

- (NSString *)convertLogLevelToString:(MendeleyLogLevel)level
{
    switch ((int) level)
    {
        case kSDKLogLevelInfo:
            return @"INFO";
            break;

        case kSDKLogLevelWarning:
            return @"WARNING";
            break;

        case kSDKLogLevelError:
            return @"ERROR";
            break;

        case kSDKLogLevelException:
            return @"EXCEPTION";
            break;

        default:
            return @"UNKNOWN LEVEL";
            break;
    }
}

- (NSDictionary *)createErrorEntryWithDomainString:(NSString *)domain
                                             level:(MendeleyLogLevel)level
                                           message:message
{
    NSDictionary *entry = @{  entryDateKey:[NSDate date],
                              entryDomainKey : domain,
                              entryLevelKey : [self convertLogLevelToString:level],
                              entryMessageKey : message };

    return entry;
}

- (void)addFlowEntriesToPersistentLog:(NSArray *)newEntries
{
    NSMutableDictionary *plist = [self getExistingActivityLogOrCreateANewOne];
    NSMutableArray *flowArrayLogs = [plist objectForKey:rootFlowKey];

    for (NSDictionary *currentEntry in newEntries)
    {
        [flowArrayLogs addObject:currentEntry maximumArraySize:MAX_SAVED_LOGS];
    }
    [self saveActivityLogDictionary:plist];
}

- (void)addUserInfoToPersistentLog:(NSDictionary *)deviceInfoDict
{
    NSMutableDictionary *plist = [self getExistingActivityLogOrCreateANewOne];

    [plist setObject:deviceInfoDict forKey:rootDeviceInfoKey];
    [self saveActivityLogDictionary:plist];
}

- (NSMutableDictionary *)getExistingActivityLogOrCreateANewOne
{
    NSString *filePath = [self getActivityLogPath];
    NSMutableDictionary *plist;

    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        plist = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    }
    else
    {
        plist = [NSMutableDictionary dictionaryWithCapacity:1];
        NSMutableArray *emptyArray = [NSMutableArray arrayWithCapacity:0];
        [plist setObject:emptyArray forKey:rootFlowKey];
    }
    return plist;
}

- (void)saveActivityLogDictionary:(NSDictionary *)plist
{
    NSString *filePath = [self getActivityLogPath];

    if (![plist writeToFile:filePath atomically:YES])
    {
        MendeleyLogMessage(kMendeleyLogDomain, kSDKLogLevelError, @"Failed to write activity log file.  No new entry added");
    }
}

- (NSString *)getActivityLogPath
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
        return [NSTemporaryDirectory() stringByAppendingPathComponent:@"MendeleyActivityLogs.plist"];
    }
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"MendeleyActivityLogs.plist"];
    return filePath;
}

- (NSString *)getExportedLogFilePath
{
    NSString *tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"MendeleyLog.plist"]];

    return tempFilePath;
}

- (void)cleanExportedLogFile
{
    NSError *error;
    NSString *filePath = [self getExportedLogFilePath];

    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
    {
        MendeleyLogMessageWithError(kMendeleyLogDomain, error);
    }
}

- (NSURL *)createFormattedActivityLogFileAndExportURL
{
    [self writeNewErrorsLogsToDisk];

    NSMutableDictionary *plist = [self getExistingActivityLogOrCreateANewOne];

    NSMutableDictionary *summaryDict = [NSMutableDictionary dictionaryWithCapacity:kLevelsNumber];

    for (int i = 0; i < kLevelsNumber; i++)
    {
        NSMutableArray *levelFilteredArray = [[NSMutableArray alloc] initWithCapacity:0];
        NSPredicate *levelPredicate = [NSPredicate predicateWithFormat:@"%K = %@", entryLevelKey, [self convertLogLevelToString:i]];
        [levelFilteredArray addObjectsFromArray:[[plist objectForKey:rootFlowKey] filteredArrayUsingPredicate:levelPredicate]];

        NSArray *domainValues = [[NSSet setWithArray:[levelFilteredArray valueForKey:entryDomainKey]] allObjects];
        NSMutableDictionary *domainsDict = [[NSMutableDictionary alloc] initWithCapacity:[domainValues count]];

        for (NSString *domain in domainValues)
        {
            NSMutableArray *domainFilteredArray = [[NSMutableArray alloc] initWithCapacity:0];
            NSPredicate *domainPredicate = [NSPredicate predicateWithFormat:@"%K = %@", entryDomainKey, domain];
            [domainFilteredArray addObjectsFromArray:[levelFilteredArray filteredArrayUsingPredicate:domainPredicate]];
            [domainsDict setObject:domainFilteredArray forKey:domain];
        }

        [summaryDict setObject:domainsDict forKey:[self convertLogLevelToString:i]];
    }

    [plist setObject:summaryDict forKey:rootSummaryKey];

    if (![plist objectForKey:rootDeviceInfoKey])
    {
        MendeleyLogMessage(kMendeleyLogDomain, kSDKLogLevelWarning, @"Exported file has not device and user info");
    }

    NSString *filePath = [self getExportedLogFilePath];
    if (![plist writeToFile:filePath atomically:YES])
    {
        filePath = nil;
        MendeleyLogMessage(kMendeleyLogDomain, kSDKLogLevelError, @"Cannot create file for exporting");
    }
    return [NSURL fileURLWithPath:filePath];
}

// This method is not being called from anywhere else - and the methods it calls never dispatch_sync, so there is no chance of a deadlock here.
- (void)writeNewErrorsLogsToDisk
{
    dispatch_sync(self.errorLogQueue, ^{
                      [self addFlowEntriesToPersistentLog:self.temporaryLogQueue];
                      [self.temporaryLogQueue removeAllObjects];
                  });
}

@end
