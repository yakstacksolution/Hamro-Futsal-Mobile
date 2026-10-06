import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/features/app_update/domain/entities/install_progress.dart';
import 'package:in_app_update/in_app_update.dart' as play;
import 'package:url_launcher/url_launcher.dart';

enum PlayFlowOutcome {
  started,

  userDenied,

  failed,

  unavailable,
}

@immutable
final class PlayUpdateAvailability {
  const PlayUpdateAvailability({
    required this.updateAvailable,
    required this.immediateAllowed,
    required this.flexibleAllowed,
    this.availableVersionCode,
    this.stalenessDays,
    this.priority,
    this.installStatus = play.InstallStatus.unknown,
  });

  static const PlayUpdateAvailability none = PlayUpdateAvailability(
    updateAvailable: false,
    immediateAllowed: false,
    flexibleAllowed: false,
  );

  final bool updateAvailable;
  final bool immediateAllowed;
  final bool flexibleAllowed;
  final int? availableVersionCode;
  final int? stalenessDays;
  final int? priority;
  final play.InstallStatus installStatus;

  bool get isDownloaded => installStatus == play.InstallStatus.downloaded;
}

abstract class AppUpdatePlatform {
  bool get isPlaySupported;

  Future<PlayUpdateAvailability> checkPlayAvailability();

  Future<PlayFlowOutcome> startFlexibleUpdate();

  Future<PlayFlowOutcome> performImmediateUpdate();

  Future<bool> completeFlexibleUpdate();

  Stream<InstallProgress> get installProgressStream;

  Future<bool> openStore({
    String? storeUrl,
    String? packageName,
    String? appStoreId,
  });
}

class InAppUpdateService implements AppUpdatePlatform {
  InAppUpdateService._();

  static final InAppUpdateService instance = InAppUpdateService._();

  PlayUpdateAvailability? _lastPlayCheck;

  @override
  bool get isPlaySupported => Platform.isAndroid;

  @override
  Future<PlayUpdateAvailability> checkPlayAvailability() async {
    if (!isPlaySupported) return PlayUpdateAvailability.none;

    try {
      final play.AppUpdateInfo info = await play.InAppUpdate.checkForUpdate();
      final PlayUpdateAvailability availability = PlayUpdateAvailability(
        updateAvailable:
            info.updateAvailability ==
                play.UpdateAvailability.updateAvailable ||
            info.updateAvailability ==
                play.UpdateAvailability.developerTriggeredUpdateInProgress,
        immediateAllowed: info.immediateUpdateAllowed,
        flexibleAllowed: info.flexibleUpdateAllowed,
        availableVersionCode: info.availableVersionCode,
        stalenessDays: info.clientVersionStalenessDays,
        priority: info.updatePriority,
        installStatus: info.installStatus,
      );
      _lastPlayCheck = availability;
      return availability;
    } on PlatformException catch (error, stack) {
      _log('Play checkForUpdate failed', error, stack);
      _lastPlayCheck = PlayUpdateAvailability.none;
      return PlayUpdateAvailability.none;
    } on MissingPluginException catch (error, stack) {
      _log('Play in-app update plugin unavailable', error, stack);
      _lastPlayCheck = PlayUpdateAvailability.none;
      return PlayUpdateAvailability.none;
    } catch (error, stack) {
      _log('Play checkForUpdate failed', error, stack);
      _lastPlayCheck = PlayUpdateAvailability.none;
      return PlayUpdateAvailability.none;
    }
  }

  @override
  Future<PlayFlowOutcome> startFlexibleUpdate() async {
    if (!isPlaySupported) return PlayFlowOutcome.unavailable;
    final PlayUpdateAvailability availability =
        _lastPlayCheck ?? await checkPlayAvailability();
    if (!availability.updateAvailable || !availability.flexibleAllowed) {
      return PlayFlowOutcome.unavailable;
    }

    try {
      return _mapResult(await play.InAppUpdate.startFlexibleUpdate());
    } catch (error, stack) {
      _log('startFlexibleUpdate failed', error, stack);
      return PlayFlowOutcome.failed;
    }
  }

  @override
  Future<PlayFlowOutcome> performImmediateUpdate() async {
    if (!isPlaySupported) return PlayFlowOutcome.unavailable;
    final PlayUpdateAvailability availability =
        _lastPlayCheck ?? await checkPlayAvailability();
    if (!availability.updateAvailable || !availability.immediateAllowed) {
      return PlayFlowOutcome.unavailable;
    }

    try {
      return _mapResult(await play.InAppUpdate.performImmediateUpdate());
    } catch (error, stack) {
      _log('performImmediateUpdate failed', error, stack);
      return PlayFlowOutcome.failed;
    }
  }

  @override
  Future<bool> completeFlexibleUpdate() async {
    if (!isPlaySupported) return false;
    try {
      await play.InAppUpdate.completeFlexibleUpdate();
      return true;
    } catch (error, stack) {
      _log('completeFlexibleUpdate failed', error, stack);
      return false;
    }
  }

  @override
  Stream<InstallProgress> get installProgressStream {
    if (!isPlaySupported) return const Stream<InstallProgress>.empty();
    return play.InAppUpdate.installUpdateListener
        .handleError(
          (Object error, StackTrace stack) =>
              _log('install listener', error, stack),
        )
        .map(_mapInstallStatus);
  }

  static InstallProgress _mapInstallStatus(play.InstallStatus status) {
    switch (status) {
      case play.InstallStatus.pending:
        return InstallProgress.pending;
      case play.InstallStatus.downloading:
        return InstallProgress.downloading;
      case play.InstallStatus.downloaded:
        return InstallProgress.downloaded;
      case play.InstallStatus.installing:
        return InstallProgress.installing;
      case play.InstallStatus.installed:
        return InstallProgress.installed;
      case play.InstallStatus.failed:
        return InstallProgress.failed;
      case play.InstallStatus.canceled:
        return InstallProgress.canceled;
      case play.InstallStatus.unknown:
        return InstallProgress.unknown;
    }
  }

  @override
  Future<bool> openStore({
    String? storeUrl,
    String? packageName,
    String? appStoreId,
  }) async {
    final List<Uri> candidates = <Uri>[];

    // `storeUrl` is backend-controlled, so every candidate goes through
    // `tryParse`: a malformed URL drops that one option instead of throwing a
    // FormatException out of the update flow.
    void addCandidate(String? value) {
      if (value == null || value.trim().isEmpty) return;
      final Uri? uri = Uri.tryParse(value.trim());
      if (uri != null && uri.scheme.isNotEmpty) candidates.add(uri);
    }

    if (Platform.isAndroid) {
      final String? id = packageName;
      if (id != null && id.isNotEmpty) {
        addCandidate('market://details?id=$id');
      }
      addCandidate(storeUrl);
      if (id != null && id.isNotEmpty) {
        addCandidate('https://play.google.com/store/apps/details?id=$id');
      }
    } else if (Platform.isIOS) {
      final String? id = appStoreId?.trim();
      if (id != null && id.isNotEmpty) {
        addCandidate('itms-apps://itunes.apple.com/app/id$id');
      }
      if (storeUrl != null && storeUrl.trim().isNotEmpty) {
        // The App Store app handles `itms-apps` links without a browser hop.
        addCandidate(
          storeUrl.trim().replaceFirst(RegExp(r'^https?://'), 'itms-apps://'),
        );
        addCandidate(storeUrl);
      }
      if (id != null && id.isNotEmpty) {
        addCandidate('https://apps.apple.com/app/id$id');
      }
    } else {
      addCandidate(storeUrl);
    }

    for (final Uri uri in candidates) {
      try {
        if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          return true;
        }
      } catch (error, stack) {
        _log('openStore failed for $uri', error, stack);
      }
    }
    return false;
  }

  PlayFlowOutcome _mapResult(play.AppUpdateResult result) {
    switch (result) {
      case play.AppUpdateResult.success:
        return PlayFlowOutcome.started;
      case play.AppUpdateResult.userDeniedUpdate:
        return PlayFlowOutcome.userDenied;
      case play.AppUpdateResult.inAppUpdateFailed:
        return PlayFlowOutcome.failed;
    }
  }

  void _log(String message, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('[InAppUpdateService] $message: $error');
    }
  }
}
