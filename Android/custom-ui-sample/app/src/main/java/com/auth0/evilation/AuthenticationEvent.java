package com.auth0.evilation;

import com.auth0.core.Token;
import com.auth0.core.UserProfile;

public class AuthenticationEvent {

    private final UserProfile profile;
    private final Token token;

    public AuthenticationEvent(UserProfile profile, Token token) {
        this.profile = profile;
        this.token = token;
    }

    public Token getToken() {
        return token;
    }

    public UserProfile getProfile() {
        return profile;
    }
}
