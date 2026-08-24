import 'package:equatable/equatable.dart';

/// A single in-app notification. IDs are strings because the backend uses UUID
/// identifiers for its notifications.
class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.readAt,
    this.createdAt,
    this.data = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String body;

  /// Raw notification type (e.g. `App\Notifications\BookingConfirmed`).
  final String type;
  final DateTime? readAt;
  final DateTime? createdAt;

  /// The notification payload — carries deep-link ids such as `booking_id`.
  final Map<String, dynamic> data;

  bool get isRead => readAt != null;

  NotificationModel copyWith({DateTime? readAt, bool clearReadAt = false}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      readAt: clearReadAt ? null : readAt ?? this.readAt,
      createdAt: createdAt,
      data: data,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Laravel notifications nest their content under `data`; some backends
    // instead flatten it onto the top-level object — support both.
    final Map<String, dynamic> payload = _mapOf(json['data']);
    final Map<String, dynamic> merged = <String, dynamic>{...json, ...payload};

    return NotificationModel(
      id: _asString(json['id'] ?? merged['id']) ?? '',
      title:
          _asString(
            merged['title'] ??
                merged['heading'] ??
                merged['subject'] ??
                merged['name'],
          ) ??
          '',
      body:
          _asString(
            merged['body'] ??
                merged['message'] ??
                merged['description'] ??
                merged['content'],
          ) ??
          '',
      type: _asString(json['type'] ?? merged['type']) ?? '',
      readAt: _asNullableDate(json['read_at'] ?? merged['read_at']),
      createdAt: _asNullableDate(
        json['created_at'] ?? merged['created_at'] ?? json['timestamp'],
      ),
      data: payload,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'body': body,
    'type': type,
    'read_at': readAt?.toIso8601String(),
    'created_at': createdAt?.toIso8601String(),
    'data': data,
  };

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    body,
    type,
    readAt,
    createdAt,
    data,
  ];
}

/// A page of notifications plus the server's unread counter.
class NotificationPage extends Equatable {
  const NotificationPage({required this.notifications, this.unreadCount = 0});

  final List<NotificationModel> notifications;
  final int unreadCount;

  factory NotificationPage.fromResponse(dynamic payload) {
    final List<dynamic> rawList = _notificationListFrom(payload);
    final List<NotificationModel> notifications = rawList
        .whereType<Map>()
        .map(
          (dynamic item) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    return NotificationPage(
      notifications: notifications,
      unreadCount:
          _unreadCountFrom(payload) ??
          notifications.where((NotificationModel n) => !n.isRead).length,
    );
  }

  @override
  List<Object?> get props => <Object?>[notifications, unreadCount];
}

List<dynamic> _notificationListFrom(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 8; depth++) {
    if (current is List) return current;
    if (current is! Map) return const <dynamic>[];

    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final dynamic next =
        map['data'] ??
        map['notifications'] ??
        map['items'] ??
        map['records'] ??
        map['results'];
    if (next == null) return const <dynamic>[];
    current = next;
  }
  return const <dynamic>[];
}

int? _unreadCountFrom(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 8; depth++) {
    if (current is! Map) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final int? count = _asInt(
      map['unread_count'] ?? map['unread'] ?? map['unread_notifications'],
    );
    if (count != null) return count;

    final dynamic meta = map['meta'];
    if (meta is Map) {
      final int? metaCount = _asInt(meta['unread_count'] ?? meta['unread']);
      if (metaCount != null) return metaCount;
    }
    current = map['data'];
  }
  return null;
}

Map<String, dynamic> _mapOf(dynamic value) {
  return value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};
}

String? _asString(Object? value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime? _asNullableDate(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString().trim());
}

int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString().trim());
}
