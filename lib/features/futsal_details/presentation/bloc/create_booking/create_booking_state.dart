part of 'create_booking_bloc.dart';

enum CreateBookingStatus { idle, submitting, success, failure }

final class CreateBookingState extends Equatable {
  const CreateBookingState({
    this.status = CreateBookingStatus.idle,
    this.result,
    this.errorMessage,
  });

  final CreateBookingStatus status;
  final BookingResultModel? result;
  final String? errorMessage;

  bool get isSubmitting => status == CreateBookingStatus.submitting;

  CreateBookingState copyWith({
    CreateBookingStatus? status,
    BookingResultModel? result,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CreateBookingState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, result, errorMessage];
}
