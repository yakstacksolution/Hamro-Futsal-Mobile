# CI/CD

This project deploys from Git branches:

- `staging`: Android APK goes to Firebase App Distribution, iOS IPA goes to TestFlight.
- `production`: Android AAB is uploaded to the Google Play production track and sent for review. Keep Google Play Managed publishing enabled so the reviewed release waits for manual publishing.
- `production`: iOS IPA is uploaded to App Store Connect/TestFlight. Final submission/release remains manual in App Store Connect.

## Workflows

- `.github/workflows/ci.yml`: runs `flutter analyze` and `flutter test` for pull requests to `staging`/`production` and for pushes to other branches.
- `.github/workflows/dev.yml`: staging Android Firebase App Distribution.
- `.github/workflows/ios_dev.yml`: staging iOS TestFlight.
- `.github/workflows/production.yml`: production Android Google Play review upload.
- `.github/workflows/ios.yml`: production iOS App Store Connect upload.

## GitHub Environments

Create these environments in GitHub repository settings:

- `staging`
- `production`

Put environment-specific secrets/vars there when values differ between staging and production. Repository-level secrets also work for shared values.

## Required Secrets

Android staging:

- `FIREBASE_CREDENTIAL_FILE_CONTENT`: Firebase service account JSON, raw or base64 encoded.
- `FIREBASE_ANDROID_APP_ID`: Firebase Android app id, for example `1:1234567890:android:abcdef`.
- `KEYSTORE_BASE64`: optional for staging; base64 of `android/upload-keystore.jks`.
- `KEYSTORE_PROPERTIES_BASE64`: optional for staging; base64 or raw content of `android/keystore.properties`.

Android production:

- `GOOGLE_PLAY_SERVICEACCOUNT`: base64 encoded Google Play service account JSON.
- `KEYSTORE_BASE64`: base64 of `android/upload-keystore.jks`.
- `KEYSTORE_PROPERTIES_BASE64`: base64 or raw content of `android/keystore.properties`.

iOS staging and production:

- `IOS_P12_DISTRIBUTION_CERTIFICATE_BASE64`
- `IOS_P12_DISTRIBUTION_CERTIFICATE_PASSWORD`
- `IOS_DISTRIBUTION_PROVISIONING_PROFILE_BASE64`
- `IOS_RUNNER_LOCAL_KEYCHAIN_PASSWORD`
- `APPLE_TEAM_ID`
- `IOS_PROVISIONING_PROFILE_NAME`
- `APP_STORE_CONNECT_API_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_KEY`

Optional shared secret:

- `SLACK_WEBHOOK_URL`

## Required Variables

Android staging:

- `FIREBASE_TESTER_GROUPS`: Firebase tester group aliases. Defaults to `testers`.

## Store Setup

Google Play:

- Enable Managed publishing in Play Console before production runs.
- Grant the service account access to the app with release permissions.
- The workflow sends the release to review. After approval, publish manually from Play Console.

Apple:

- Use an App Store distribution certificate and App Store provisioning profile for `com.np.hamrofutsal`.
- The workflow uploads the build to App Store Connect/TestFlight. Submit/release manually from App Store Connect.
