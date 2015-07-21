//
//  Evilation.swift
//  Evilation
//
//  Created by Hernan Zalazar on 7/21/15.
//  Copyright (c) 2015 Auth0. All rights reserved.
//

import UIKit
import Lock
import LockFacebook

struct Evilation {

    static let sharedInstance = Evilation()

    let lock: A0Lock

    init() {
        self.lock = A0Lock()
        let facebook = A0FacebookAuthenticator.newAuthenticatorWithDefaultPermissions()
        self.lock.registerAuthenticators([facebook])
    }
}
