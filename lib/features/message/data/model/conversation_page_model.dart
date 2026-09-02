import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';

final class ConversationPageModel extends Equatable {
  const ConversationPageModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
    required this.hasMorePages,
  });

  final List<ConversationModel> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  /// 1-based index of the first/last item of this page within [total].
  /// Both are 0 when the page came back empty.
  final int from;
  final int to;
  final bool hasMorePages;

  factory ConversationPageModel.fromResponse(dynamic response) {
    final root = _map(response);
    final data = _map(root['data'] ?? root);
    final pagination = _map(data['pagination']);
    final rawItems = data['items'] is List ? data['items'] as List : const [];
    final items = rawItems
        .whereType<Map>()
        .map(
          (item) => ConversationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    final currentPage = _integer(pagination['current_page'], 1);
    final lastPage = _integer(pagination['last_page'], currentPage);
    return ConversationPageModel(
      items: items,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: _integer(pagination['per_page'], items.length),
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
