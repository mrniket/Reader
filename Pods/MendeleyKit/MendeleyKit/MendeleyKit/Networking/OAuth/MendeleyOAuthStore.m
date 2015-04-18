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

#import "MendeleyOAuthStore.h"
#import "MendeleyOAuthConstants.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <Security/Security.h>

static NSMutableDictionary * keychainQueryDictionaryWithIdentifier()
{
    NSMutableDictionary *queryDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id) kSecClassGenericPassword, kSecClass, kMendeleyOAuthCredentialServiceName, kSecAttrService, nil];

    [queryDictionary setValue:kMendeleyOAuthTokenIdentifier forKey:(__bridge id) kSecAttrAccount];
    return queryDictionary;
}


@implementation MendeleyOAuthStore


- (BOOL)storeOAuthCredentials:(MendeleyOAuthCredentials *)credentials
{
    if (nil == credentials)
    {
        return [self removeOAuthCredentials];
    }
    NSMutableDictionary *keychainDictionary = keychainQueryDictionaryWithIdentifier();
    NSMutableDictionary *updateDictionary = [NSMutableDictionary dictionary];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:credentials];
    [updateDictionary setObject:data forKey:(__bridge id) kSecValueData];
    [updateDictionary setObject:(__bridge id) kSecAttrAccessibleWhenUnlocked
                         forKey:(__bridge id) kSecAttrAccessible];

    OSStatus status;
    BOOL exists = ([self retrieveOAuthCredentials] != nil);

    if (exists)
    {
        status = SecItemUpdate((__bridge CFDictionaryRef) keychainDictionary, (__bridge CFDictionaryRef) updateDictionary);
    }
    else
    {
        [keychainDictionary addEntriesFromDictionary:updateDictionary];
        status = SecItemAdd((__bridge CFDictionaryRef) keychainDictionary, NULL);
    }

    if (status != errSecSuccess)
    {
    }

    return (status == errSecSuccess);

}

- (BOOL)removeOAuthCredentials
{
    NSMutableDictionary *keychainDictionary = keychainQueryDictionaryWithIdentifier();
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef) keychainDictionary);

    if (status != errSecSuccess)
    {
    }
    return (status == errSecSuccess);

}

- (MendeleyOAuthCredentials *)retrieveOAuthCredentials
{
    NSMutableDictionary *keychainDictionary = keychainQueryDictionaryWithIdentifier();

    [keychainDictionary setObject:(__bridge id) kCFBooleanTrue forKey:(__bridge id) kSecReturnData];
    [keychainDictionary setObject:(__bridge id) kSecMatchLimitOne forKey:(__bridge id) kSecMatchLimit];

    CFDataRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef) keychainDictionary, (CFTypeRef *) &result);

    if (status != errSecSuccess || nil == result)
    {
        return nil;
    }

    NSData *data = (__bridge NSData *) result;
    MendeleyOAuthCredentials *oauthData = (MendeleyOAuthCredentials *) [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (nil == oauthData)
    {
    }
    return oauthData;

}
@end
