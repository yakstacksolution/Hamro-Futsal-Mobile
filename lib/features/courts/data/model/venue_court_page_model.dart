import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';

final class VenueCourtPageModel extends Equatable {
  const VenueCourtPageModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.from = 0,
    this.to = 0,
    required this.hasMorePages,
  });

  final List<VenueCourtModel> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  /// 1-based index of the first and last venue of this page within [total].
  /// Both are 0 when the page came back empty.
  final int from;
  final int to;
  final bool hasMorePages;

  factory VenueCourtPageModel.fromResponse(dynamic response) {
    final Map<String, dynamic> root = _map(response);
    final Map<String, dynamic> data = _map(root['data'] ?? root);
    final Map<String, dynamic> pagination = _map(data['pagination']);
    final List<VenueCourtModel> items = VenueCourtModel.listFromResponse(
      data['items'] ?? data,
    );
    final int currentPage = _integer(pagination['current_page'], 1);
    final int lastPage = _integer(pagination['last_page'], currentPage);
    final int perPage = _integer(pagination['per_page'], items.length);
    return VenueCourtPageModel(
      items: items,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: _integer(pagination['total'], items.length),
      // Derived from the page when the server omits them, so "showing 11-16 of
      // 34" is answerable either way.
      from: _integer(
        pagination['from'],
        items.isEmpty ? 0 : (currentPage - 1) * perPage + 1,
      ),
      to: _integer(
        pagination['to'],
        items.isEmpty ? 0 : (currentPage - 1) * perPage + items.length,
      ),
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
