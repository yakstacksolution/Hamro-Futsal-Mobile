# Environments — staging ⇄ production

## The one switch

Open `lib/main.dart` and change one line:

```dart
const AppFlavor? kAppFlavor = AppFlavor.staging;  // or AppFlavor.production
```

That is the whole switch. There is one `main.dart`; no `main_staging.dart`, no
Android product flavors, no per-environment bundle id. Restart the app after
changing it — `env_*.env` are bundled assets, so hot reload will not pick it up.

Precedence, highest first:

1. `kAppFlavor` in `main.dart`, when it is not `null` — a hard override, so
   editing that line always takes effect whatever the IDE launch config or the
   Makefile target passes.
2. `--dart-define=ENV=staging|production` — used when `kAppFlavor` is `null`,
   which is what every CI workflow relies on.
3. The build mode — debug → staging, release/profile → production.

> **Set `kAppFlavor` back to `null` before pushing.** Left at `production` it
> overrides the `ENV=staging` in `dev.yml` and `ios_dev.yml`, and your staging
> builds would ship pointing at the production API.

`AppEnvironment` (`lib/core/config/app_environment.dart`) turns that into a
flavor, and `main.dart` loads the matching asset file:

| `ENV`        | file loaded       | API base                              |
| ------------ | ----------------- | ------------------------------------- |
| `staging`    | `env_staging.env`    | `https://staging.hamrofutsal.com/api` |
| `production` | `env_production.env` | `https://hamrofutsal.com/api`         |
| *(omitted)*  | depends on build mode — **debug → staging, profile/release → production** ||

`staging` also accepts `stage` / `dev`, and `production` accepts `prod` /
`live`, so a typo in a workflow does not silently fall back.

There is no other switch: no Android product flavors, no separate `main_*.dart`
entry points, no per-environment bundle id.

## Which file do I change?

| I want to change…                        | Edit                                        |
| ---------------------------------------- | ------------------------------------------- |
| **Which backend my builds use**          | `kAppFlavor` in `lib/main.dart`              |
| An API URL, socket host, key or event    | `env_staging.env` and/or `env_production.env`      |
| Add a **new** key                        | all of `env_staging.env`, `env_production.env`, `env_example.env` — then `make env-check` |
| Which environment a CI build ships       | the `--dart-define=ENV=…` in the workflow (see below) |
| Which environment one run uses, without touching code | `make run-prod` / the IDE's production config |
| The fallback when neither is set         | `_defaultFlavor` in `lib/core/config/app_environment.dart` |

After editing an env file, **do a full restart** — `env_*.env` are bundled assets,
so hot reload will not pick up a change.

## Running locally

```bash
make run-staging     # flutter run --dart-define=ENV=staging
make run-prod
make apk-staging     # release APK against staging
make aab-prod        # Play Store bundle against production
make ipa-staging
make env-check       # compares the two env files key by key
make help
```

VS Code: pick "Hamro Futsal — staging" or "— production" from the Run menu.
Android Studio: Run → Edit Configurations → *Additional run args*:
`--dart-define=ENV=staging`.

### Debugging

`flutter run`, the IDE Run button and `flutter build` all follow `kAppFlavor`
in `lib/main.dart`. Flip that line and restart — that is the normal way to move
between backends.

If `kAppFlavor` is `null`, the build flag decides; with neither, `_defaultFlavor` in
`lib/core/config/app_environment.dart` still keeps debug on staging and
release on production.

#### Debugging against production

Set `kAppFlavor = AppFlavor.production` in `main.dart` and hit Debug — you keep
breakpoints, hot reload and DevTools, pointed at the live backend.

To do it for one run without editing code, set `kAppFlavor = null` and pass the
flag:

**Android Studio / IntelliJ** — pick **`main.dart (production)`** from the run
configuration dropdown beside the Run button, then Debug (⌃D / Shift+F9).
Both configs ship in `.idea/runConfigurations/`. To make your own: Run → Edit
Configurations → **+** → Flutter → set *Dart entrypoint* to `lib/main.dart` and
*Additional run args* to `--dart-define=ENV=production`.

**VS Code** — pick **"Hamro Futsal — production"** in the Run and Debug panel
(configs live in `.vscode/launch.json`), then F5.

**Terminal**

```bash
make run-prod                                   # or
flutter run --dart-define=ENV=production
```

Confirm which one you got from the first console line:

```
[env] production (kAppFlavor in main.dart) → env_production.env → https://hamrofutsal.com/api
```

> `.idea/` is gitignored, so those run configurations stay on your machine;
> `.vscode/launch.json` is committed and shared.

To change what debug uses permanently, edit `_defaultFlavor` — that one getter
is the whole rule.

On start-up a debug build prints the environment it resolved, so the first line
in the console answers "which server am I on?":

```
[env] staging (default for this build mode) → https://staging.hamrofutsal.com/api
```

## CI

Each workflow pins its own environment; nothing is inferred from the branch.

| Workflow                        | Ships to                     | Defines             |
| ------------------------------- | ---------------------------- | ------------------- |
| `.github/workflows/dev.yml`     | Firebase App Distribution    | `ENV=staging`       |
| `.github/workflows/production.yml` | Google Play               | `ENV=production`    |
| `.github/workflows/ios_dev.yml` | TestFlight (staging)         | `ENV=staging`       |
| `.github/workflows/ios.yml`     | TestFlight (production)      | `ENV=production`    |

To move a workflow between environments, change that one `--dart-define` in its
`flutter build` step.

## Verified state (last checked 2026-09-14)

* Both env files carry the same 14 keys — no key is missing from either side.
* Only three values differ, all of them the backend host:
  `API_URL`, `REVERB_HOST`, `REVERB_AUTH_URL`.
* Every workflow passes `ENV` explicitly, so no shipped build depends on the
  default.
* `env_staging.env` and `env_production.env` are **committed** and listed as
  assets in `pubspec.yaml`. There is no `.env` fallback: if the flavour file is
  missing or a required key is blank, `AppEnvironment.load()` throws
  `EnvLoadException` — debug builds stop at start-up, release builds report it
  to Crashlytics. A packaging mistake is never papered over by quietly loading
  a different backend's configuration.

### Known gaps

1. **Shared secrets.** `SECURE_API_TOKEN`, `REVERB_APP_KEY`,
   `GOOGLE_SERVER_CLIENT_ID` and `GOOGLE_IOS_CLIENT_ID` are identical in both
   files. A staging build therefore authenticates with production credentials.
   `make env-check` prints these as warnings; give staging its own values when
   the backend can issue them.
2. **One Firebase project.** `android/app/google-services.json` and
   `ios/Runner/GoogleService-Info.plist` are single files pointing at
   `hamro-futsal-6f95c`, so staging and production share Crashlytics, Analytics
   and FCM. Switching projects today means editing those files by hand — which
   is why they show up as local modifications. If the two environments need to
   be separated, add Android product flavors (`android/app/src/staging/` and
   `src/production/`) and an Xcode configuration-scoped plist, then move the
   files into them.
3. **Secrets are in git.** Both env files are committed, so anyone with repo
   access has the production API token. Moving them to CI secrets and writing
   them at build time is the usual fix.
