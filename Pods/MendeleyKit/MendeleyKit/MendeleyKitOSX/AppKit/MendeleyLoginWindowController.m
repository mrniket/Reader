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

#import "MendeleyLoginWindowController.h"
#import "MendeleyURLBuilder.h"
#import "MendeleyKitConfiguration.h"
#import "MendeleyOAuthConstants.h"
#import "MendeleyOAuthStore.h"
#import "MendeleyDefaultOAuthProvider.h"
#import "NSError+MendeleyError.h"

@interface MendeleyLoginWindowController ()
@property (nonatomic, strong) WebView *webView;
@property (nonatomic, strong) NSURL *oauthServer;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *redirectURI;
@property (nonatomic, copy) MendeleyCompletionBlock completionBlock;
@property (nonatomic, strong) MendeleyOAuthCompletionBlock oAuthCompletionBlock;
@property (nonatomic, strong) id<MendeleyOAuthProvider> oauthProvider;

@end

@implementation MendeleyLoginWindowController

- (instancetype)initWithClientKey:(NSString *)clientKey
                     clientSecret:(NSString *)clientSecret
                      redirectURI:(NSString *)redirectURI
                  completionBlock:(MendeleyCompletionBlock)completionBlock
{
    return [self initWithClientKey:clientKey
                      clientSecret:clientSecret
                       redirectURI:redirectURI
                   completionBlock:completionBlock
               customOAuthProvider:nil];
}

- (instancetype)initWithClientKey:(NSString *)clientKey
                     clientSecret:(NSString *)clientSecret
                      redirectURI:(NSString *)redirectURI
                  completionBlock:(MendeleyCompletionBlock)completionBlock
              customOAuthProvider:(id<MendeleyOAuthProvider>)customOAuthProvider
{
    NSRect frame = NSMakeRect(0, 0, 550, 450);
    NSUInteger styleMask = NSTitledWindowMask | NSResizableWindowMask | NSClosableWindowMask;
    NSWindow *window = [[NSWindow alloc]
                        initWithContentRect:frame
                                  styleMask:styleMask
                                    backing:NSBackingStoreBuffered
                                      defer:YES];

    self = [super initWithWindow:window];
    if (self)
    {
        if (nil == customOAuthProvider)
        {
            _oauthProvider = [[MendeleyKitConfiguration sharedInstance] oauthProvider];
        }
        else
        {
            _oauthProvider = customOAuthProvider;
        }
        NSDictionary *oauthParameters = @{ kMendeleyOAuth2ClientSecretKey : clientSecret,
                                           kMendeleyOAuth2ClientIDKey : clientKey,
                                           kMendeleyOAuth2RedirectURLKey : redirectURI };
        [[MendeleyKitConfiguration sharedInstance] configureOAuthWithParameters:oauthParameters];
        _completionBlock = completionBlock;
        _clientID = clientKey;
        _redirectURI = redirectURI;

        NSView *view = [[NSView alloc] initWithFrame:frame];
        window.contentView = view;

        const CGFloat margin = 8;
        NSButton *cancelButton = [[NSButton alloc] init];
        [cancelButton setAction:@selector(cancel:)];
        [cancelButton setButtonType:NSPushOnPushOffButton];
        [cancelButton setBezelStyle:NSRoundedBezelStyle];
        [cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
        [cancelButton sizeToFit];
        cancelButton.frame = NSMakeRect(NSWidth(frame) - (NSWidth(cancelButton.frame) + margin), margin, NSWidth(cancelButton.frame), NSHeight(cancelButton.frame));
        cancelButton.autoresizingMask = NSViewMinXMargin;
        [view addSubview:cancelButton];

        WebView *webView = [[WebView alloc] initWithFrame:NSMakeRect(0, NSHeight(cancelButton.frame) + 2 * margin,
                                                                     NSWidth(frame), NSHeight(frame) - (NSHeight(cancelButton.frame) + 2 * margin))];
        webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
        webView.policyDelegate = self;
        webView.frameLoadDelegate = self;
        [view addSubview:webView];
        self.webView = webView;

        [self startLoginProcess];
    }

    return self;
}

- (IBAction)cancel:(id)sender
{
    [NSApp endSheet:self.window returnCode:NSModalResponseAbort];
}

#pragma mark Webview delegates methods

- (void)                    webView:(WebView *)webView
    decidePolicyForNavigationAction:(NSDictionary *)actionInformation
                            request:(NSURLRequest *)request
                              frame:(WebFrame *)frame
                   decisionListener:(id<WebPolicyDecisionListener>)listener
{
    if ([request.URL.absoluteString hasPrefix:[self.oauthServer absoluteString]])
    {
        [listener use];
        return;
    }

    NSString *code = [self authenticationCodeFromURLRequest:request];
    if (nil != code)
    {
        MendeleyOAuthCompletionBlock oAuthCompletionBlock = self.oAuthCompletionBlock;
        [self.oauthProvider authenticateWithAuthenticationCode:code
                                               completionBlock:oAuthCompletionBlock];
        [listener ignore];
        return;
    }

    ///TODO error handling

    [listener ignore];
}

- (void)         webView:(WebView *)sender
    didFailLoadWithError:(NSError *)error
                forFrame:(WebFrame *)frame
{
    NSDictionary *userInfo = [error userInfo];
    NSString *failingURLString = [userInfo objectForKey:NSURLErrorFailingURLStringErrorKey];

    if (nil != failingURLString && [self.oauthProvider urlStringIsRedirectURI:failingURLString])
    {
        // ignore if redirect URI
        return;
    }

    MendeleyCompletionBlock completionBlock = self.completionBlock;

    if (completionBlock)
    {
        completionBlock(NO, error);
    }
    self.oAuthCompletionBlock = nil;
    self.completionBlock = nil;
    self.webView = nil;
}

#pragma mark private methods

- (void)startLoginProcess
{
    [self setUpCompletionBlock];
    self.oauthServer = [MendeleyKitConfiguration sharedInstance].baseAPIURL;
    [self cleanCookiesAndURLCache];

    NSURLRequest *loginRequest = [self oauthURLRequest];
    [self.webView.mainFrame loadRequest:loginRequest];
}

- (void)setUpCompletionBlock
{
    MendeleyOAuthCompletionBlock oAuthCompletionBlock = ^void (MendeleyOAuthCredentials *credentials, NSError *error){
        if (nil != credentials)
        {
            MendeleyOAuthStore *oauthStore = [[MendeleyOAuthStore alloc] init];
            BOOL success = [oauthStore storeOAuthCredentials:credentials];
            if (nil != self.completionBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                                   self.completionBlock(success, nil);
                               });
            }
        }
        else
        {
            if (nil != self.completionBlock)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                                   self.completionBlock(NO, error);
                               });
            }
        }
    };

    self.oAuthCompletionBlock = oAuthCompletionBlock;
}


- (void)cleanCookiesAndURLCache
{
    if (nil == self.oauthServer)
    {
        return;
    }

    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        NSString *cookieDomain = [cookie domain];
        if ([cookieDomain isEqualToString:kMendeleyKitURL])
        {

            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
        if ([cookieDomain isEqualToString:[self.oauthServer host]])
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
}

- (NSURLRequest *)oauthURLRequest
{
    NSURL *baseOAuthURL = [self.oauthServer URLByAppendingPathComponent:kMendeleyOAuthPathAuthorize];
    NSDictionary *parameters = @{ kMendeleyOAuthAuthorizationCodeKey: kMendeleyOAuthAuthorizationCode,
                                  kMendeleyOAuth2RedirectURLKey: self.redirectURI,
                                  kMendeleyOAuth2ScopeKey: kMendeleyOAuth2Scope,
                                  kMendeleyOAuth2ClientIDKey: self.clientID,
                                  kMendeleyOAuth2ResponseTypeKey: kMendeleyOAuth2ResponseType };

    baseOAuthURL = [MendeleyURLBuilder urlWithBaseURL:baseOAuthURL parameters:parameters query:YES];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseOAuthURL];
    request.HTTPMethod = @"GET";
    request.allHTTPHeaderFields = [MendeleyURLBuilder defaultHeader];
    return request;
}

- (NSString *)authenticationCodeFromURLRequest:(NSURLRequest *)request
{
    NSArray *urlComponents = [[[request URL] query] componentsSeparatedByString:@"&"];
    __block NSString *code = nil;

    [urlComponents enumerateObjectsUsingBlock:^(NSString *param, NSUInteger index, BOOL *stop) {
         NSArray *parameterPair = [param componentsSeparatedByString:@"="];
         NSString *key = [parameterPair objectAtIndex:0];
         NSString *value = [parameterPair objectAtIndex:1];
         if ([key isEqualToString:kMendeleyOAuth2ResponseType])
         {
             code = value;
         }
     }];
    return code;
}

@end
