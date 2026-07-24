part of 'booking_overview_bloc.dart';

enum BookingOverviewStatus { initial, loading, success, failure }

final class BookingOverviewState extends Equatable {
  const BookingOverviewState({
    this.status = BookingOverviewStatus.initial,
    this.overview,
    this.errorMessage,
  });

  final BookingOverviewStatus status;
  final BookingOverviewResponse? overview;
  final String? errorMessage;

  BookingOverviewState copyWith({
    BookingOverviewStatus? status,
    BookingOverviewResponse? overview,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BookingOverviewState(
      status: status ?? this.status,
      overview: overview ?? this.overview,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, overview, errorMessage];
}
