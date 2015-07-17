//
//  TokenRefresh.swift
//  SwiftSample
//
//  Created by Hernan Zalazar on 6/23/15.
//  Copyright (c) 2015 Auth0. All rights reserved.
//

import Foundation
import Lock
import JWTDecode

public class TokenRefresh: NSObject {

    let storage: Storage
    let client: A0APIClient

    public init(storage: Storage, client: A0APIClient) {
        self.storage = storage
        self.client = client
    }

    public func refresh(callback: (error: NSError?, token: String?) -> ()) {
        if let jwt = storage.idToken {
            if !JWTDecode.expired(jwt: jwt) {
                callback(error: nil, token: storage.idToken)
                return
            }
            if let refreshToken = storage.refreshToken {
                client.fetchNewIdTokenWithRefreshToken(refreshToken, parameters: nil, success: { (token) -> () in
                    callback(error: nil, token: token.idToken)
                    }, failure: { (error) -> () in
                        callback(error: error, token: nil)
                })
            } else {
                callback(error: NSError(domain: "com.auth0.ios.refresh-token", code: -1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Couldn't find a refresh token in Token Storage", comment: "No refresh_token")]), token: nil)
            }
        } else {
            callback(error: NSError(domain: "com.auth0.ios.id-token", code: -1, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Couldn't find an id_token in Token Storage", comment: "No id_token")]), token: nil)
        }
    }

}

public extension A0Lock {
    public func refreshIdTokenFromStorage(storage: Storage, callback: (error: NSError?, token: String?) -> ()) {
        let token = TokenRefresh(storage: storage, client: self.apiClient())
        token.refresh(callback)
    }
}
