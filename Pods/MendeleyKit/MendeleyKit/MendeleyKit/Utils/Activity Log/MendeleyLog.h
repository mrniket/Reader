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

#pragma mark - Activity Log Methods Macros

#ifdef DEBUG
#   define MLog(fmt, ...) NSLog((fmt), ## __VA_ARGS__);
#else
#   define MLog(...)
#endif

#define kMendeleyNetworkDomain       @"MendeleyNetworkDomain"
#define kMendeleyLoginDomain         @"MendeleyLoginDomain"
#define kMendeleyLogDomain           @"MendeleyLogDomain"
#define kMendeleyPerformanceDomain   @"MendeleyPerformanceDomain"

#define MendeleyLogMessage(Domain, Level, ...)     [[MendeleyLog sharedInstance] logMessageWithDomainString : Domain level : Level message : __VA_ARGS__]
#define MendeleyLogMessageWithError(Domain, Error) [[MendeleyLog sharedInstance] logMessageWithDomainString : Domain error : Error]
#define kLevelsNumber                4
#define kMendeleyLogDomainAllDomains @"MendeleyLog Special Domain, do not use in normal logging."

#pragma mark -
@interface MendeleyLog : NSObject

+ (MendeleyLog *)sharedInstance;

/// Internal activity logs queue. Readonly from outside.
/// A maximum number of 1000 logs are kept at one time. (including the logs from previous runs!)
@property (nonatomic, strong, readonly) NSMutableArray *temporaryLogQueue;

/** Use this dictionary to filter which log messages you'd like to have printed on the console (they will always be written to disk).
   The keys are expected to be NSStrings - namely your domain names.
   The values should be the corresponding minimum log levels you want for each domain.
   There is a special domain name - defined as kMendeleyLogDomainAllDomains that will provide a certain threshold for all domains -
   any values set for a specific domain will overwrite this value. (e.g. it is possible to only log warnings for all domains except one, which might also log infos)
   If a domain is not found in the dictionary, all levels will be printed to the console for this domain.
   The example below will only print messages with level 'Warning' or above for the domain 'my log domain'.
   All other domains are unaffected.
   @code
   NSDictionary *filters = {@"my log domain" : @(kLogLevelWarning)};
   [[MendeleyLog sharedInstance] setConsoleLogFilters:filters];
 */
@property (nonatomic, strong) NSDictionary *consoleLogFilters;

typedef NS_ENUM (NSUInteger, MendeleyLogLevel)
{
    kSDKLogLevelInfo = 0,
    kSDKLogLevelWarning,
    kSDKLogLevelError,
    kSDKLogLevelException
};

/**
 * Logs a message using the given parameters
   @param domain
   @param level
   @param format (variable)
 */
- (void)logMessageWithDomainString:(NSString *)domain level:(MendeleyLogLevel)level message:(NSString *)format, ...;

/**
 * Logs an error message using the given error object
   @param domain
   @param error
 */
- (void)logMessageWithDomainString:(NSString *)domain error:(NSError *)error;

/**
   @return the URL for a temp file ready to be sent via mail
 */
- (NSURL *)createFormattedActivityLogFileAndExportURL;

/**
 * delete the temp file
 */
- (void)cleanExportedLogFile;

/**
 * Allow to the client to insert info about current device and user
   @param deviceInfoDict
 */
- (void)addUserInfoToPersistentLog:(NSDictionary *)deviceInfoDict;

/**
 * This Method save new errors persistently
 */
- (void)writeNewErrorsLogsToDisk;

@end
