import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/app_update/domain/entities/app_version.dart';

enum AppUpdateSource { backend, playStore, appStore }

final class AppUpdateManifestModel extends Equatable {
  const AppUpdateManifestModel({
    required this.source,
    required this.latestVersion,
    this.latestBuild,
    this.minSupportedVersion,
    this.minSupportedBuild,
    this.forceUpdate = false,
    this.updateAvailableOverride,
    this.releaseTitle,
    this.releaseNotes = const <String>[],
    this.storeUrl,
    this.downloadSize,
    this.releasedAt,
  });

  final AppUpdateSource source;

  final AppVersion latestVersion;

  final int? latestBuild;

  final AppVersion? minSupportedVersion;
  final int? minSupportedBuild;

  final bool forceUpdate;

  final bool? updateAvailableOverride;

  final String? releaseTitle;

  final List<String> releaseNotes;

  final String? storeUrl;

  final String? downloadSize;
  final DateTime? releasedAt;

  static AppUpdateManifestModel? fromBackendResponse(dynamic response) {
    final Map<String, dynamic>? root = _asMap(response);
    if (root == null) return null;

    final Map<String, dynamic> body = _asMap(root['data']) ?? root;
    final String platformKey = Platform.isIOS ? 'ios' : 'android';

    final Map<String, dynamic> platforms =
        _asMap(body['platforms']) ?? const <String, dynamic>{};
    final Map<String, dynamic> platform =
        _asMap(body[platformKey]) ??
        _asMap(platforms[platformKey]) ??
        const <String, dynamic>{};

    // Platform-specific values win; shared keys at the root are the fallback.
    final Map<String, dynamic> merged = <String, dynamic>{...body, ...platform};

    final AppVersion? latest = AppVersion.tryParse(
      _string(merged, const <String>[
        'latest_version',
        'latestVersion',
        'version',
        'latest',
        'current_version',
      ]),
    );
    if (latest == null) return null;

    return AppUpdateManifestModel(
      source: AppUpdateSource.backend,
      latestVersion: latest,
      latestBuild: _int(merged, const <String>[
        'latest_build',
        'latestBuild',
        'build',
        'build_number',
        'version_code',
        'versionCode',
      ]),
      minSupportedVersion: AppVersion.tryParse(
        _string(merged, const <String>[
          'min_supported_version',
          'minSupportedVersion',
          'min_version',
          'minimum_version',
          'min_required_version',
        ]),
      ),
      minSupportedBuild: _int(merged, const <String>[
        'min_supported_build',
        'minSupportedBuild',
        'min_build',
        'minimum_build',
      ]),
      forceUpdate:
          _bool(merged, const <String>[
            'force_update',
            'forceUpdate',
            'is_force_update',
            'force',
            'mandatory',
            'is_mandatory',
          ]) ??
          false,
      updateAvailableOverride: _bool(merged, const <String>[
        'update_available',
        'updateAvailable',
        'has_update',
      ]),
      releaseTitle: _string(merged, const <String>[
        'release_title',
        'title',
        'headline',
      ]),
      releaseNotes: _notes(
        merged['release_notes'] ??
            merged['releaseNotes'] ??
            merged['changelog'] ??
            merged['whats_new'] ??
            merged['notes'] ??
            merged['description'],
      ),
      storeUrl: _string(merged, <String>[
        Platform.isIOS ? 'app_store_url' : 'play_store_url',
        Platform.isIOS ? 'appStoreUrl' : 'playStoreUrl',
        'store_url',
        'storeUrl',
        'url',
        'download_url',
      ]),
      downloadSize: _string(merged, const <String>[
        'download_size',
        'downloadSize',
        'size',
      ]),
      releasedAt: _dateTime(merged, const <String>[
        'released_at',
        'releasedAt',
        'release_date',
        'published_at',
      ]),
    );
  }

  static AppUpdateManifestModel? fromAppStoreResponse(dynamic response) {
    final Map<String, dynamic>? root = _asMap(response);
    final dynamic results = root?['results'];
    if (results is! List || results.isEmpty) return null;

    final Map<String, dynamic>? entry = _asMap(results.first);
    if (entry == null) return null;

    final AppVersion? latest = AppVersion.tryParse(entry['version'] as String?);
    if (latest == null) return null;

    return AppUpdateManifestModel(
      source: AppUpdateSource.appStore,
      latestVersion: latest,
      releaseNotes: _notes(entry['releaseNotes']),
      storeUrl: (entry['trackViewUrl'] ?? entry['sellerUrl']) as String?,
      releasedAt: DateTime.tryParse(
        (entry['currentVersionReleaseDate'] ?? '').toString(),
      ),
    );
  }

  AppUpdateManifestModel copyWith({String? storeUrl}) {
    return AppUpdateManifestModel(
      source: source,
      latestVersion: latestVersion,
      latestBuild: latestBuild,
      minSupportedVersion: minSupportedVersion,
      minSupportedBuild: minSupportedBuild,
      forceUpdate: forceUpdate,
      updateAvailableOverride: updateAvailableOverride,
      releaseTitle: releaseTitle,
      releaseNotes: releaseNotes,
      storeUrl: storeUrl ?? this.storeUrl,
      downloadSize: downloadSize,
      releasedAt: releasedAt,
    );
  }

  // ── Parsing helpers ──

  static Map<String, dynamic>? _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  static String? _string(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    return null;
  }

  static int? _int(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final int? parsed = int.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static bool? _bool(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final String normalised = value.trim().toLowerCase();
        if (normalised == 'true' || normalised == '1') return true;
        if (normalised == 'false' || normalised == '0') return false;
      }
    }
    return null;
  }

  static DateTime? _dateTime(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        final DateTime? parsed = DateTime.tryParse(value.trim());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static List<String> _notes(dynamic value) {
    if (value is List) {
      return value
          .map((dynamic item) => item.toString().trim())
          .where((String item) => item.isNotEmpty)
          .toList(growable: false);
    }
    if (value is String) {
      return value
          .split(RegExp(r'[\r\n]+'))
          // Strip a leading bullet/dash so the sheet's own bullets are not
          // doubled up.
          .map(
            (String line) =>
                line.trim().replaceFirst(RegExp(r'^[•*\-•]\s*'), '').trim(),
          )
          .where((String line) => line.isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  @override
  List<Object?> get props => <Object?>[
    source,
    latestVersion,
    latestBuild,
    minSupportedVersion,
    minSupportedBuild,
    forceUpdate,
    updateAvailableOverride,
    releaseTitle,
    releaseNotes,
    storeUrl,
    downloadSize,
    releasedAt,
  ];
}
