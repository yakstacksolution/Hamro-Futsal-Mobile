import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/app_update/data/model/app_update_manifest_model.dart';
import 'package:hamro_futsal/features/app_update/domain/entities/app_version.dart';

enum UpdateRequirement {
  none,

  optional,

  forced,
}

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

  final String packageName;

  final AppUpdateManifestModel? manifest;

  final bool sourceReachable;

  // ── Google Play in-app update capabilities (Android only) ──

  final bool playUpdateAvailable;
  final bool playImmediateAllowed;
  final bool playFlexibleAllowed;

  final int? playStalenessDays;

  final int? playPriority;

  bool get hasUpdate => requirement != UpdateRequirement.none;
  bool get isForced => requirement == UpdateRequirement.forced;
  bool get isOptional => requirement == UpdateRequirement.optional;

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
