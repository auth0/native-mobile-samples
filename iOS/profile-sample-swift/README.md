# Auth0 + iOS + Profile Seed

This a seed project that will show how to update the user profile in Auth0 using Auth0 API v2 and `user_metadata` field of the Auth0 user. This project also shows how to keep your user logged in using the `refresh_token`.

## Configuring the example

You must set your Auht0 `ClientId` and `Domain` in this sample so that it works. For that, just open the `ProfileSample/Info.plist` file and replace the `{CLIENT_ID}` and `{DOMAIN}` fields with your account information.

Also replace `{MOBILE_CUSTOM_SCHEME}` with `a0YOUR_CLIENT_ID`

## Running the example

In order to run the project, you need to have `XCode` installed.
Once you have that, just clone the project and run the following:

1. `pod install`
2. `open Profile\ Sample.xcworkspace`

Enjoy your iOS app now :).
