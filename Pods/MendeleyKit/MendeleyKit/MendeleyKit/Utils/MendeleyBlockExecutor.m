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

#import "MendeleyBlockExecutor.h"

@interface MendeleyBlockExecutor ()
@property (nonatomic, copy) MendeleyArrayCompletionBlock arrayCompletionBlock;
@property (nonatomic, copy) MendeleyCompletionBlock completionBlock;
@property (nonatomic, copy) MendeleyObjectCompletionBlock objectCompletionBlock;
@property (nonatomic, copy) MendeleySecureObjectCompletionBlock secureObjectCompletionBlock;
@property (nonatomic, copy) MendeleyDictionaryResponseBlock dictionaryCompletionBlock;
@property (nonatomic, copy) MendeleyStringArrayCompletionBlock stringArrayCompletionBlock;
@property (nonatomic, copy) MendeleyBinaryDataCompletionBlock binaryDataCompletionBlock;
@property (nonatomic, copy) MendeleyOAuthCompletionBlock oauthCompletionBlock;
@end

@implementation MendeleyBlockExecutor

- (id)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must use one of the 3 initialisers"]
                                 userInfo:nil];
}

- (instancetype)initWithArrayCompletionBlock:(MendeleyArrayCompletionBlock)arrayCompletionBlock
{
    self = [super init];
    if (nil != self)
    {
        _arrayCompletionBlock = arrayCompletionBlock;
    }
    return self;
}

- (instancetype)initWithStringArrayCompletionBlock:(MendeleyStringArrayCompletionBlock)stringArrayCompletionBlock
{
    self = [super init];
    if (nil != self)
    {
        _stringArrayCompletionBlock = stringArrayCompletionBlock;
    }
    return self;
}

- (instancetype)initWithCompletionBlock:(MendeleyCompletionBlock)completionBlock
{
    self = [super init];
    if (nil != self)
    {
        _completionBlock = completionBlock;
    }
    return self;

}

- (instancetype)initWithObjectCompletionBlock:(MendeleyObjectCompletionBlock)objectCompletionBlock
{
    self = [super init];
    if (nil != self)
    {
        _objectCompletionBlock = objectCompletionBlock;
    }
    return self;

}

- (instancetype)initWithSecureObjectCompletionBlock:(MendeleySecureObjectCompletionBlock)secureObjectCompletionBlock
{
    self = [super init];
    if (nil != self)
    {
        _secureObjectCompletionBlock = secureObjectCompletionBlock;
    }
    return self;
}

- (instancetype)initWithDictionaryCompletionBlock:(MendeleyDictionaryResponseBlock)dictionaryCompletionBlock
{
    self = [super init];
    if (nil != self)
    {
        _dictionaryCompletionBlock = dictionaryCompletionBlock;
    }
    return self;
}

- (instancetype)initWithBinaryDataCompletionBlock:(MendeleyBinaryDataCompletionBlock)binaryDataCompletionBlock
{
    self = [super init];
    if (nil != self)
    {
        _binaryDataCompletionBlock = binaryDataCompletionBlock;
    }
    return self;
}

- (instancetype)initWithOAuthCompletionBlock:(MendeleyOAuthCompletionBlock)oauthCompletionBlock
{
    self = [super init];
    if (nil != self)
    {
        _oauthCompletionBlock = oauthCompletionBlock;
    }
    return self;
}


- (void)executeWithArray:(NSArray *)array
                syncInfo:(MendeleySyncInfo *)syncInfo
                   error:(NSError *)error
{
    if (nil == self.arrayCompletionBlock)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.arrayCompletionBlock(array, syncInfo, error);
    });
}

- (void)executeWithBool:(BOOL)success
                  error:(NSError *)error
{
    if (nil == self.completionBlock)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionBlock(success, error);
    });
}

- (void)executeWithMendeleyObject:(MendeleyObject *)mendeleyObject
                         syncInfo:(MendeleySyncInfo *)syncInfo
                            error:(NSError *)error
{
    if (nil == self.objectCompletionBlock)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.objectCompletionBlock(mendeleyObject, syncInfo, error);
    });
}

- (void)executeWithMendeleySecureObject:(MendeleySecureObject *)mendeleySecureObject
                               syncInfo:(MendeleySyncInfo *)syncInfo
                                  error:(NSError *)error
{
    if (nil == self.secureObjectCompletionBlock)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.secureObjectCompletionBlock(mendeleySecureObject, syncInfo, error);
    });
}

- (void)executeWithDictionary:(NSDictionary *)dictionary
                        error:(NSError *)error
{
    if (nil == self.dictionaryCompletionBlock)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dictionaryCompletionBlock(dictionary, error);
    });

}

- (void)executeWithBinaryData:(NSData *)binaryData
                        error:(NSError *)error
{
    if (nil == self.binaryDataCompletionBlock)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.binaryDataCompletionBlock(binaryData, error);
    });
}

- (void)executeWithCredentials:(MendeleyOAuthCredentials *)credentials error:(NSError *)error
{
    if (nil == self.oauthCompletionBlock)
    {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.oauthCompletionBlock(credentials, error);
    });
}


@end
