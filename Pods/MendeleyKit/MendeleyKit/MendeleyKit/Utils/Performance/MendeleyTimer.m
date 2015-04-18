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

#import "MendeleyTimer.h"
#include <mach/mach_time.h>
#include <mach/mach.h>

@implementation MendeleyTimer
{
    @private
    // The absolute to nanosecond conversion factor.
    volatile long double factor_;

    // The started absolute time.
    volatile UInt64 started_;

    // The capture absolute time.
    volatile UInt64 capture_;
}

- (void)start;
{
    MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelInfo, @"Timer starting for job: %@", _name);
    _absoluteStartTime = [NSDate date];
    started_ = mach_absolute_time();
    capture_ = 0ULL;
}

- (void)stop
{
    // Get the capture time.
    UInt64 capture = mach_absolute_time();

    // If the timer was started, set capture time; otherwise, ignore the call.
    if (started_)
    {
        capture_ = capture;
    }

    MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelInfo, @"Timer stopped for job: %@ - Started on: %@ - Elapsed Time: %@", _name, _absoluteStartTime, [self stringWithElapsedTime]);
}

- (UInt64)nsElapsed
{
    if (!started_ || !capture_)
    {
        return 0LL;
    }

    return (UInt64) roundl((long double) (capture_ - started_) * factor_);
}

- (UInt32)msElapsed
{
    if (!started_ || !capture_)
    {
        return 0LL;
    }

    return (UInt32) roundl((long double) (capture_ - started_) * factor_ / 1000000.0L);
}

+ (MendeleyTimer *)timerWithName:(NSString *)name
{
    MendeleyTimer *stopWatch = [[MendeleyTimer alloc] initWithName:name];

    return stopWatch;
}

// Class initializer.
- (instancetype)initWithName:(NSString *)name
{
    self = [super init];

    // Handle errors.
    if (nil == self)
    {
        return nil;
    }

    _timerID = [[NSUUID UUID] UUIDString];

    if (name)
    {
        _name = name;
    }
    else
    {
        _name = @"no name";
    }

    // Precalculate the absolute time to nanosecond conversion factor as it
    // only needs to be done once.
    mach_timebase_info_data_t info;
    mach_timebase_info(&info);
    factor_ = ((long double) info.numer) / ((long double) info.denom);

    // Done.
    return self;
}

- (NSString *)stringWithElapsedTime
{
    // Allocate a number formatter and initialize it with the decimal style.
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];

    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];

    // Obtain the elapsed ns.
    UInt64 nsElapsed = [self nsElapsed];

    // Format the elapsed ns. This will always be returned.
    NSString *nsElapsedString = [formatter stringFromNumber:[NSNumber numberWithLongLong:nsElapsed]];

    // If the elapsed ns is < 1 ms, just return the elapsed ns.
    if (nsElapsed < 1000000ULL)
    {
        return [NSString stringWithFormat:@"[%@ ns]", nsElapsedString];
    }

    // Format the elapsed ms.
    NSString *msElapsedString = [formatter stringFromNumber:[NSNumber numberWithLong:[self msElapsed]]];

    // Done. Return elapsed ms and ns.
    return [NSString stringWithFormat:@"[%@ ms] [%@ ns]", msElapsedString, nsElapsedString];
}

- (void)invalidate
{
    [self stop];
    capture_ = 0;
    started_ = 0;
    MendeleyLogMessage(kMendeleyPerformanceDomain, kSDKLogLevelInfo, @"Timer invalidated for job: %@", _name);
}

@end
