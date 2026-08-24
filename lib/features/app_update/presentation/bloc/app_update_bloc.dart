import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/app_update/data/service/in_app_update_service.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/app_update_check.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/install_progress.dart';
import 'package:hamro_footsall/features/app_update/domain/usecase/check_app_update_use_case.dart';

part 'app_update_event.dart';
part 'app_update_state.dart';

/// Owns the update lifecycle: checking, prompting, snoozing, and driving the
/// platform update flow through to install.
///
/// Long-lived — created once above the router so a forced update can block the
/// whole app and a background download survives navigation.
class AppUpdateBloc extends Bloc<AppUpdateEvent, AppUpdateState> {
  AppUpdateBloc(this._useCase) : super(const AppUpdateState()) {
    on<CheckAppUpdateEvent>(_onCheck);
    on<StartAppUpdateEvent>(_onStartUpdate);
    on<OpenStoreEvent>(_onOpenStore);
    on<SnoozeAppUpdateEvent>(_onSnooze);
    on<CompleteFlexibleUpdateEvent>(_onCompleteFlexible);
    on<AppUpdatePromptShownEvent>(_onPromptShown);
    on<AppUpdateInstallProgressChanged>(_onInstallProgress);

    // Play emits download/install transitions for the whole app session, so the
    // subscription is opened once and lives as long as the bloc.
    //
    // This bloc is constructed above the router: anything thrown here would
    // fail app startup, so an unavailable platform channel must not escape.
    try {
      _installSubscription = _useCase.installProgress.listen(
        (InstallProgress progress) {
          if (isClosed) return;
          add(AppUpdateInstallProgressChanged(progress));
        },
        // The download is a background nicety — a broken listener leaves the
        // manual "Update" button working rather than surfacing an error.
        onError: (Object error, StackTrace stack) {
          if (kDebugMode) {
            debugPrint('[AppUpdate] install progress stream failed: $error');
          }
        },
        cancelOnError: false,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('[AppUpdate] install progress unavailable: $error');
      }
    }
  }

  final CheckAppUpdateUseCase _useCase;

  /// Null when the platform exposes no install-progress stream.
  StreamSubscription<InstallProgress>? _installSubscription;

  /// Automatic checks closer together than this are skipped, so returning to
  /// the foreground repeatedly does not hammer the endpoint.
  static const Duration _minAutoCheckInterval = Duration(minutes: 30);

  @override
  Future<void> close() {
    _installSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheck(
    CheckAppUpdateEvent event,
    Emitter<AppUpdateState> emit,
  ) async {
    if (state.isChecking) return;

    if (!event.manual && state.check != null && _isThrottled) {
      return;
    }

    emit(
      state.copyWith(
        status: AppUpdateStatus.checking,
        wasManualCheck: event.manual,
        clearError: true,
        clearInfo: true,
      ),
    );

    final Either<AppException, AppUpdateCheck> response = await _useCase
        .checkForUpdate();
    if (emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: AppUpdateStatus.failure,
          errorMessage: event.manual ? failure.errorMessage : null,
        ),
      ),
      (AppUpdateCheck check) {
        if (!check.hasUpdate) {
          emit(
            state.copyWith(
              // An unreachable source is "unknown", not "up to date" — say so
              // when the user asked explicitly.
              status: !check.sourceReachable && event.manual
                  ? AppUpdateStatus.failure
                  : AppUpdateStatus.upToDate,
              check: check,
              promptPending: false,
              errorMessage: !check.sourceReachable && event.manual
                  ? StringConstants.updateCheckFailed
                  : null,
              infoMessage: check.sourceReachable && event.manual
                  ? StringConstants.youAreOnTheLatestVersion
                  : null,
            ),
          );
          return;
        }

        // A manual check always shows the sheet, even inside a snooze window.
        final bool shouldPrompt = event.manual || _useCase.shouldPrompt(check);
        emit(
          state.copyWith(
            status: AppUpdateStatus.updateAvailable,
            check: check,
            promptPending: shouldPrompt,
            clearError: true,
            clearInfo: true,
          ),
        );
      },
    );
  }

  Future<void> _onStartUpdate(
    StartAppUpdateEvent event,
    Emitter<AppUpdateState> emit,
  ) async {
    final AppUpdateCheck? check = state.check;
    if (check == null || state.isStartingUpdate) return;

    emit(state.copyWith(isStartingUpdate: true, clearError: true));

    final PlayFlowOutcome outcome = await _useCase.startUpdate(check);
    if (emit.isDone) return;

    switch (outcome) {
      case PlayFlowOutcome.started:
        emit(state.copyWith(isStartingUpdate: false, clearError: true));
      case PlayFlowOutcome.userDenied:
        emit(
          state.copyWith(
            isStartingUpdate: false,
            // A denied *forced* update leaves the blocking screen in place with
            // an explanation rather than letting the user through.
            errorMessage: check.isForced
                ? StringConstants.updateRequiredToContinue
                : null,
          ),
        );
      case PlayFlowOutcome.failed:
      case PlayFlowOutcome.unavailable:
        emit(
          state.copyWith(
            isStartingUpdate: false,
            errorMessage: StringConstants.couldNotOpenTheStore,
          ),
        );
    }
  }

  Future<void> _onOpenStore(
    OpenStoreEvent event,
    Emitter<AppUpdateState> emit,
  ) async {
    final AppUpdateCheck? check = state.check;
    if (check == null) return;

    emit(state.copyWith(isStartingUpdate: true, clearError: true));
    final bool opened = await _useCase.openStore(check);
    if (emit.isDone) return;

    emit(
      state.copyWith(
        isStartingUpdate: false,
        errorMessage: opened ? null : StringConstants.couldNotOpenTheStore,
        clearError: opened,
      ),
    );
  }

  Future<void> _onSnooze(
    SnoozeAppUpdateEvent event,
    Emitter<AppUpdateState> emit,
  ) async {
    final AppUpdateCheck? check = state.check;
    // A forced update cannot be postponed.
    if (check == null || check.isForced) return;

    await _useCase.snooze(check, duration: event.duration);
    if (emit.isDone) return;
    emit(state.copyWith(promptPending: false, clearError: true));
  }

  Future<void> _onCompleteFlexible(
    CompleteFlexibleUpdateEvent event,
    Emitter<AppUpdateState> emit,
  ) async {
    if (!state.isReadyToInstall) return;

    final bool completed = await _useCase.completeFlexibleUpdate();
    if (emit.isDone || completed) return;

    // The install could not be handed to Play — offer the store as a fallback.
    emit(state.copyWith(errorMessage: StringConstants.updateInstallFailed));
  }

  void _onPromptShown(
    AppUpdatePromptShownEvent event,
    Emitter<AppUpdateState> emit,
  ) {
    emit(state.copyWith(promptPending: false));
  }

  void _onInstallProgress(
    AppUpdateInstallProgressChanged event,
    Emitter<AppUpdateState> emit,
  ) {
    emit(
      state.copyWith(
        installProgress: event.progress,
        errorMessage: event.progress == InstallProgress.failed
            ? StringConstants.updateDownloadFailed
            : null,
        clearError: !event.progress.isTerminalFailure,
      ),
    );
  }

  bool get _isThrottled {
    final DateTime? lastChecked = AppSettings().updateLastCheckedAt;
    if (lastChecked == null) return false;
    return DateTime.now().difference(lastChecked) < _minAutoCheckInterval;
  }
}
