// ViewController.swift
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
import Alamofire
import CoreGraphics

private extension UIButton {

    func setRoundedCornerWitRadius(radius: Int) {
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.masksToBounds = true
    }

    func setBackgroundColor(color: UIColor, forState state: UIControlState) {
        let image = imageWithColor(color)
        setBackgroundImage(image, forState: state)
    }

    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPointZero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

class ViewController: UIViewController {

    var profile: A0UserProfile {
        return Application.sharedInstance.storage.profile!
    }

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        let normalColor = UIColor(red: 0.086, green: 0.129, blue: 0.302, alpha: 1.0)
        let highlightColor = UIColor(red: 0.239, green: 0.314, blue: 0.6, alpha: 1.0)
        self.avatarImageView.layer.cornerRadius = 50
        self.avatarImageView.layer.masksToBounds = true
        self.editProfileButton.setRoundedCornerWitRadius(5)
        self.editProfileButton.setBackgroundColor(normalColor, forState: .Normal)
        self.editProfileButton.setBackgroundColor(highlightColor, forState: .Highlighted)
        self.logoutButton.setRoundedCornerWitRadius(5)
        self.logoutButton.setBackgroundColor(normalColor, forState: .Normal)
        self.logoutButton.setBackgroundColor(highlightColor, forState: .Highlighted)
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "nav-auth0-logo"))
    }

    override func viewWillAppear(animated: Bool) {
        self.avatarImageView.setImageWithURL(self.profile.picture)
        self.usernameLabel.text = self.profile.username
        self.emailLabel.text = self.profile.email
    }

    @IBAction func logout(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(SessionNotification.Finish.rawValue, object: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as? ProfileViewController
        controller?.profile = self.profile
    }
}

