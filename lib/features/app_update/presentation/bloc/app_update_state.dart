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

  final AppUpdateCheck? check;

  final InstallProgress installProgress;

  final bool isStartingUpdate;

  final bool promptPending;

  final bool wasManualCheck;

  final String? errorMessage;
  final String? infoMessage;

  bool get isChecking => status == AppUpdateStatus.checking;
  bool get hasUpdate => check?.hasUpdate ?? false;
  bool get isForced => check?.isForced ?? false;

  bool get isReadyToInstall => installProgress.isReadyToInstall;
  bool get isDownloading => installProgress.isInFlight;

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
