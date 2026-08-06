part of 'app_update_bloc.dart';

sealed class AppUpdateEvent extends Equatable {
  const AppUpdateEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Runs a version check.
///
/// [manual] marks a user-initiated check: it bypasses the throttle, ignores a
/// previous "Later", and reports "you're up to date" / failures out loud, where
/// the automatic launch check stays silent.
final class CheckAppUpdateEvent extends AppUpdateEvent {
  const CheckAppUpdateEvent({this.manual = false});

  final bool manual;

  @override
  List<Object?> get props => <Object?>[manual];
}

/// Begins the platform update flow (native Play flow, or a store redirect).
final class StartAppUpdateEvent extends AppUpdateEvent {
  const StartAppUpdateEvent();
}

/// Opens the store listing directly, skipping the native flow. Used by the
/// "Open Play Store"/"Open App Store" escape hatch after a failed native flow.
final class OpenStoreEvent extends AppUpdateEvent {
  const OpenStoreEvent();
}

/// User chose "Later" on an optional update.
final class SnoozeAppUpdateEvent extends AppUpdateEvent {
  const SnoozeAppUpdateEvent({this.duration});

  final Duration? duration;

  @override
  List<Object?> get props => <Object?>[duration];
}

/// Installs an already-downloaded flexible update — this restarts the app.
final class CompleteFlexibleUpdateEvent extends AppUpdateEvent {
  const CompleteFlexibleUpdateEvent();
}

/// Marks the prompt as shown so the gate does not re-present it on every
/// rebuild. Forced updates are unaffected — they are never dismissible.
final class AppUpdatePromptShownEvent extends AppUpdateEvent {
  const AppUpdatePromptShownEvent();
}

/// Internal: Play reported new download/install progress.
final class AppUpdateInstallProgressChanged extends AppUpdateEvent {
  const AppUpdateInstallProgressChanged(this.progress);

  final InstallProgress progress;

  @override
  List<Object?> get props => <Object?>[progress];
}
