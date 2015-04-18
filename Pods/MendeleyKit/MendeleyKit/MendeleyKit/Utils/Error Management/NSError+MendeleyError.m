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

#import "NSError+MendeleyError.h"
#import "MendeleyResponse.h"

@implementation NSError (MendeleyKit)

+ (id)errorWithCode:(MendeleyErrorCode)code localizedDescription:(NSString *)localizedDescription
{
    if (nil == localizedDescription)
    {
        localizedDescription = MendeleyErrorUnknown;
    }
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: localizedDescription };
    return [[self class] errorWithDomain:kMendeleyErrorDomain code:code userInfo:userInfo];
}

+ (id)errorWithCode:(MendeleyErrorCode)code
{
    return [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:code];
}

+ (id)errorWithMendeleyResponse:(MendeleyResponse *)response requestURL:(NSURL *)url
{
    if (nil == response)
    {
        return [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:MendeleyErrorUnknown];
    }
    NSString *description = [NSString stringWithFormat:@"%@: %@ (%@)", [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], response.responseMessage, [url absoluteString]];
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey:  description };

    return [[self class] errorWithDomain:kMendeleyErrorDomain code:response.statusCode userInfo:userInfo];
}

+ (id)errorWithMendeleyResponse:(MendeleyResponse *)response requestURL:(NSURL *)url failureBody:(NSData *)body
{
    if (nil == response)
    {
        return [[MendeleyErrorManager sharedInstance] errorWithDomain:kMendeleyErrorDomain code:MendeleyErrorUnknown];
    }

    NSString *description = [NSString stringWithFormat:@"%lu %@ (%@)", (unsigned long)response.statusCode, response.responseMessage, [url absoluteString]];
    NSMutableDictionary *userInfo = [@{ NSLocalizedDescriptionKey:  description } mutableCopy];

    if (0 != body.length)
    {
        NSError *failureError;
        id failureReason = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingAllowFragments error:&failureError];
        if (!failureError && failureReason)
        {
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason;
        }
    }

    return [[self class] errorWithDomain:kMendeleyErrorDomain code:response.statusCode userInfo:userInfo];
}

@end
