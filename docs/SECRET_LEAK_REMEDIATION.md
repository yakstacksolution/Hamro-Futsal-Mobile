# Secret Leak Remediation

GitGuardian reported a Google API key exposed in this repository. Treat every
committed key as compromised, even after the source file is cleaned.

## Immediate Actions

1. Revoke the exposed Google Maps API key in Google Cloud Console.
2. Create new platform-specific keys:
   - Android Maps key restricted to package `com.np.hamrofutsal` and release /
     debug SHA-1 fingerprints.
   - iOS Maps key restricted to bundle id `com.np.hamrofutsal`.
3. Restrict each key to only the APIs the app needs, such as Maps SDK for
   Android and Maps SDK for iOS.
4. Rotate any non-Google secrets that were committed in env files, including
   `SECURE_API_TOKEN` and realtime service keys.
5. Replace local `env_staging.env`, `env_production.env`,
   `android/app/google-services.json`, and
   `ios/Runner/GoogleService-Info.plist` from a secure secret store before
   building.

## Repository Guardrails

- Run `make secret-scan` before pushing.
- CI runs `tool/secret_scan.dart` before dependency installation.
- Committed env and Firebase config files must contain placeholders only.
- Before local builds, place real Firebase config files in:
  - `secrets/android/google-services.json`
  - `secrets/ios/GoogleService-Info.plist`
- Or set these CI/local environment variables:
  - `FIREBASE_ANDROID_GOOGLE_SERVICES_JSON_BASE64`
  - `FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64`
- Run `make prepare-firebase` to copy secure config into the platform paths.
- Android builds run `validateFirebaseConfig` before `preBuild`, so placeholder
  Firebase API keys fail the build instead of crashing at runtime.

## Git History

Cleaning the working tree does not remove values from past commits. If the
repository is public or GitGuardian requires full remediation, rewrite history
with `git filter-repo` or BFG Repo-Cleaner, force-push protected branches using
your incident procedure, then invalidate every exposed key again.
