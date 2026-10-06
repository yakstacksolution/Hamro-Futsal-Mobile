part of 'app_update_bloc.dart';

sealed class AppUpdateEvent extends Equatable {
  const AppUpdateEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class CheckAppUpdateEvent extends AppUpdateEvent {
  const CheckAppUpdateEvent({this.manual = false});

  final bool manual;

  @override
  List<Object?> get props => <Object?>[manual];
}

final class StartAppUpdateEvent extends AppUpdateEvent {
  const StartAppUpdateEvent();
}

final class OpenStoreEvent extends AppUpdateEvent {
  const OpenStoreEvent();
}

final class SnoozeAppUpdateEvent extends AppUpdateEvent {
  const SnoozeAppUpdateEvent({this.duration});

  final Duration? duration;

  @override
  List<Object?> get props => <Object?>[duration];
}

final class CompleteFlexibleUpdateEvent extends AppUpdateEvent {
  const CompleteFlexibleUpdateEvent();
}

final class AppUpdatePromptShownEvent extends AppUpdateEvent {
  const AppUpdatePromptShownEvent();
}

final class AppUpdateInstallProgressChanged extends AppUpdateEvent {
  const AppUpdateInstallProgressChanged(this.progress);

  final InstallProgress progress;

  @override
  List<Object?> get props => <Object?>[progress];
}
