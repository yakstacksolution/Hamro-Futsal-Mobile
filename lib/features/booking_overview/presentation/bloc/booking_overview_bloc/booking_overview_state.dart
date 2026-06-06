part of 'booking_overview_bloc.dart';

enum BookingOverviewStatus { initial, loading, success, failure }

final class BookingOverviewState extends Equatable {
  const BookingOverviewState({
    this.status = BookingOverviewStatus.initial,
    this.futsals = const [],
    this.bookings = const [],
    this.errorMessage,
  });

  final BookingOverviewStatus status;
  final List<BookingFutsalModel> futsals;
  final List<BookingRecordModel> bookings;
  final String? errorMessage;

  BookingOverviewState copyWith({
    BookingOverviewStatus? status,
    List<BookingFutsalModel>? futsals,
    List<BookingRecordModel>? bookings,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BookingOverviewState(
      status: status ?? this.status,
      futsals: futsals ?? this.futsals,
      bookings: bookings ?? this.bookings,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, futsals, bookings, errorMessage];
}
