import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/app_update/data/service/in_app_update_service.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/app_update_check.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/install_progress.dart';
import 'package:hamro_footsall/features/app_update/domain/repository/app_update_repository.dart';

/// The single entry point the presentation layer uses for updates: check,
/// decide whether to prompt, snooze, and drive the platform update flow.
final class CheckAppUpdateUseCase {
  CheckAppUpdateUseCase(this._repository, {AppUpdatePlatform? updateService})
    : _updateService = updateService ?? InAppUpdateService.instance;

  final AppUpdateRepository _repository;
  final AppUpdatePlatform _updateService;

  Future<Either<AppException, AppUpdateCheck>> checkForUpdate() =>
      _repository.checkForUpdate();

  bool shouldPrompt(AppUpdateCheck check) => _repository.shouldPrompt(check);

  Future<void> snooze(AppUpdateCheck check, {Duration? duration}) =>
      duration == null
      ? _repository.snooze(check)
      : _repository.snooze(check, duration: duration);

  /// Starts the best available update route for [check].
  ///
  /// Android with Play support: the native flow (immediate when the update is
  /// mandatory, flexible otherwise). Everything else, and any Play failure:
  /// the store listing.
  Future<PlayFlowOutcome> startUpdate(AppUpdateCheck check) async {
    if (check.canUsePlayFlow) {
      final PlayFlowOutcome outcome = check.isForced
          ? await _startImmediateThenFlexible(check)
          : await _startFlexibleThenImmediate(check);
      if (outcome != PlayFlowOutcome.unavailable &&
          outcome != PlayFlowOutcome.failed) {
        return outcome;
      }
    }

    final bool opened = await openStore(check);
    return opened ? PlayFlowOutcome.started : PlayFlowOutcome.failed;
  }

  /// Installs a flexible update that has finished downloading. Restarts the app.
  Future<bool> completeFlexibleUpdate() =>
      _updateService.completeFlexibleUpdate();

  Stream<InstallProgress> get installProgress =>
      _updateService.installProgressStream;

  Future<bool> openStore(AppUpdateCheck check) => _updateService.openStore(
    storeUrl: check.storeUrl,
    packageName: check.packageName,
    // Optional: the backend manifest and the iTunes lookup both supply a full
    // store URL, which is preferred over building one from the id. Guarded
    // because `maybeGet` throws outright when `.env` was never loaded.
    appStoreId: dotenv.isInitialized
        ? dotenv.maybeGet('IOS_APP_STORE_ID')
        : null,
  );

  Future<PlayFlowOutcome> _startFlexibleThenImmediate(
    AppUpdateCheck check,
  ) async {
    if (check.playFlexibleAllowed) {
      final PlayFlowOutcome outcome = await _updateService
          .startFlexibleUpdate();
      if (outcome != PlayFlowOutcome.unavailable) return outcome;
    }
    if (check.playImmediateAllowed) {
      return _updateService.performImmediateUpdate();
    }
    return PlayFlowOutcome.unavailable;
  }

  Future<PlayFlowOutcome> _startImmediateThenFlexible(
    AppUpdateCheck check,
  ) async {
    if (check.playImmediateAllowed) {
      final PlayFlowOutcome outcome = await _updateService
          .performImmediateUpdate();
      if (outcome != PlayFlowOutcome.unavailable) return outcome;
    }
    if (check.playFlexibleAllowed) {
      return _updateService.startFlexibleUpdate();
    }
    return PlayFlowOutcome.unavailable;
  }
}
