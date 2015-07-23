//
//  LoginViewController.swift
//  Evilation
//
//  Created by Hernan Zalazar on 7/21/15.
//  Copyright (c) 2015 Auth0. All rights reserved.
//

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
        client.loginWithUsername(self.emailField.text,
            password: self.passwordField.text,
            parameters: parameters,
            success: { profile, token in
                println("Logged in user \(profile.name)")
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
                UIView.animateWithDuration(animationDuration, delay: 0, options: UIViewAnimationOptions(animationCurve), animations: { () -> Void in
                    self.view.superview!.frame = frame
                    }, completion: nil)

        }
    }

    private func errorCallback(hud: MBProgressHUD) -> NSError -> () {
        return { error in
            var alert = UIAlertController(title: "Login failed", message: "Please check you application logs for more info", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            println("Failed with error \(error)")
            hud.hide(true)
        }
    }

    private func successCallback(hud: MBProgressHUD) -> (A0UserProfile, A0Token) -> () {
        return { (profile, token) -> Void in
            var alert = UIAlertController(title: "Logged In!", message: "User with name \(profile.name) logged in!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            println("Logged in user \(profile.name)")
            println("Tokens: \(token)")
            hud.hide(true)
        }
    }
}
