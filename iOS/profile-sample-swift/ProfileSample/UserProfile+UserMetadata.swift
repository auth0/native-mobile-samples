// UserProfile+UserMetadata.swift
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

import Foundation
import Lock

enum MetadataKeys: String {
    case Username = "username", GivenName = "given_name", FamilyName = "family_name", Birthday = "birthday", Address = "address"
}

extension A0UserProfile {

    var username: String {
        return metadata(.Username, defaultValue: self.nickname)!
    }

    var firstName: String? {
        return metadata(.GivenName)
    }

    var lastName: String? {
        return metadata(.FamilyName)
    }

    private func metadata<T>(key: MetadataKeys, defaultValue: T? = nil) -> T? {
        switch(self.userMetadata[key.rawValue] as? T, defaultValue) {
        case let (.Some(value), .None):
            return value
        case let (.None, .Some(value)):
            return value
        default:
            return self.extraInfo[key.rawValue] as? T
        }
    }
}
