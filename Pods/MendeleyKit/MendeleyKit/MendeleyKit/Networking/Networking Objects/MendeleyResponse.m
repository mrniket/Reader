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

#import "MendeleyResponse.h"
#import "MendeleySyncInfo.h"
#import "NSError+MendeleyError.h"


@interface MendeleyResponse ()
@property (nonatomic, assign, readwrite) MendeleyResponseBodyContentType contentType;
@property (nonatomic, assign, readwrite) BOOL success;
@property (nonatomic, strong, readwrite) id responseBody;
@property (nonatomic, strong, readwrite) NSString *responseMessage;
@property (nonatomic, assign, readwrite) NSUInteger statusCode;
@property (nonatomic, strong, readwrite) NSURL *fileURL;
@property (nonatomic, strong, readwrite) MendeleySyncInfo *syncHeader;

@end

@implementation MendeleyResponse

+ (MendeleyResponse *)mendeleyReponseForURLResponse:(NSURLResponse *)urlResponse
{
    return [[self class] mendeleyReponseForURLResponse:urlResponse fileURL:nil];
}

+ (MendeleyResponse *)mendeleyReponseForURLResponse:(NSURLResponse *)urlResponse
                                            fileURL:(NSURL *)fileURL
{
    MendeleyResponse *response = [[MendeleyResponse alloc] init];

    response.fileURL = fileURL;

    [response parseURLResponse:urlResponse];

    return response;
}


- (BOOL)deserialiseRawResponseData:(NSData *)rawResponseData error:(NSError **)error
{
    BOOL innerSuccess = self.success;

    self.responseBody = nil;

    switch (self.contentType)
    {
        case JSONBody:
        {
            id jsonData = [NSJSONSerialization JSONObjectWithData:rawResponseData
                                                          options:NSJSONReadingAllowFragments
                                                            error:error];
            innerSuccess = [self jsonObjectHasValidData:jsonData error:error];
            self.responseBody = jsonData;
        }
        break;
        case PDFBody:
        case JPGBody:
        case PNGBody:
        case BinaryBody:
        {
            self.responseBody = rawResponseData;
        }
        break;
        case UnknownBody:
        {
            if (NULL != error)
            {
                *error = [NSError errorWithCode:kMendeleyUnknownDataTypeErrorCode];
            }
        }
        break;
    }
    self.success = innerSuccess;
    return innerSuccess;
}

#pragma mark private methods

+ (NSIndexSet *)correctStates
{
    return [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
}

- (void)parseURLResponse:(NSURLResponse *)urlResponse
{
    if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
        self.statusCode = httpResponse.statusCode;
        self.responseMessage = [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode];
        if ([[[self class] correctStates] containsIndex:self.statusCode])
        {
            self.success = YES;
            [self parseHTTPHeader:httpResponse];
        }
        else
        {
            self.success = NO;
        }
    }
    else
    {
        self.success = NO;
        self.responseMessage = @"Unknown URL response. Unable to process.";
    }

}

- (void)parseHTTPHeader:(NSHTTPURLResponse *)httpResponse
{
    NSDictionary *header = httpResponse.allHeaderFields;

    [self obtainContentTypeFromHeader:header];
    self.syncHeader = [[MendeleySyncInfo alloc] initWithAllHeaderFields:header];
}



- (void)obtainContentTypeFromHeader:(NSDictionary *)header
{
    NSString *contentType = [header objectForKey:kMendeleyRESTRequestContentType];

    if (nil != contentType)
    {
        if ([contentType hasSuffix:@"json"])
        {
            self.contentType = JSONBody;
        }
        else if ([contentType hasSuffix:kMendeleyRESTRequestValuePDF])
        {
            self.contentType = PDFBody;
        }
        else if ([contentType hasSuffix:kMendeleyRESTRequestJPEGType])
        {
            self.contentType = JPGBody;
        }
        else if ([contentType hasSuffix:kMendeleyRESTRequestPNGType])
        {
            self.contentType = PNGBody;
        }
        else if ([contentType hasSuffix:kMendeleyRESTRequestBinaryType])
        {
            self.contentType = BinaryBody;
        }
        else
        {
            self.contentType = UnknownBody;
        }
    }
}


- (BOOL)jsonObjectHasValidData:(id)jsonObject error:(NSError **)error
{
    if (nil == jsonObject)
    {
        return NO;
    }
    if ([jsonObject isKindOfClass:[NSDictionary class]])
    {
        NSString *message = [jsonObject objectForKey:kMendeleyJSONErrorMessage];
        BOOL success = (nil == message);
        if (!success && NULL != error)
        {
            self.responseMessage = message;
            *error = [NSError errorWithCode:kMendeleyJSONTypeNotMappedToModelErrorCode];
        }
        return success;
    }
    else if ([jsonObject isKindOfClass:[NSArray class]])
    {
        return YES;
    }
    return NO;
}
@end
