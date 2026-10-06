import 'package:equatable/equatable.dart';

enum HelpVideoAudience {
  player,
  vendor,
  all;

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

  bool includes(HelpVideoAudience selected) =>
      this == HelpVideoAudience.all || this == selected;
}

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

  final String youtubeId;
  final String title;
  final String? description;

  final String? category;

  final String? duration;

  final String? customThumbnailUrl;
  final HelpVideoAudience audience;
  final int sortOrder;

  String get thumbnailUrl =>
      customThumbnailUrl ??
      'https://img.youtube.com/vi/$youtubeId/hqdefault.jpg';

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

bool _isActive(Map<String, dynamic> json) {
  final dynamic flag = json['status'] ?? json['is_active'] ?? json['active'];
  if (flag == null) return true;
  if (flag is bool) return flag;
  final String text = flag.toString().trim().toLowerCase();
  return const <String>{'', '1', 'true', 'active', 'published'}.contains(text);
}

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

dynamic _nestedName(dynamic value) {
  if (value is Map) return value['name'] ?? value['title'];
  return value;
}

String? _asString(dynamic value) {
  if (value == null) return null;
  final String text = value.toString().trim();
  return text.isEmpty ? null : text;
}
