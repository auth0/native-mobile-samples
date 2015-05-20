// LockReactModule.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LockReactModule.h"
#import "A0LockReact.h"
#import <Lock/A0IdentityProviderAuthenticator.h>

#if __has_include(<Lock-Facebook/A0FacebookAuthenticator.h>)
#define FACEBOOK_ENABLED 1
#import <Lock-Facebook/A0FacebookAuthenticator.h>
#endif

#if __has_include(<Lock-Twitter/A0TwitterAuthenticator.h>)
#define TWITTER_ENABLED 1
#import <Lock-Twitter/A0TwitterAuthenticator.h>
#endif

#if __has_include(<Lock-GooglePlus/A0GooglePlusAuthenticator.h>)
#define GOOGLE_PLUS_ENABLED 1
#import <Lock-GooglePlus/A0GooglePlusAuthenticator.h>
#endif

@implementation LockReactModule

RCT_EXPORT_MODULE(LockReact);

RCT_EXPORT_METHOD(registerNativeAuthentication:(NSArray *)authentications) {
  A0IdentityProviderAuthenticator *authenticator = [A0IdentityProviderAuthenticator sharedInstance];
  for (NSDictionary *authentication in authentications) {
    NSString *name = authentication[@"provider"];
#ifdef FACEBOOK_ENABLED
    if ([@"facebook" isEqualToString:name]) {
      NSArray *permissions = authentication[@"permissions"];
      if (permissions.count == 0) {
        permissions = nil;
      }
      [authenticator registerAuthenticationProvider:[A0FacebookAuthenticator newAuthenticatorWithPermissions:permissions]];
    }
#endif
#ifdef TWITTER_ENABLED
    if ([@"twitter" isEqualToString:name]) {
      NSString *apiKey = authentication[@"api_key"];
      NSString *apiSecret = authentication[@"api_secret"];
      [authenticator registerAuthenticationProvider:[A0TwitterAuthenticator newAuthenticatorWithKey:apiKey andSecret:apiSecret]];
    }
#endif
#ifdef GOOGLE_PLUS_ENABLED
    if ([@"google+" isEqualToString:name]) {
      NSString *clientId = authentication[@"client_id"];
      NSArray *scopes = authentication[@"scopes"];
      [authenticator registerAuthenticationProvider:[A0GooglePlusAuthenticator newAuthenticatorWithClientId:clientId andScopes:scopes]];
    }
#endif
  }
}

RCT_EXPORT_METHOD(show:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    A0LockReact *lock = [[A0LockReact alloc] init];
    [lock showWithOptions:options callback:callback];
  });
}

RCT_EXPORT_METHOD(showSMS:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    A0LockReact *lock = [[A0LockReact alloc] init];
    [lock showSMSWithOptions:options callback:callback];
  });
}

RCT_EXPORT_METHOD(showTouchID:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    A0LockReact *lock = [[A0LockReact alloc] init];
    [lock showTouchIDWithOptions:options callback:callback];
  });
}

@end