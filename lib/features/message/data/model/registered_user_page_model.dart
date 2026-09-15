import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';

final class RegisteredUserPageModel extends Equatable {
  const RegisteredUserPageModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  final List<ParticipantModel> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  factory RegisteredUserPageModel.fromResponse(
    dynamic response, {
    required int requestedPage,
    required int requestedPerPage,
    required int currentUserId,
  }) {
    final root = _map(response);
    final data = _map(root['data']);
    final list = _listFrom(data) ?? _listFrom(root) ?? const [];
    final pagination = _paginationFrom(root, data);
    final items = list
        .whereType<Map>()
        .map((item) => _participantFromUser(Map<String, dynamic>.from(item)))
        .where((participant) {
          return participant.userId > 0 && participant.userId != currentUserId;
        })
        .toList(growable: false);
    final currentPage = _integer(
      pagination['current_page'] ?? pagination['page'],
      requestedPage,
    );
    final perPage = _integer(
      pagination['per_page'] ?? pagination['perPage'],
      requestedPerPage,
    );
    final lastPage = _integer(
      pagination['last_page'] ?? pagination['lastPage'],
      items.length < perPage ? currentPage : currentPage + 1,
    );
    return RegisteredUserPageModel(
      items: items,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: _integer(pagination['total'], items.length),
      hasMorePages: _boolean(
        pagination['has_more_pages'] ?? pagination['hasMorePages'],
        currentPage < lastPage,
      ),
    );
  }

  static ParticipantModel _participantFromUser(Map<String, dynamic> json) {
    final dynamic avatar =
        json['avatar'] ??
        json['image'] ??
        json['profile_image'] ??
        json['photo'];
    final int id = _firstPositive(<dynamic>[
      json['id'],
      json['user_id'],
      _map(json['user'])['id'],
    ]);
    return ParticipantModel(
      id: id,
      userId: id,
      name:
          (json['name'] ??
                  json['full_name'] ??
                  _map(json['user'])['name'] ??
                  '')
              .toString()
              .trim(),
      email: (json['email'] ?? _map(json['user'])['email'] ?? '')
          .toString()
          .trim(),
      role: (json['role'] ?? '').toString(),
      avatarId: avatar is Map ? _integer(avatar['id'], 0) : null,
      avatarUrl: avatar is Map
          ? (avatar['url'] ?? avatar['path'] ?? '').toString()
          : (avatar ?? '').toString(),
      isOnline: _boolean(json['is_online'] ?? json['online'], false),
      lastSeenAt: DateTime.tryParse(json['last_seen_at']?.toString() ?? ''),
    );
  }

  static Map<String, dynamic> _paginationFrom(
    Map<String, dynamic> root,
    Map<String, dynamic> data,
  ) {
    for (final value in <dynamic>[
      data['pagination'],
      data['meta'],
      root['pagination'],
      root['meta'],
      data,
      root,
    ]) {
      final map = _map(value);
      if (map.containsKey('current_page') ||
          map.containsKey('last_page') ||
          map.containsKey('per_page') ||
          map.containsKey('total')) {
        return map;
      }
    }
    return const <String, dynamic>{};
  }

  static List? _listFrom(Map<String, dynamic> map) {
    for (final key in const ['items', 'users', 'registered_users', 'data']) {
      final dynamic value = map[key];
      if (value is List) return value;
    }
    return null;
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};

  static int _integer(dynamic value, int fallback) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

  static int _firstPositive(Iterable<dynamic> values) {
    for (final value in values) {
      final parsed = _integer(value, 0);
      if (parsed > 0) return parsed;
    }
    return 0;
  }

  static bool _boolean(dynamic value, bool fallback) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    return fallback;
  }

  @override
  List<Object?> get props => <Object?>[
    items,
    currentPage,
    lastPage,
    perPage,
    total,
    hasMorePages,
  ];
}
