# Auth0 + Android + Custom UI

This seed project shows how to build your own Login UI and call Auth0 to authenticate your users.

## Configuring the example

You must set your Auht0 `ClientId` and `Domain` in this sample so that it works. For that, just open the `app/src/main/res/values/auth0.xml` file and replace the `{CLIENT_ID}` and `{DOMAIN}` fields with your account information.
Also replace `{MOBILE_CUSTOM_SCHEME}` with your ClientId in lowercase with `a0` prefix, e.g.: `a0YOUR_CLIENT_ID`

## Running the example

From the command line run the following commands inside the sample folder

```bash
./gradlew installDebug
adb shell am start -n com.auth0.evilation/.MainActivity 
```

Enjoy your Android app now :).
