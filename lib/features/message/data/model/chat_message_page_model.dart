import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';

/// One page of `/conversations/{id}/messages`.
///
/// The endpoint serves newest-first, so page 1 is the tail of the thread and
/// each further page walks backwards in time. The server may answer with a
/// bare `{data: {items: []}}` (no `pagination` block) — in that case the flags
/// are inferred from how full the page came back.
final class ChatMessagePageModel extends Equatable {
  const ChatMessagePageModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from = 0,
    this.to = 0,
    required this.hasMorePages,
  });

  /// Oldest → newest, ready to append to the rendered thread.
  final List<ChatMessageModel> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  /// 1-based index of the first/last item of this page within [total].
  final int from;
  final int to;

  /// True when older messages remain beyond [currentPage].
  final bool hasMorePages;

  factory ChatMessagePageModel.fromResponse(
    dynamic response, {
    required int requestedPage,
    required int requestedPerPage,
  }) {
    final root = _map(response);
    final data = _map(root['data'] ?? root);
    final pagination = _map(data['pagination'] ?? data['meta']);
    final rawItems = data['items'] is List
        ? data['items'] as List
        : root['data'] is List
        ? root['data'] as List
        : const [];
    final items =
        rawItems
            .whereType<Map>()
            .map(
              (item) =>
                  ChatMessageModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
          // The thread renders oldest → newest; the API sends newest first.
          ..sort((a, b) {
            final byTime = a.createdAt.compareTo(b.createdAt);
            return byTime != 0 ? byTime : a.id.compareTo(b.id);
          });
    final currentPage = _integer(pagination['current_page'], requestedPage);
    final perPage = _integer(pagination['per_page'], requestedPerPage);
    // Without a `last_page`, a full page means "there is probably another".
    final lastPage = _integer(
      pagination['last_page'],
      items.length >= perPage ? currentPage + 1 : currentPage,
    );
    return ChatMessagePageModel(
      items: List.unmodifiable(items),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: _integer(pagination['total'], items.length),
      from: _integer(pagination['from'], items.isEmpty ? 0 : 1),
      to: _integer(pagination['to'], items.length),
      hasMorePages: _boolean(
        pagination['has_more_pages'],
        currentPage < lastPage,
      ),
    );
  }

  static Map<String, dynamic> _map(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};

  static int _integer(dynamic value, int fallback) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

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
    from,
    to,
    hasMorePages,
  ];
}
