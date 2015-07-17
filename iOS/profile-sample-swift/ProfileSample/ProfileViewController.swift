// ProfileViewController.swift
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

import UIKit
import Lock
import AFNetworking
import CoreGraphics
import Auth0
import MBProgressHUD

class ProfileViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!

    weak var currentField: UITextField?
    var keyboardFrame: CGRect?
    var profile: A0UserProfile!

    override func viewDidLoad() {

        super.viewDidLoad()

        self.avatar.layer.cornerRadius = 50
        self.avatar.layer.masksToBounds = true

        updateUI()

        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardShown:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func keyboardShown(notification: NSNotification) {
        let info = notification.userInfo!
        self.keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.keyboardFrame = self.view.convertRect(self.keyboardFrame!, fromView: nil)
        self.containerHeight.constant = 600 + self.keyboardFrame!.size.height
        if let field = self.currentField {
            self.scrollToField(field, keyboardFrame: self.keyboardFrame!)
        }
    }

    func keyboardHidden(notification: NSNotification) {
        self.containerHeight.constant = 600
        self.keyboardFrame = nil
    }

    @IBAction func editingBegan(sender: AnyObject) {
        self.currentField = sender as? UITextField
        if let field = self.currentField, let frame = self.keyboardFrame {
            self.scrollToField(field, keyboardFrame: frame)
        }
    }

    @IBAction func editingEnded(sender: AnyObject) {
        self.currentField = nil
    }

    @IBAction func nextField(sender: AnyObject) {
        let field = sender as! UITextField
        let currentTag = field.tag
        var nextTag = field.tag + 1
        if !(600...603 ~= nextTag) {
            nextTag = 600
        }
        if let next = self.view.viewWithTag(nextTag) as? UITextField, let frame = self.keyboardFrame {
            next.becomeFirstResponder()
            self.scrollToField(next, keyboardFrame: frame)
        }
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        hideKeyboard()
        let hud = MBProgressHUD.showHUDAddedTo(self.navigationController?.view, animated: true)
        hud.mode = .Indeterminate
        hud.labelText = NSLocalizedString("Saving…", comment: "Saving Profile message")
        let storage = Application.sharedInstance.storage
        if let idToken = storage.idToken {
            Auth0
                .users(idToken)
                .update(userMetadata: [
                    MetadataKeys.GivenName.rawValue: self.firstName.text,
                    MetadataKeys.FamilyName.rawValue: self.lastName.text,
                    MetadataKeys.Address.rawValue: self.address.text,
                    MetadataKeys.Birthday.rawValue: self.birthday.text,
                    ])
                .responseJSON { _, profileJSON in
                    if profileJSON != nil {
                        let newProfile = A0UserProfile(dictionary: profileJSON!)
                        storage.profile = newProfile
                        self.profile = newProfile
                        let checkImageView = UIImageView(image: UIImage(named: "checkmark"))
                        hud.customView = checkImageView
                        hud.mode = .CustomView
                        hud.labelText = NSLocalizedString("Saved!", comment: "Saved Profile message")
                        hud.hide(true, afterDelay: 0.8)
                    } else {
                        let checkImageView = UIImageView(image: UIImage(named: "cross"))
                        hud.customView = checkImageView
                        hud.mode = .CustomView
                        hud.labelText = NSLocalizedString("Failed!", comment: "Failed Save Profile message")
                        hud.hide(true, afterDelay: 0.8)
                    }
            }
        }
    }

    private func hideKeyboard() {
        self.currentField?.resignFirstResponder()
    }

    private func scrollToField(field: UITextField, keyboardFrame: CGRect) {
        let scrollOffset = self.offsetForFrame(field.frame, keyboardFrame: keyboardFrame)
        self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollOffset), animated: true)
    }

    private func offsetForFrame(frame: CGRect, keyboardFrame: CGRect) -> CGFloat {
        let bottom = frame.origin.y + frame.size.height
        let offset = bottom - keyboardFrame.origin.y
        if offset < 0 {
            return 0
        }
        return offset
    }

    private func updateUI() {
        self.title = self.profile.name
        self.avatar.setImageWithURL(self.profile.picture)
        self.firstName.text = self.profile.firstName
        self.lastName.text = self.profile.lastName
        self.email.text = self.profile.email
        self.address.text = self.profile.userMetadata["address"] as? String
        self.birthday.text = self.profile.userMetadata["birthday"] as? String
    }
}
