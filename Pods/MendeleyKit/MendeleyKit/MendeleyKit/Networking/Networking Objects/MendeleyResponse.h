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
@class MendeleySyncInfo;

@interface MendeleyResponse : NSObject
@property (nonatomic, assign, readonly) MendeleyResponseBodyContentType contentType;
@property (nonatomic, assign, readonly, getter = isSuccess) BOOL success;
@property (nonatomic, strong, readonly) id responseBody;
@property (nonatomic, strong, readonly) NSString *responseMessage;
@property (nonatomic, assign, readonly) NSUInteger statusCode;
@property (nonatomic, strong, readonly) MendeleySyncInfo *syncHeader;
@property (nonatomic, strong, readonly) NSURL *fileURL;
/**
   initialises a MendeleyResponse object
   @param urlResponse
   @return MendeleyResponse object
 */

+ (MendeleyResponse *)mendeleyReponseForURLResponse:(NSURLResponse *)urlResponse;

/**
   initialises a MendeleyResponse object with a file location (to be used for up/download)
   @param urlResponse
   @param fileURL
   @return MendeleyResponse object
 */
+ (MendeleyResponse *)mendeleyReponseForURLResponse:(NSURLResponse *)urlResponse
                                            fileURL:(NSURL *)fileURL;

/**
   used for deserialising response data. This method is used for cases where
   the body content is of type JSON.
   Don't use for binary data
   @param rawResponseData
   @param error
   @return YES if successful (error is nil) or NO otherwise
 */
- (BOOL)deserialiseRawResponseData:(NSData *)rawResponseData error:(NSError **)error;

@end
