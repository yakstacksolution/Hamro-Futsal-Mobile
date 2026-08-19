# CI/CD

Two long-lived deployment branches drive four workflows:

| Branch       | Workflow                  | Platform | Destination                 |
| ------------ | ------------------------- | -------- | --------------------------- |
| `staging`    | `dev.yml`                 | Android  | Firebase App Distribution   |
| `staging`    | `ios_dev.yml`             | iOS      | TestFlight                  |
| `production` | `production.yml`          | Android  | Google Play (`production`)  |
| `production` | `ios.yml`                 | iOS      | TestFlight                  |

All four also accept a manual `workflow_dispatch` run.

Flow: feature branch → `staging` (tester builds) → `production` (store release).
Bump `version:` in `pubspec.yaml` before merging into `production` — Google Play
rejects an AAB whose build number it has already seen.

## Required repository secrets

Android (both workflows):

| Secret                              | Contents                                                              |
| ----------------------------------- | --------------------------------------------------------------------- |
| `KEYSTORE_BASE64`                   | `base64 -i hamro-futsal-release-key.keystore`                          |
| `KEYSTORE_PROPERTIES_BASE64`        | `base64 -i keystore.properties` (see format below)                     |

Android staging only:

| Secret                              | Contents                                                              |
| ----------------------------------- | --------------------------------------------------------------------- |
| `FIREBASE_ANDROID_APP_ID`           | Firebase Android app ID, e.g. `1:1234567890:android:abcdef`            |
| `FIREBASE_CREDENTIAL_FILE_CONTENT`  | Raw JSON of a service account with the Firebase App Distribution role  |

Android production only:

| Secret                              | Contents                                                              |
| ----------------------------------- | --------------------------------------------------------------------- |
| `GOOGLE_PLAY_SERVICEACCOUNT`        | base64 of the Google Play service account JSON                        |

iOS (both workflows):

| Secret                                        | Contents                                            |
| --------------------------------------------- | --------------------------------------------------- |
| `IOS_P12_DISTRIBUTION_CERTIFICATE_BASE64`     | base64 of the distribution `.p12`                    |
| `IOS_P12_DISTRIBUTION_CERTIFICATE_PASSWORD`   | password for that `.p12`                             |
| `IOS_DISTRIBUTION_PROVISIONING_PROFILE_BASE64`| base64 of the App Store `.mobileprovision`           |
| `IOS_RUNNER_LOCAL_KEYCHAIN_PASSWORD`          | any string — throwaway keychain password on the runner |
| `APP_STORE_CONNECT_API_ISSUER_ID`             | App Store Connect API issuer ID                      |
| `APP_STORE_CONNECT_API_KEY_ID`                | App Store Connect API key ID                         |
| `APP_STORE_CONNECT_API_KEY`                   | contents of the `.p8` private key                    |

Optional, all workflows:

| Secret              | Contents                                                        |
| ------------------- | --------------------------------------------------------------- |
| `SLACK_WEBHOOK_URL` | Incoming webhook. Notification steps skip themselves if unset.   |

## `keystore.properties` format

Lives at `android/keystore.properties`, git-ignored, decoded by CI from
`KEYSTORE_PROPERTIES_BASE64`. `storeFile` is resolved relative to `android/`:

```properties
storeFile=hamro-futsal-release-key.keystore
storePassword=<store password>
keyAlias=<alias>
keyPassword=<key password>
```

`android/app/build.gradle.kts` falls back to the debug keys when this file is
absent, so a fresh clone still builds locally without the release secrets.

## Before the first iOS run

`ios/Runner/ExportOptions.plist` ships with two placeholders that must be filled in:

- `teamID` → your 10-character Apple Developer Team ID
- `provisioningProfiles["com.np.hamrofutsal"]` → the App Store provisioning profile **name**

## Notes

- `google-services.json` and `GoogleService-Info.plist` are committed, so CI needs
  no Firebase config injection.
- Release builds pass `--no-tree-shake-icons`: icons chosen indirectly through
  shared widgets are otherwise dropped and disappear only in release.
- The Android staging job runs `flutter analyze`/`flutter test` non-blocking;
  the production job requires `flutter test` to pass before building.
