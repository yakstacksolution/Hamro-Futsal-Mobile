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

  final String? dateFilter;

  final String? dateFrom;
  final String? dateTo;

  final List<String>? venueIds;

  @override
  List<Object?> get props => [dateFilter, dateFrom, dateTo, venueIds];
}

final class ExportBookingOverviewEvent extends BookingOverviewEvent {
  const ExportBookingOverviewEvent({
    this.dateFilter,
    this.dateFrom,
    this.dateTo,
    this.venueIds,
  });

  final String? dateFilter;
  final String? dateFrom;
  final String? dateTo;
  final List<String>? venueIds;

  @override
  List<Object?> get props => [dateFilter, dateFrom, dateTo, venueIds];
}
