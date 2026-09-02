import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/app_update/data/model/app_update_manifest_model.dart';
import 'package:hamro_futsal/features/app_update/domain/entities/app_version.dart';

/// How hard the user should be pushed to update.
enum UpdateRequirement {
  /// The installed build is current (or newer than the manifest).
  none,

  /// A newer build exists but the installed one still works.
  optional,

  /// The installed build is below the minimum supported version, or the
  /// release was flagged mandatory — the app must not be usable until updated.
  forced,
}

/// The result of one update check: what is installed, what is published, and
/// what we intend to do about it.
final class AppUpdateCheck extends Equatable {
  const AppUpdateCheck({
    required this.currentVersion,
    required this.currentBuild,
    required this.requirement,
    this.packageName = '',
    this.manifest,
    this.sourceReachable = true,
    this.playUpdateAvailable = false,
    this.playImmediateAllowed = false,
    this.playFlexibleAllowed = false,
    this.playStalenessDays,
    this.playPriority,
  });

  /// A check that produced no available update — used when every source fails
  /// silently, so a network blip never blocks the app.
  factory AppUpdateCheck.upToDate({
    required AppVersion currentVersion,
    required int currentBuild,
    String packageName = '',
  }) {
    return AppUpdateCheck(
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      packageName: packageName,
      requirement: UpdateRequirement.none,
    );
  }

  final AppVersion currentVersion;
  final int currentBuild;
  final UpdateRequirement requirement;

  /// Android application id / iOS bundle id, used to build a store link when
  /// the manifest carries none.
  final String packageName;

  /// The remote release information behind this decision. Null when no source
  /// could be reached, in which case [requirement] is always
  /// [UpdateRequirement.none].
  final AppUpdateManifestModel? manifest;

  /// Whether any version source actually answered. False means "we do not know"
  /// rather than "up to date" — the silent launch check ignores the difference,
  /// the manual "Check for updates" action reports it.
  final bool sourceReachable;

  // ── Google Play in-app update capabilities (Android only) ──

  /// Whether Play itself reports an update for this package. Only when this is
  /// true can the native flow be started — Play refuses otherwise (for example
  /// on a sideloaded or debug build).
  final bool playUpdateAvailable;
  final bool playImmediateAllowed;
  final bool playFlexibleAllowed;

  /// Days since the Play Store learnt about the update — the signal Google
  /// recommends for escalating a nag into a block.
  final int? playStalenessDays;

  /// Developer-set Play update priority (0–5).
  final int? playPriority;

  bool get hasUpdate => requirement != UpdateRequirement.none;
  bool get isForced => requirement == UpdateRequirement.forced;
  bool get isOptional => requirement == UpdateRequirement.optional;

  /// Whether the native Play flow can be driven for this check.
  bool get canUsePlayFlow =>
      playUpdateAvailable && (playImmediateAllowed || playFlexibleAllowed);

  String get latestVersionLabel => manifest?.latestVersion.toString() ?? '';
  String get currentVersionLabel => currentVersion.toString();
  List<String> get releaseNotes => manifest?.releaseNotes ?? const <String>[];
  String? get storeUrl => manifest?.storeUrl;

  AppUpdateCheck copyWith({
    UpdateRequirement? requirement,
    AppUpdateManifestModel? manifest,
    bool? sourceReachable,
    bool? playUpdateAvailable,
    bool? playImmediateAllowed,
    bool? playFlexibleAllowed,
    int? playStalenessDays,
    int? playPriority,
  }) {
    return AppUpdateCheck(
      currentVersion: currentVersion,
      currentBuild: currentBuild,
      packageName: packageName,
      requirement: requirement ?? this.requirement,
      manifest: manifest ?? this.manifest,
      sourceReachable: sourceReachable ?? this.sourceReachable,
      playUpdateAvailable: playUpdateAvailable ?? this.playUpdateAvailable,
      playImmediateAllowed: playImmediateAllowed ?? this.playImmediateAllowed,
      playFlexibleAllowed: playFlexibleAllowed ?? this.playFlexibleAllowed,
      playStalenessDays: playStalenessDays ?? this.playStalenessDays,
      playPriority: playPriority ?? this.playPriority,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    currentVersion,
    currentBuild,
    packageName,
    requirement,
    manifest,
    sourceReachable,
    playUpdateAvailable,
    playImmediateAllowed,
    playFlexibleAllowed,
    playStalenessDays,
    playPriority,
  ];
}
