part of 'app_update_bloc.dart';

enum AppUpdateStatus { idle, checking, upToDate, updateAvailable, failure }

final class AppUpdateState extends Equatable {
  const AppUpdateState({
    this.status = AppUpdateStatus.idle,
    this.check,
    this.installProgress = InstallProgress.unknown,
    this.isStartingUpdate = false,
    this.promptPending = false,
    this.wasManualCheck = false,
    this.errorMessage,
    this.infoMessage,
  });

  final AppUpdateStatus status;

  /// Result of the most recent check. Kept across a later failed check so the
  /// UI does not lose a known-pending update.
  final AppUpdateCheck? check;

  /// Progress of a running background (flexible) download on Android.
  final InstallProgress installProgress;

  /// Whether the update flow is being handed to Play / the store right now.
  final bool isStartingUpdate;

  /// Set when a prompt is due and has not been presented yet. The gate consumes
  /// it via [AppUpdatePromptShownEvent] so the sheet is shown exactly once per
  /// check.
  final bool promptPending;

  /// Whether the last check was user-initiated — drives whether "up to date"
  /// and failures are surfaced.
  final bool wasManualCheck;

  final String? errorMessage;
  final String? infoMessage;

  bool get isChecking => status == AppUpdateStatus.checking;
  bool get hasUpdate => check?.hasUpdate ?? false;
  bool get isForced => check?.isForced ?? false;

  /// True once a flexible download has finished — the UI offers "Restart to
  /// install" instead of "Update".
  bool get isReadyToInstall => installProgress.isReadyToInstall;
  bool get isDownloading => installProgress.isInFlight;

  /// Whether the blocking screen must be shown. Deliberately independent of
  /// [promptPending]: a forced update is not a prompt that can be consumed.
  bool get shouldBlockApp => isForced;

  AppUpdateState copyWith({
    AppUpdateStatus? status,
    AppUpdateCheck? check,
    InstallProgress? installProgress,
    bool? isStartingUpdate,
    bool? promptPending,
    bool? wasManualCheck,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
  }) {
    return AppUpdateState(
      status: status ?? this.status,
      check: check ?? this.check,
      installProgress: installProgress ?? this.installProgress,
      isStartingUpdate: isStartingUpdate ?? this.isStartingUpdate,
      promptPending: promptPending ?? this.promptPending,
      wasManualCheck: wasManualCheck ?? this.wasManualCheck,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    check,
    installProgress,
    isStartingUpdate,
    promptPending,
    wasManualCheck,
    errorMessage,
    infoMessage,
  ];
}
