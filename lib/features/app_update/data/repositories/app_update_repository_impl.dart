import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/app_update/data/data_source/app_update_remote_data_source.dart';
import 'package:hamro_futsal/features/app_update/data/model/app_update_manifest_model.dart';
import 'package:hamro_futsal/features/app_update/data/service/in_app_update_service.dart';
import 'package:hamro_futsal/features/app_update/domain/entities/app_update_check.dart';
import 'package:hamro_futsal/features/app_update/domain/entities/app_version.dart';
import 'package:hamro_futsal/features/app_update/domain/repository/app_update_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

final class AppUpdateRepositoryImpl extends AppUpdateRepository {
  AppUpdateRepositoryImpl({
    AppUpdateRemoteDataSource? remoteDataSource,
    AppUpdatePlatform? updateService,
  }) : _remoteDataSource = remoteDataSource ?? AppUpdateRemoteDataSourceImpl(),
       _updateService = updateService ?? InAppUpdateService.instance;

  final AppUpdateRemoteDataSource _remoteDataSource;
  final AppUpdatePlatform _updateService;

  /// A Play priority of 5 is the "critical release" band. Treating it as
  /// mandatory gives a working kill-switch on Android even when the backend
  /// manifest is unreachable.
  static const int _criticalPlayPriority = 5;

  /// Default "Later" window for an optional update.
  static const Duration _defaultSnooze = Duration(hours: 24);

  @override
  Future<Either<AppException, AppUpdateCheck>> checkForUpdate() async {
    // Everything below runs at launch, above every route. A throw here — an
    // unreadable PackageInfo, a platform without dart:io, a plugin channel that
    // is not registered yet — used to escape as an unhandled async error and
    // take the frame down with it. An update check failing is never worth a
    // crash: it degrades to "source unreachable".
    try {
      return right(await _resolveUpdate());
    } catch (error, stack) {
      if (kDebugMode) {
        debugPrint('[AppUpdate] check failed: $error\n$stack');
      }
      return left(
        DefaultException(
          errorMessage: StringConstants.updateCheckFailed,
          statusCode: 0,
        ),
      );
    }
  }

  Future<AppUpdateCheck> _resolveUpdate() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final AppVersion currentVersion =
        AppVersion.tryParse(packageInfo.version) ?? AppVersion.zero;
    final int currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

    // Play is queried on every Android check regardless of the backend result:
    // its answer is what decides whether the *native* flow can be used, and it
    // doubles as the fallback source when our own endpoint is down.
    final PlayUpdateAvailability play = await _updateService
        .checkPlayAvailability();

    final ({AppUpdateManifestModel? manifest, bool reachable}) backend =
        await _fetchBackendManifest(
          version: packageInfo.version,
          build: currentBuild,
          packageName: packageInfo.packageName,
        );

    AppUpdateManifestModel? manifest = backend.manifest;
    bool reachable = backend.reachable;

    // iOS has no equivalent of the Play check, so the App Store lookup is the
    // only fallback when our backend cannot answer.
    if (manifest == null && Platform.isIOS) {
      manifest = await _fetchAppStoreManifest(packageInfo.packageName);
      reachable = reachable || manifest != null;
    }

    // On Android, a successful Play query is itself proof we could determine
    // the update state.
    reachable = reachable || (Platform.isAndroid && play.updateAvailable);

    AppUpdateCheck check = AppUpdateCheck(
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      packageName: packageInfo.packageName,
      requirement: UpdateRequirement.none,
      manifest: manifest,
      sourceReachable: reachable,
      playUpdateAvailable: play.updateAvailable,
      playImmediateAllowed: play.immediateAllowed,
      playFlexibleAllowed: play.flexibleAllowed,
      playStalenessDays: play.stalenessDays,
      playPriority: play.priority,
    );

    check = check.copyWith(
      requirement: _resolveRequirement(
        manifest: manifest,
        play: play,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      ),
    );

    // With no manifest but a Play-reported update, synthesise just enough
    // release information for the prompt to be meaningful.
    if (check.hasUpdate && manifest == null && play.updateAvailable) {
      check = check.copyWith(
        manifest: AppUpdateManifestModel(
          source: AppUpdateSource.playStore,
          // Play exposes a version *code*, never a version name, so the
          // installed version string is reused and the UI hides the label when
          // the two match.
          latestVersion: currentVersion,
          latestBuild: play.availableVersionCode,
          forceUpdate: check.isForced,
        ),
      );
    }

    AppSettings().updateLastCheckedAt = DateTime.now();

    // A newer release supersedes any earlier "Later".
    final String? snoozedVersion = AppSettings().updateSnoozedVersion;
    if (snoozedVersion != null &&
        check.manifest != null &&
        snoozedVersion != _snoozeKey(check)) {
      AppSettings().clearUpdateSnooze();
    }

    return check;
  }

  @override
  bool shouldPrompt(AppUpdateCheck check) {
    if (!check.hasUpdate) return false;
    if (check.isForced) return true;

    final AppSettings settings = AppSettings();
    if (settings.updateSnoozedVersion != _snoozeKey(check)) return true;

    final DateTime? until = settings.updateSnoozedUntil;
    if (until == null) return true;
    return DateTime.now().isAfter(until);
  }

  @override
  Future<void> snooze(
    AppUpdateCheck check, {
    Duration duration = _defaultSnooze,
  }) async {
    final AppSettings settings = AppSettings();
    settings.updateSnoozedVersion = _snoozeKey(check);
    settings.updateSnoozedUntil = DateTime.now().add(duration);
  }

  // ── Internals ──

  /// Identifies the snoozed release by version *and* build, so a rebuilt
  /// release under the same version name still prompts.
  String _snoozeKey(AppUpdateCheck check) {
    final AppUpdateManifestModel? manifest = check.manifest;
    if (manifest == null) return '';
    return '${manifest.latestVersion}+${manifest.latestBuild ?? 0}';
  }

  Future<({AppUpdateManifestModel? manifest, bool reachable})>
  _fetchBackendManifest({
    required String version,
    required int build,
    required String packageName,
  }) async {
    final Result response = await _remoteDataSource.getAppVersion(
      query: <String, dynamic>{
        'platform': Platform.isIOS ? 'ios' : 'android',
        'version': version,
        'build': build,
        'package': packageName,
      },
    );

    if (response.isError()) {
      return (manifest: null, reachable: false);
    }

    try {
      return (
        manifest: AppUpdateManifestModel.fromBackendResponse(
          response.getValue(),
        ),
        // The endpoint answered — even an unparsable body means the app is
        // online and our server is up.
        reachable: true,
      );
    } catch (_) {
      // A malformed manifest must never block launch — fall through to the
      // store-based sources instead.
      return (manifest: null, reachable: true);
    }
  }

  Future<AppUpdateManifestModel?> _fetchAppStoreManifest(
    String bundleId,
  ) async {
    final Result response = await _remoteDataSource.lookupAppStore(
      bundleId: bundleId,
      country: _appStoreCountry,
    );
    if (response.isError()) return null;

    try {
      return AppUpdateManifestModel.fromAppStoreResponse(response.getValue());
    } catch (_) {
      return null;
    }
  }

  /// The App Store storefront to look the app up in. A wrong storefront returns
  /// no results, so this prefers an explicit override, then the device region.
  String? get _appStoreCountry {
    // `maybeGet` still throws when the file was never loaded — a check that runs
    // before or without `dotenv.load` must not blow up.
    final String? configured = dotenv.isInitialized
        ? dotenv.maybeGet('APP_STORE_COUNTRY')
        : null;
    if (configured != null && configured.trim().isNotEmpty) {
      return configured.trim();
    }
    return PlatformDispatcher.instance.locale.countryCode;
  }

  UpdateRequirement _resolveRequirement({
    required AppUpdateManifestModel? manifest,
    required PlayUpdateAvailability play,
    required AppVersion currentVersion,
    required int currentBuild,
  }) {
    if (manifest != null) {
      final bool newerAvailable =
          manifest.updateAvailableOverride ??
          _isNewer(
            latest: manifest.latestVersion,
            latestBuild: manifest.latestBuild,
            currentVersion: currentVersion,
            currentBuild: currentBuild,
          );

      final bool belowMinimum = _isBelowMinimum(
        manifest: manifest,
        currentVersion: currentVersion,
        currentBuild: currentBuild,
      );

      // A minimum-version breach forces the update even if the server also
      // (contradictorily) says no update is available — the installed build is
      // no longer allowed to run either way.
      if (belowMinimum) return UpdateRequirement.forced;
      if (!newerAvailable) return UpdateRequirement.none;
      if (manifest.forceUpdate) return UpdateRequirement.forced;
      return UpdateRequirement.optional;
    }

    if (play.updateAvailable) {
      return (play.priority ?? 0) >= _criticalPlayPriority
          ? UpdateRequirement.forced
          : UpdateRequirement.optional;
    }

    return UpdateRequirement.none;
  }

  bool _isNewer({
    required AppVersion latest,
    required int? latestBuild,
    required AppVersion currentVersion,
    required int currentBuild,
  }) {
    final int comparison = latest.compareTo(currentVersion);
    if (comparison > 0) return true;
    if (comparison < 0) return false;
    // Same version name — a higher build number still counts as a new release.
    return latestBuild != null && latestBuild > currentBuild;
  }

  bool _isBelowMinimum({
    required AppUpdateManifestModel manifest,
    required AppVersion currentVersion,
    required int currentBuild,
  }) {
    final AppVersion? minimum = manifest.minSupportedVersion;
    if (minimum != null) {
      final int comparison = currentVersion.compareTo(minimum);
      if (comparison < 0) return true;
      if (comparison == 0) {
        final int? minimumBuild = manifest.minSupportedBuild;
        if (minimumBuild != null && currentBuild < minimumBuild) return true;
      }
      return false;
    }

    // A bare minimum *build* with no version is still meaningful when the
    // backend versions by build number only.
    final int? minimumBuild = manifest.minSupportedBuild;
    return minimumBuild != null && currentBuild < minimumBuild;
  }
}
