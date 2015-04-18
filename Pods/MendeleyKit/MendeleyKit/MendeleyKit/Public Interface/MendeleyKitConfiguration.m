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

#import "MendeleyKitConfiguration.h"
#import "MendeleyDefaultNetworkProvider.h"
#import "MendeleyDefaultOAuthProvider.h"
#import "MendeleyKitUserInfoManager.h"

@interface MendeleyKitConfiguration ()
@property (nonatomic, assign, readwrite) BOOL isTrustedSSLServer;
@property (nonatomic, strong, readwrite) NSURL *baseAPIURL;
@property (nonatomic, assign, readwrite) NSString *documentViewType;
@property (nonatomic, strong, readwrite) id<MendeleyNetworkProvider> networkProvider;
@property (nonatomic, strong, readwrite) id<MendeleyOAuthProvider> oauthProvider;
@end

@implementation MendeleyKitConfiguration
+ (MendeleyKitConfiguration *)sharedInstance
{
    static MendeleyKitConfiguration *configuration = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
                      configuration = [[MendeleyKitConfiguration alloc] init];
                  });

    return configuration;
}

- (id)init
{
    self = [super init];
    if (nil != self)
    {
        [self resetToDefault];

        MendeleyKitUserInfoManager *sdkHelper = [MendeleyKitUserInfoManager new];
        [[MendeleyErrorManager sharedInstance] addUserInfoHelper:sdkHelper errorDomain:kMendeleyErrorDomain];
    }
    return self;
}

- (void)configureOAuthWithParameters:(NSDictionary *)parameters
{
    if (nil != self.oauthProvider &&
        [self.oauthProvider respondsToSelector:@selector(configureOAuthWithParameters:)])
    {
        [self.oauthProvider configureOAuthWithParameters:parameters];
    }
}


- (void)changeConfigurationWithParameters:(NSDictionary *)configurationParameters
{
    if (nil == configurationParameters || 0 == configurationParameters.allKeys.count)
    {
        return;
    }
    NSString *baseURLCandidate = [configurationParameters objectForKey:kMendeleyBaseAPIURLKey];
    if (nil != baseURLCandidate)
    {
        self.baseAPIURL = [NSURL URLWithString:baseURLCandidate];
    }
    NSNumber *baseTrustedFlag = [configurationParameters objectForKey:kMendeleyTrustedSSLServerKey];
    if (nil != baseTrustedFlag)
    {
        self.isTrustedSSLServer = [baseTrustedFlag boolValue];
    }
    NSString *baseViewType = [configurationParameters objectForKey:kMendeleyDocumentViewType];
    if (nil != baseViewType)
    {
        self.documentViewType = baseViewType;
    }

    NSString *oauthProviderName = [configurationParameters objectForKey:kMendeleyOAuthProviderKey];
    [self createProviderForClassName:oauthProviderName isNetwork:NO];

    NSString *networkProviderName = [configurationParameters objectForKey:kMendeleyNetworkProviderKey];
    [self createProviderForClassName:networkProviderName isNetwork:YES];
}

- (void)createProviderForClassName:(NSString *)className isNetwork:(BOOL)isNetwork
{
    Class providerClass = NSClassFromString(className);

    if (nil == providerClass)
    {
        return;
    }
    id provider = [[providerClass alloc] init];
    if (nil == provider)
    {
        return;
    }
    if (isNetwork)
    {
        if ([provider conformsToProtocol:@protocol(MendeleyNetworkProvider)])
        {
            self.networkProvider = provider;
        }
    }
    else
    {
        if ([provider conformsToProtocol:@protocol(MendeleyOAuthProvider)])
        {
            self.oauthProvider = provider;
        }
    }
}

- (void)resetToDefault
{
    _networkProvider = [MendeleyDefaultNetworkProvider sharedInstance];
    _oauthProvider = [MendeleyDefaultOAuthProvider sharedInstance];
    _isTrustedSSLServer = NO;
    // TODO: reset to default
    _documentViewType = kMendeleyDocumentViewTypeDefault;
    _baseAPIURL = [NSURL URLWithString:kMendeleyKitURL];
}


@end
