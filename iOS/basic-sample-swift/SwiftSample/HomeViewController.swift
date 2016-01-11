// HomeViewController.swift
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
import JWTDecode
import MBProgressHUD
import Lock

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = MyApplication.sharedInstance.keychain
        if let idToken = keychain.stringForKey("id_token"), let jwt = try? JWTDecode.decode(idToken) {
            if jwt.expired, let refreshToken = keychain.stringForKey("refresh_token") {

                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                let success = {(token:A0Token!) -> () in
                    keychain.setString(token.idToken, forKey: "id_token")
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.performSegueWithIdentifier("showProfile", sender: self)
                }
                let failure = {(error:NSError!) -> () in
                    keychain.clearAll()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                let client = MyApplication.sharedInstance.lock.apiClient()
                client.fetchNewIdTokenWithRefreshToken(refreshToken, parameters: nil, success: success, failure: failure)
            } else {
                self.performSegueWithIdentifier("showProfile", sender: self)
            }
        }
    }

    @IBAction func showSignIn(sender: AnyObject) {
        let lock = MyApplication.sharedInstance.lock
        let authController = lock.newLockViewController()
        authController.closable = true
        authController.onAuthenticationBlock = { (profile, token) -> () in
            switch (profile, token) {
            case (.Some(let profile), .Some(let token)):
                let keychain = MyApplication.sharedInstance.keychain
                keychain.setString(token.idToken, forKey: "id_token")
                if let refreshToken = token.refreshToken {
                    keychain.setString(refreshToken, forKey: "refresh_token")
                }
                keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: "profile")
                self.dismissViewControllerAnimated(true, completion: nil)
                self.performSegueWithIdentifier("showProfile", sender: self)
            default:
                print("User signed up without logging in")
            }
        }
        self.presentViewController(authController, animated: true, completion: nil)
    }

}
