//
//  LockReactModule.m
//  AwesomeProject
//
//  Created by Sidorenko Nikita on 9/2/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "LockReactModule.h"
#import <LockReact/A0LockReact.h>

@implementation LockReactModule

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(show:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    A0LockReact *lock = [A0LockReact sharedInstance];
    [lock showWithOptions:options callback:callback];
  });
}

RCT_EXPORT_METHOD(showSMS:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    A0LockReact *lock = [A0LockReact sharedInstance];
    [lock showSMSWithOptions:options callback:callback];
  });
}

RCT_EXPORT_METHOD(showTouchID:(NSDictionary *)options callback:(RCTResponseSenderBlock)callback) {
  dispatch_async(dispatch_get_main_queue(), ^{
    A0LockReact *lock = [A0LockReact sharedInstance];
    [lock showTouchIDWithOptions:options callback:callback];
  });
}

@end
