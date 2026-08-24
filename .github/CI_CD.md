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

Android production:

| Secret                              | Contents                                                              |
| ----------------------------------- | --------------------------------------------------------------------- |
| `KEYSTORE_BASE64`                   | `base64 -i android/upload-keystore.jks`                                |
| `KEYSTORE_PROPERTIES_BASE64`        | `base64 -i android/keystore.properties` (see format below)             |

Android staging uses the same secrets when present. If both are absent, the
staging workflow builds the Firebase tester APK with the debug signing key. If
only one of the two secrets exists, the workflow fails so CI does not silently
use a half-configured release signing setup.

Android staging only:

| Secret                              | Contents                                                              |
| ----------------------------------- | --------------------------------------------------------------------- |
| `FIREBASE_ANDROID_APP_ID`           | Firebase Android app ID, e.g. `1:1234567890:android:abcdef`            |
| `FIREBASE_CREDENTIAL_FILE_CONTENT`  | Service account JSON (raw or base64) with the Firebase App Distribution role |

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
| `APPLE_TEAM_ID`                               | 10-character Apple Developer Team ID                  |
| `IOS_PROVISIONING_PROFILE_NAME`               | App Store provisioning profile name for `com.np.hamrofutsal` |
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
storeFile=upload-keystore.jks
storePassword=<store password>
keyAlias=<alias>
keyPassword=<key password>
```

`android/app/build.gradle.kts` falls back to the debug keys when this file is
absent, so a fresh clone still builds locally without the release secrets.

To create the GitHub secrets from macOS:

```sh
base64 -i android/upload-keystore.jks | pbcopy
# Save clipboard as KEYSTORE_BASE64

base64 -i android/keystore.properties | pbcopy
# Save clipboard as KEYSTORE_PROPERTIES_BASE64
```

`KEYSTORE_BASE64` must come from the binary `.jks` file. Do not paste
`keystore.properties` into that secret.

After changing either local signing file, update the matching GitHub secret in
**Settings → Secrets and variables → Actions → Repository secrets**. The local
files are git-ignored, so CI only sees the values stored in GitHub secrets.

## Before the first iOS run

`ios/Runner/ExportOptions.plist` ships with two placeholders. The workflows replace
them at runtime from secrets, so you do not need to commit real signing values:

- `APPLE_TEAM_ID` → your 10-character Apple Developer Team ID
- `IOS_PROVISIONING_PROFILE_NAME` → the App Store provisioning profile **name**

## Notes

- `google-services.json` and `GoogleService-Info.plist` are committed, so CI needs
  no Firebase config injection.
- Release builds pass `--no-tree-shake-icons`: icons chosen indirectly through
  shared widgets are otherwise dropped and disappear only in release.
- The Android staging job runs `flutter analyze`/`flutter test` non-blocking;
  the production job requires `flutter test` to pass before building.

## Troubleshooting

### `Failed to authenticate, have you run firebase login?`

The action prints this for *every* credential problem. It never means a missing
interactive login — CI authenticates with a service account, not `firebase login`.
Real causes, in order of likelihood:

1. `FIREBASE_CREDENTIAL_FILE_CONTENT` is unset, empty, or under a different name.
2. The secret holds something other than a service account key — a Firebase CLI
   token (`firebase login:ci`) or an OAuth client file will not work.
3. The service account lacks the **Firebase App Distribution Admin** role, or the
   App Distribution API is not enabled on the project.
4. `FIREBASE_ANDROID_APP_ID` belongs to a different Firebase project than the
   service account.

The "Prepare Firebase credentials" step checks 1 and 2 and prints the service
account email, project ID, and the App ID's project number — compare those two
project identifiers to rule out 4.
