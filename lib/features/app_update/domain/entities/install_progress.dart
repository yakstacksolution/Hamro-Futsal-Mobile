/// Platform-agnostic view of a background (flexible) update's install state.
///
/// Mirrors Google Play's `InstallStatus`, but kept free of any plugin type so
/// the domain and presentation layers do not depend on the Android SDK.
enum InstallProgress {
  unknown,
  pending,
  downloading,

  /// Fully downloaded and waiting for the app to restart to install.
  downloaded,
  installing,
  installed,
  failed,
  canceled;

  bool get isInFlight =>
      this == InstallProgress.pending ||
      this == InstallProgress.downloading ||
      this == InstallProgress.installing;

  /// Whether the user now needs to be offered a "Restart to install" action.
  bool get isReadyToInstall => this == InstallProgress.downloaded;

  bool get isTerminalFailure =>
      this == InstallProgress.failed || this == InstallProgress.canceled;
}
