import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';

final class VenueCourtPageModel extends Equatable {
  const VenueCourtPageModel({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
  });

  final List<VenueCourtModel> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
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
    return VenueCourtPageModel(
      items: items,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: _integer(pagination['per_page'], items.length),
      total: _integer(pagination['total'], items.length),
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
    hasMorePages,
  ];
}
