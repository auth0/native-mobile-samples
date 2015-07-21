//
//  AppDelegate.swift
//  Evilation
//
//  Created by Hernan Zalazar on 7/20/15.
//  Copyright (c) 2015 Auth0. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        Evilation.sharedInstance.lock.applicationLaunchedWithOptions(launchOptions)
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return Evilation.sharedInstance.lock.handleURL(url, sourceApplication: sourceApplication)
    }
}

