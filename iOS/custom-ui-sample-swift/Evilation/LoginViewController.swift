// LoginViewController.swift
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
import MBProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        let placeholderColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        self.emailField.attributedPlaceholder = NSAttributedString(string: "E-Mail", attributes: [NSForegroundColorAttributeName: placeholderColor])
        self.passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: placeholderColor])
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "handleKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "handleKeyboard:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        center.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    @IBAction func hideKeyboard(sender: AnyObject) {
        self.emailField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
    }

    @IBAction func focusPasswordField(sender: AnyObject) {
        self.passwordField.becomeFirstResponder()
    }

    @IBAction func login(sender: AnyObject) {
        self.hideKeyboard(sender)
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let lock = Evilation.sharedInstance.lock
        let client = lock.apiClient()
        let parameters = A0AuthParameters(dictionary: [A0ParameterConnection : "Username-Password-Authentication"])
        guard let email = self.emailField.text, let password = self.passwordField.text else {
            print("Either email or password are nil")
            return
        }
        client.loginWithUsername(email,
            password: password,
            parameters: parameters,
            success: { profile, token in
                print("Logged in user \(profile.name)")
                hud.hide(true)
            },
            failure: self.errorCallback(hud))
    }

    @IBAction func loginSocial(sender: AnyObject) {
        let connectionName: String
        if sender as! NSObject == self.twitterButton {
            connectionName = "twitter"
        } else {
            connectionName = "facebook"
        }
        self.hideKeyboard(sender)
        let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let lock = Evilation.sharedInstance.lock
        lock.identityProviderAuthenticator().authenticateWithConnectionName(connectionName, parameters: nil, success: self.successCallback(hud), failure: self.errorCallback(hud))
    }

    func handleKeyboard(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue(),
            let animationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval,
            let animationCurve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
                let parentFrame = self.view.superview!.frame
                let keyboardHeight = keyboardFrame.size.height
                let dy: CGFloat
                switch (notification.name) {
                case UIKeyboardWillShowNotification where parentFrame.origin.y == 0:
                    dy = -keyboardHeight
                case UIKeyboardWillShowNotification where parentFrame.origin.y != 0:
                    dy = -parentFrame.origin.y - keyboardHeight
                default:
                    dy = -parentFrame.origin.y
                }
                let frame = CGRectOffset(parentFrame, 0, dy)
                UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions(rawValue: animationCurve), animations: { () -> Void in
                    self.view.superview!.frame = frame
                    }, completion: nil)

        }
    }

    private func errorCallback(hud: MBProgressHUD) -> NSError -> () {
        return { error in
            let alert = UIAlertController(title: "Login failed", message: "Please check you application logs for more info", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("Failed with error \(error)")
            hud.hide(true)
        }
    }

    private func successCallback(hud: MBProgressHUD) -> (A0UserProfile, A0Token) -> () {
        return { (profile, token) -> Void in
            let alert = UIAlertController(title: "Logged In!", message: "User with name \(profile.name) logged in!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("Logged in user \(profile.name)")
            print("Tokens: \(token)")
            hud.hide(true)
        }
    }
}
