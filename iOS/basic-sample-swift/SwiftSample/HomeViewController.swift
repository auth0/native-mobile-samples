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

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = MyApplication.sharedInstance.keychain
        let idToken = keychain.stringForKey("id_token")
        if (idToken != nil) {
            if (A0JWTDecoder.isJWTExpired(idToken)) {
                let refreshToken = keychain.stringForKey("refresh_token")
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
                A0APIClient.sharedClient().fetchNewIdTokenWithRefreshToken(refreshToken, parameters: nil, success: success, failure: failure)
            } else {
                self.performSegueWithIdentifier("showProfile", sender: self)
            }
        }
    }

    @IBAction func showSignIn(sender: AnyObject) {
        let authController = A0LockViewController()
        authController.closable = true
        authController.onAuthenticationBlock = {(profile:A0UserProfile!, token:A0Token!) -> () in
            let keychain = MyApplication.sharedInstance.keychain
            keychain.setString(token.idToken, forKey: "id_token")
            keychain.setString(token.refreshToken, forKey: "refresh_token")
            keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: "profile")
            self.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("showProfile", sender: self)
        }
        self.presentViewController(authController, animated: true, completion: nil)
    }

}
