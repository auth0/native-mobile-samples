// AppDelegate.swift
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
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


import UIKit
import Lock
import SimpleKeychain
import Auth0Storage

enum SessionNotification: String {
    case Start = "StartSession"
    case Finish = "FinishSession"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window?.makeKeyAndVisible()
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LoadingController") as! UIViewController
        self.window?.rootViewController = controller

        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "finishSessionNotification:", name: SessionNotification.Finish.rawValue, object: nil)
        notificationCenter.addObserver(self, selector: "startSessionNotification:", name: SessionNotification.Start.rawValue, object: nil)
        let storage = Application.sharedInstance.storage
        let lock = Application.sharedInstance.lock
        lock.applicationLaunchedWithOptions(launchOptions)
        lock.refreshIdTokenFromStorage(storage) { (error, token) -> () in
            if error != nil {
                self.showLock(animated: false)
                return;
            }
            storage.idToken = token
            self.showMainRoot()
        }
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        return Application.sharedInstance.lock.handleURL(url, sourceApplication: sourceApplication)
    }

    func startSessionNotification(notification: NSNotification) {
        self.showMainRoot()
    }

    func finishSessionNotification(notification: NSNotification) {
        Application.sharedInstance.storage.clear()
        self.showLock(animated: true)
    }

    private func showMainRoot() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! UIViewController
        self.window?.rootViewController = controller
        UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionFlipFromLeft, animations: { }, completion: nil)
    }

    private func showLock(animated: Bool = false) {
        let storage = Application.sharedInstance.storage
        storage.clear()
        let lock = Application.sharedInstance.lock.newLockViewController()
        lock.onAuthenticationBlock = { (profile, token) in
            switch(profile, token) {
            case let (.Some(profile), .Some(token)):
                storage.save(token: token, profile: profile)
                NSNotificationCenter.defaultCenter().postNotificationName(SessionNotification.Start.rawValue, object: nil)
            default:
                println("Either auth0 token or profile of the user was nil, please check your Auth0 Lock config")
            }
        }
        self.window?.rootViewController = lock
        if animated {
            UIView.transitionWithView(self.window!, duration: 0.5, options: .TransitionFlipFromLeft, animations: { }, completion: nil)
        }
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

