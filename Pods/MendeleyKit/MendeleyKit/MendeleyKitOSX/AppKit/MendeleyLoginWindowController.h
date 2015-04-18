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

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>
#import <WebKit/WebKit.h>
#import "MendeleyGlobals.h"
#import "MendeleyOAuthProvider.h"

@interface MendeleyLoginWindowController : NSWindowController
/**
   @name MendeleyLoginController is a helper class for OS X based clients.
   It provides a NSWindowController with a WebView for user authentication
 */
/**
   initialises the login view controller with Client App details
   @param clientKey
   @param clientSecret
   @param redirectURI
   @param completionBlock
 */

- (instancetype)initWithClientKey:(NSString *)clientKey
                     clientSecret:(NSString *)clientSecret
                      redirectURI:(NSString *)redirectURI
                  completionBlock:(MendeleyCompletionBlock)completionBlock;

/**
   custom initialisers
   The completion block BOOL variable is set to YES if login has been successful
   NO otherwise
   @param clientKey
   @param clientSecret
   @param redirectURI
   @param completionBlock
 */
- (instancetype)initWithClientKey:(NSString *)clientKey
                     clientSecret:(NSString *)clientSecret
                      redirectURI:(NSString *)redirectURI
                  completionBlock:(MendeleyCompletionBlock)completionBlock
              customOAuthProvider:(id<MendeleyOAuthProvider>)customOAuthProvider;

/**
   Cancels the operation.
   @param sender The event sender; can be nil.
 */
- (IBAction)cancel:(id)sender;

@end
