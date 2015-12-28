// Auth0Storage.swift
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

public class Storage {

    private let IdTokenKey = "id_token"
    private let RefreshTokenKey = "refresh_token"
    private let ProfileKey = "profile"
    private let keychain: A0SimpleKeychain

    public init(keychain: A0SimpleKeychain) {
        self.keychain = keychain
    }

    convenience public init() {
        self.init(keychain: A0SimpleKeychain())
    }

    public var idToken: String? {
        get {
            return keychain.stringForKey(IdTokenKey)
        }
        set {
            keychain.setString(newValue!, forKey: IdTokenKey)
        }
    }

    public var refreshToken: String? {
        return keychain.stringForKey(RefreshTokenKey)
    }

    public var profile: A0UserProfile? {
        get {
            let data = keychain.dataForKey(ProfileKey)
            return NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? A0UserProfile
        }
        set {
            if let profile = newValue {
                keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: ProfileKey)
            }
        }
    }

    public func save(token token: A0Token, profile: A0UserProfile) {
        self.idToken = token.idToken
        self.profile = profile
        keychain.setString(token.refreshToken!, forKey: RefreshTokenKey)
    }

    public func clear() {
        keychain.deleteEntryForKey(IdTokenKey)
        keychain.deleteEntryForKey(ProfileKey)
        keychain.deleteEntryForKey(RefreshTokenKey)
    }
}
