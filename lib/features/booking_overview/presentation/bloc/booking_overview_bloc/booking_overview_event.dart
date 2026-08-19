part of 'booking_overview_bloc.dart';

sealed class BookingOverviewEvent extends Equatable {
  const BookingOverviewEvent();

  @override
  List<Object?> get props => [];
}

final class LoadBookingOverviewEvent extends BookingOverviewEvent {
  const LoadBookingOverviewEvent({
    this.dateFilter,
    this.dateFrom,
    this.dateTo,
    this.venueIds,
  });

  /// Named window (`today`/`week`/`month`/`year`/`custom`). Null = server default.
  final String? dateFilter;

  /// `yyyy-MM-dd`, only sent alongside a `custom` filter.
  final String? dateFrom;
  final String? dateTo;

  /// Selected venue ids; empty/null means all venues.
  final List<String>? venueIds;

  @override
  List<Object?> get props => [dateFilter, dateFrom, dateTo, venueIds];
}
