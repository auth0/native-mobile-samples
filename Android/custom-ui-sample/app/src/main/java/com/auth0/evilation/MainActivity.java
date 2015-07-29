package com.auth0.evilation;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;

import com.auth0.api.APIClient;
import com.auth0.api.callback.AuthenticationCallback;
import com.auth0.api.callback.BaseCallback;
import com.auth0.core.Auth0;
import com.auth0.core.Strategies;
import com.auth0.core.Token;
import com.auth0.core.UserProfile;
import com.auth0.facebook.FacebookIdentityProvider;
import com.auth0.identity.IdentityProvider;
import com.auth0.identity.IdentityProviderCallback;
import com.auth0.identity.WebIdentityProvider;
import com.auth0.identity.web.CallbackParser;

import de.greenrobot.event.EventBus;


public class MainActivity extends Activity {

    private static final String TAG = MainActivity.class.getName();

    private APIClient client;
    private EventBus eventBus;
    private WebIdentityProvider webProvider;
    private FacebookIdentityProvider facebook;
    private IdentityProvider identity;

    private ProgressDialog progress;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Auth0 auth0 = new Auth0(getString(R.string.auth0_client_id), getString(R.string.auth0_domain_name));
        this.client = auth0.newAPIClient();
        this.eventBus = new EventBus();
        final EventBusIdentityProviderCallback callback = new EventBusIdentityProviderCallback(eventBus, client);
        this.webProvider = new WebIdentityProvider(new CallbackParser(), auth0.getClientId(), auth0.getAuthorizeUrl());
        this.webProvider.setCallback(callback);
        this.facebook = new FacebookIdentityProvider(this);
        this.facebook.setCallback(callback);
        Button loginButton = (Button) findViewById(R.id.login_action_button);
        loginButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                EditText emailField = (EditText) findViewById(R.id.login_email_field);
                EditText passwordField = (EditText) findViewById(R.id.login_password_field);
                String email = emailField.getText().toString();
                String password = passwordField.getText().toString();
                progress = ProgressDialog.show(MainActivity.this, null, null, true);
                client.login(email, password, null, new AuthenticationCallback() {
                    @Override
                    public void onSuccess(UserProfile userProfile, Token token) {
                        eventBus.post(new AuthenticationEvent(userProfile, token));
                    }

                    @Override
                    public void onFailure(Throwable throwable) {
                        eventBus.post(new ErrorEvent(R.string.login_failed_title, R.string.login_failed_message, throwable));
                    }
                });
            }
        });
        Button twitterButton = (Button) findViewById(R.id.login_twitter_button);
        twitterButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                progress = ProgressDialog.show(MainActivity.this, null, null, true);
                identity = webProvider;
                identity.start(MainActivity.this, Strategies.Twitter.getName());
            }
        });
        Button facebookButton = (Button) findViewById(R.id.login_facebook_button);
        facebookButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                progress = ProgressDialog.show(MainActivity.this, null, null, true);
                identity = facebook;
                identity.start(MainActivity.this, Strategies.Facebook.getName());
            }
        });
    }

    @Override
    protected void onStart() {
        super.onStart();
        eventBus.register(this);
    }

    @Override
    protected void onStop() {
        super.onStop();
        webProvider.stop();
        eventBus.unregister(this);
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (progress != null) {
            progress.dismiss();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        Log.v(TAG, "Received new Intent with URI " + intent.getData());
        if (identity != null) {
            identity.authorize(this, IdentityProvider.WEBVIEW_AUTH_REQUEST_CODE, RESULT_OK, intent);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.v(TAG, "Child activity result obtained");
        if (identity != null) {
            identity.authorize(this, requestCode, resultCode, data);
        }
    }

    public void onEvent(ErrorEvent event) {
        progress.dismiss();
        event.showDialog(this);
    }

    public void onEvent(AuthenticationEvent event) {
        UserProfile profile = event.getProfile();
        Log.i(TAG, "LOGGED IN!");
        progress.dismiss();
        new AlertDialog.Builder(MainActivity.this)
                .setCancelable(true)
                .setTitle("Logged in with Auth0")
                .setMessage("Login with user email " + profile.getEmail())
                .setNeutralButton("Ok", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        dialogInterface.cancel();
                    }
                })
                .show();
    }
}
