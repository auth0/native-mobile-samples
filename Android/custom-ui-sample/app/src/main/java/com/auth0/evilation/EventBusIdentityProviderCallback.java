package com.auth0.evilation;

import android.app.Dialog;

import com.auth0.api.authentication.AuthenticationAPIClient;
import com.auth0.api.callback.AuthenticationCallback;
import com.auth0.api.callback.BaseCallback;
import com.auth0.core.Token;
import com.auth0.core.UserProfile;
import com.auth0.identity.IdentityProviderCallback;

import org.greenrobot.eventbus.EventBus;

public class EventBusIdentityProviderCallback implements IdentityProviderCallback {

    private final EventBus bus;
    private final AuthenticationAPIClient client;

    public EventBusIdentityProviderCallback(EventBus bus, AuthenticationAPIClient client) {
        this.bus = bus;
        this.client = client;
    }

    @Override
    public void onFailure(Dialog dialog) {
        bus.post(new ErrorEvent(dialog));
    }

    @Override
    public void onFailure(int title, int message, Throwable throwable) {
        bus.post(new ErrorEvent(title, message, throwable));
    }

    @Override
    public void onSuccess(String serviceName, String accessToken) {
        client.loginWithOAuthAccessToken(accessToken, serviceName)
                .start(new AuthenticationCallback() {
                    @Override
                    public void onSuccess(UserProfile userProfile, Token token) {
                        bus.post(new AuthenticationEvent(userProfile, token));
                    }

                    @Override
                    public void onFailure(Throwable throwable) {
                        bus.post(new ErrorEvent(R.string.login_failed_title, R.string.login_failed_message, throwable));
                    }
                });
    }

    @Override
    public void onSuccess(final Token token) {
        client.tokenInfo(token.getIdToken())
                .start(new BaseCallback<UserProfile>() {
                    @Override
                    public void onSuccess(UserProfile profile) {
                        bus.post(new AuthenticationEvent(profile, token));
                    }

                    @Override
                    public void onFailure(Throwable throwable) {
                        bus.post(new ErrorEvent(R.string.login_failed_title, R.string.login_failed_message, throwable));
                    }
                });
    }
}
