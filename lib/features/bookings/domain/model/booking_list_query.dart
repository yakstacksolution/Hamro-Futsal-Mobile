import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';

/// Which end of the list comes first.
enum BookingDateOrder {
  ascending('asc'),
  descending('desc');

  const BookingDateOrder(this.query);

  /// The value the endpoint's `order` parameter takes.
  final String query;
}

/// Everything a request for a page of bookings is made of.
///
/// Both booking endpoints — `/bookings` and `/futsal-bookings` — take the same
/// parameters, so the payload is built once here and the two data sources only
/// choose a URL. Having one place that produces the map is also the only way
/// to test the contract without a server.
final class BookingListQuery extends Equatable {
  const BookingListQuery({
    required this.page,
    required this.perPage,
    required this.status,
    this.dateFilter = const BookingDateFilter.all(),
    this.order = BookingDateOrder.descending,
  });

  final int page;
  final int perPage;

  /// The server's own filter: `all`, `pending`, `confirmed`, `completed`,
  /// `cancelled` or `rejected`. Sent as given, `all` included.
  final String status;

  final BookingDateFilter dateFilter;
  final BookingDateOrder order;

  /// The query parameters, exactly as they go on the wire.
  Map<String, dynamic> toQueryParameters() => <String, dynamic>{
    'page': page,
    'per_page': perPage,
    if (status.trim().isNotEmpty) 'status': status.trim(),
    ...dateFilter.toQueryParameters(),
    'sort': 'date',
    'order': order.query,
  };

  BookingListQuery copyWith({
    int? page,
    int? perPage,
    String? status,
    BookingDateFilter? dateFilter,
    BookingDateOrder? order,
  }) => BookingListQuery(
    page: page ?? this.page,
    perPage: perPage ?? this.perPage,
    status: status ?? this.status,
    dateFilter: dateFilter ?? this.dateFilter,
    order: order ?? this.order,
  );

  @override
  List<Object?> get props => <Object?>[
    page,
    perPage,
    status,
    dateFilter,
    order,
  ];
}
