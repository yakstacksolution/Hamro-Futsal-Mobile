enum InstallProgress {
  unknown,
  pending,
  downloading,

  downloaded,
  installing,
  installed,
  failed,
  canceled;

  bool get isInFlight =>
      this == InstallProgress.pending ||
      this == InstallProgress.downloading ||
      this == InstallProgress.installing;

  bool get isReadyToInstall => this == InstallProgress.downloaded;

  bool get isTerminalFailure =>
      this == InstallProgress.failed || this == InstallProgress.canceled;
}
