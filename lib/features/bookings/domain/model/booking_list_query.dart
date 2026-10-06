import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';

enum BookingDateOrder {
  ascending('asc'),
  descending('desc');

  const BookingDateOrder(this.query);

  final String query;
}

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

  final String status;

  final BookingDateFilter dateFilter;
  final BookingDateOrder order;

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
