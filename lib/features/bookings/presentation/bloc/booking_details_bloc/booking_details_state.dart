part of 'booking_details_bloc.dart';

enum BookingDetailsStatus { idle, loading, success, failure }

final class BookingDetailsState extends Equatable {
  const BookingDetailsState({
    required this.booking,
    this.status = BookingDetailsStatus.idle,
    this.errorMessage,
  });

  final BookingModel booking;
  final BookingDetailsStatus status;
  final String? errorMessage;

  BookingDetailsState copyWith({
    BookingModel? booking,
    BookingDetailsStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingDetailsState(
      booking: booking ?? this.booking,
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[booking, status, errorMessage];
}
