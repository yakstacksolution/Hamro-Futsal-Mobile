# In-app update

Server-driven update gate with native store integration on both platforms.

## How a check resolves

1. `GET {API_URL}/app-version?platform=android|ios&version=&build=&package=` — the
   authoritative source. It is the only source that can *force* an update.
2. **Android fallback:** Google Play's In-App Update API (`in_app_update`). Queried on
   every Android check anyway, because only Play can tell us whether the *native*
   flow may be started. A Play `updatePriority` of 5 is treated as mandatory, so the
   kill-switch still works when our backend is unreachable.
3. **iOS fallback:** the public iTunes Lookup API
   (`https://itunes.apple.com/lookup?bundleId=…`). Optional updates only — the App
   Store exposes no minimum-supported-version concept. Note Apple's CDN can lag a
   fresh release by a few hours.

Every source failing is treated as "up to date" (`sourceReachable: false`), so a
network blip never blocks the app. Only the manual **Settings → Check for updates**
action reports that difference to the user.

## Backend contract

Minimum viable response — the app needs only `latest_version`:

```json
{
  "data": {
    "latest_version": "1.4.2",
    "latest_build": 42,
    "min_supported_version": "1.2.0",
    "min_supported_build": 12,
    "force_update": false,
    "update_available": true,
    "release_title": "Faster booking",
    "release_notes": ["Faster slot search", "Fixed a payment crash"],
    "play_store_url": "https://play.google.com/store/apps/details?id=com.np.hamrofutsal",
    "app_store_url": "https://apps.apple.com/app/id0000000000",
    "download_size": "24.6 MB",
    "released_at": "2026-07-30T09:00:00Z"
  }
}
```

* The `data` envelope is optional; a flat object works too.
* Per-platform overrides may be nested under `android` / `ios` (or
  `platforms.android`), and win over the shared top-level values.
* Key spellings are matched liberally (`version`/`latest_version`,
  `changelog`/`release_notes`, `version_code`/`build`, …) so a backend rename does not
  silently disable the gate. See `AppUpdateManifestModel.fromBackendResponse`.
* `release_notes` accepts a list or a single string (split on newlines).

### What forces an update

* installed version `<` `min_supported_version` (or equal version with a lower build
  than `min_supported_build`), **or**
* `force_update: true` while a newer release exists, **or**
* Android only: Play reports `updatePriority: 5`.

Everything else that is newer is an *optional* update.

## Behaviour

| Case | UI |
| --- | --- |
| Optional | Dismissible bottom sheet with "What's new". "Later" snoozes **that version+build** for 24 h; a newer release clears the snooze. |
| Mandatory | Full-screen, non-dismissible wall layered over every route (`ForceUpdateScreen`), back button swallowed. |
| Android, non-mandatory | Play *flexible* flow — downloads in the background, then a "Restart to install" bar. |
| Android, mandatory | Play *immediate* flow (Play handles download, install and restart). |
| iOS / no Play / Play failure | Store redirect (`itms-apps://` → `https://`, `market://` → Play web). |

Checks run ~1.5 s after launch and on every app resume, throttled to one per 30
minutes (a manual check bypasses the throttle and the snooze).

## Wiring

* `AppUpdateBloc` is provided above `MaterialApp.router` in `main.dart`, and
  `AppUpdateGate` is mounted in the app's `builder` — above every route, below the
  theme.
* State that survives restarts lives in `AppSettings`
  (`updateSnoozedVersion`, `updateSnoozedUntil`, `updateLastCheckedAt`).

## Platform setup

* **Android:** nothing beyond the `in_app_update` dependency. The Play flow only
  works for a build installed *by Play* (internal testing track or higher) — in debug
  or sideloaded builds Play reports no update and the code falls back to a store
  redirect.
* **iOS:** `LSApplicationQueriesSchemes` includes `itms-apps` so the App Store app
  opens directly.
* **Optional `.env`:** `IOS_APP_STORE_ID` (builds a store link when the manifest has
  none), `APP_STORE_COUNTRY` (iTunes lookup storefront; defaults to the device
  region).

## Tests

`test/features/app_update/` covers version parsing/comparison and the full
requirement matrix (optional, forced, min-version breach, `update_available`
override, Play fallback, snooze semantics) against a fake data source and a fake
platform.
