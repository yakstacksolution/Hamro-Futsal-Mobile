import 'package:equatable/equatable.dart';

/// Who a video guide is for. [all] guides show on both sides.
enum HelpVideoAudience {
  player,
  vendor,
  all;

  /// Reads the audience from the API's free-form value (`"player"`,
  /// `"vendor"`, `"both"`, ...). Anything unrecognised — or missing — is
  /// treated as for everyone, so a guide is never hidden by a label typo.
  static HelpVideoAudience fromValue(dynamic value) {
    final String text = value?.toString().trim().toLowerCase() ?? '';
    if (text.isEmpty) return HelpVideoAudience.all;
    if (const <String>{
      'vendor',
      'vendors',
      'futsal',
      'owner',
      'venue',
    }.contains(text)) {
      return HelpVideoAudience.vendor;
    }
    if (const <String>{
      'player',
      'players',
      'user',
      'users',
      'customer',
    }.contains(text)) {
      return HelpVideoAudience.player;
    }
    return HelpVideoAudience.all;
  }

  /// Whether a guide for this audience belongs in the [selected] list.
  bool includes(HelpVideoAudience selected) =>
      this == HelpVideoAudience.all || this == selected;
}

/// A YouTube how-to guide from `GET /youtube-videos`, listed in
/// Help & FAQ → Videos.
final class HelpVideo extends Equatable {
  const HelpVideo({
    required this.id,
    required this.youtubeId,
    required this.title,
    this.description,
    this.category,
    this.duration,
    this.customThumbnailUrl,
    this.audience = HelpVideoAudience.all,
    this.sortOrder = 0,
  });

  final String id;

  /// The 11-character YouTube video id.
  final String youtubeId;
  final String title;
  final String? description;

  /// Short topic label, e.g. "Booking".
  final String? category;

  /// Display length, e.g. "2:45".
  final String? duration;

  /// Thumbnail set on the server; YouTube's own is used when absent.
  final String? customThumbnailUrl;
  final HelpVideoAudience audience;
  final int sortOrder;

  String get thumbnailUrl =>
      customThumbnailUrl ??
      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

  /// Parses one item, or returns null when it has no playable YouTube video or
  /// has been switched off on the server.
  static HelpVideo? tryParse(Map<String, dynamic> json) {
    if (!_isActive(json)) return null;

    final String? youtubeId = youtubeIdFrom(
      json['youtube_id'] ??
          json['video_id'] ??
          json['youtube_url'] ??
          json['youtube_link'] ??
          json['video_url'] ??
          json['url'] ??
          json['link'],
    );
    if (youtubeId == null) return null;

    return HelpVideo(
      id: (json['id'] ?? json['uuid'] ?? youtubeId).toString(),
      youtubeId: youtubeId,
      title: _asString(json['title'] ?? json['name']) ?? '',
      description: _asString(json['description'] ?? json['summary']),
      category: _asString(
        _nestedName(json['category']) ?? json['tag'] ?? json['topic'],
      ),
      duration: _formatDuration(json['duration'] ?? json['length']),
      customThumbnailUrl: _asString(
        json['thumbnail_url'] ??
            json['thumbnail'] ??
            json['image_url'] ??
            json['image'],
      ),
      audience: HelpVideoAudience.fromValue(
        json['audience'] ??
            json['user_type'] ??
            json['target'] ??
            json['type'] ??
            json['role'],
      ),
      sortOrder:
          int.tryParse(
            (json['order_no'] ?? json['sort_order'])?.toString() ?? '',
          ) ??
          0,
    );
  }

  /// Parses the `{data: {videos: [...]}}` envelope (or a bare list), dropping
  /// entries without a video and ordering by `order_no`.
  static List<HelpVideo> listFromResponse(dynamic payload) {
    dynamic current = payload;
    for (int depth = 0; depth < 4 && current is Map; depth++) {
      current =
          current['videos'] ??
          current['youtube_videos'] ??
          current['data'] ??
          current['items'];
    }
    if (current is! List) return const <HelpVideo>[];

    final List<HelpVideo> videos = current
        .whereType<Map>()
        .map((Map item) => tryParse(Map<String, dynamic>.from(item)))
        .whereType<HelpVideo>()
        .toList();
    // Stable: equal sort orders keep the server's order.
    _sortByOrder(videos);
    return List<HelpVideo>.unmodifiable(videos);
  }

  /// Extracts the video id from a bare id or any YouTube link shape —
  /// `watch?v=`, `youtu.be/`, `/shorts/`, `/embed/`, `/live/`.
  static String? youtubeIdFrom(dynamic value) {
    final String? text = _asString(value);
    if (text == null) return null;
    if (_idPattern.hasMatch(text)) return text;

    final Uri? uri = Uri.tryParse(text);
    if (uri == null) return null;
    final String host = uri.host.toLowerCase();
    String? candidate;
    if (host.endsWith('youtu.be')) {
      candidate = uri.pathSegments.isEmpty ? null : uri.pathSegments.first;
    } else if (host.contains('youtube')) {
      candidate = uri.queryParameters['v'];
      if (candidate == null && uri.pathSegments.length >= 2) {
        const Set<String> prefixes = <String>{'shorts', 'embed', 'live', 'v'};
        if (prefixes.contains(uri.pathSegments.first)) {
          candidate = uri.pathSegments[1];
        }
      }
    }
    return candidate != null && _idPattern.hasMatch(candidate)
        ? candidate
        : null;
  }

  static final RegExp _idPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

  @override
  List<Object?> get props => <Object?>[
    id,
    youtubeId,
    title,
    description,
    category,
    duration,
    customThumbnailUrl,
    audience,
    sortOrder,
  ];
}

/// Insertion-based stable sort by [HelpVideo.sortOrder]; lists are short.
void _sortByOrder(List<HelpVideo> videos) {
  for (int i = 1; i < videos.length; i++) {
    final HelpVideo item = videos[i];
    int j = i - 1;
    while (j >= 0 && videos[j].sortOrder > item.sortOrder) {
      videos[j + 1] = videos[j];
      j--;
    }
    videos[j + 1] = item;
  }
}

/// `status` arrives as a bool (`"status": true`); older shapes used an
/// `is_active` flag or a `"active"`/`"published"` string.
bool _isActive(Map<String, dynamic> json) {
  final dynamic flag = json['status'] ?? json['is_active'] ?? json['active'];
  if (flag == null) return true;
  if (flag is bool) return flag;
  final String text = flag.toString().trim().toLowerCase();
  return const <String>{'', '1', 'true', 'active', 'published'}.contains(text);
}

/// "2:45" from either a ready string or a number of seconds.
String? _formatDuration(dynamic value) {
  if (value == null) return null;
  final int? seconds = value is num
      ? value.round()
      : int.tryParse(value.toString().trim());
  if (seconds == null) return _asString(value);
  if (seconds <= 0) return null;
  final int h = seconds ~/ 3600;
  final int m = (seconds % 3600) ~/ 60;
  final String s = (seconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

/// A `name`/`title` from a nested object (`category: {name: "..."}`), or the
/// value itself when it is already a string.
dynamic _nestedName(dynamic value) {
  if (value is Map) return value['name'] ?? value['title'];
  return value;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}
