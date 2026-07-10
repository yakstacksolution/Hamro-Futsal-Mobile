import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_details_bloc/booking_details_bloc.dart';

void main() {
  group('BookingBloc', () {
    test('loads my bookings from the repository', () async {
      final _FakeBookingRepository repository = _FakeBookingRepository();
      final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
      addTearDown(bloc.close);

      final Future<BookingState> loading = bloc.stream.firstWhere(
        (BookingState state) =>
            state.myBookingsStatus == BookingLoadStatus.loading,
      );
      final Future<BookingState> loaded = bloc.stream.firstWhere(
        (BookingState state) =>
            state.myBookingsStatus == BookingLoadStatus.success,
      );

      bloc.add(const FetchMyBookingsEvent());

      await loading;
      final BookingState state = await loaded;
      expect(repository.myBookingsCalls, 1);
      expect(state.myBookings, <BookingModel>[repository.booking]);
      expect(state.myBookingsError, isNull);
    });

    test('surfaces futsal booking errors', () async {
      final _FakeBookingRepository repository = _FakeBookingRepository(
        futsalError: DefaultException(
          errorMessage: 'Futsal access is unavailable.',
          statusCode: 403,
        ),
      );
      final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
      addTearDown(bloc.close);

      final Future<BookingState> failed = bloc.stream.firstWhere(
        (BookingState state) =>
            state.futsalBookingsStatus == BookingLoadStatus.failure,
      );

      bloc.add(const FetchFutsalBookingsEvent());

      final BookingState state = await failed;
      expect(repository.futsalBookingsCalls, 1);
      expect(state.futsalBookings, isEmpty);
      expect(state.futsalBookingsError, 'Futsal access is unavailable.');
    });
  });

  group('BookingDetailsBloc', () {
    test('verify payment does not accept the booking', () async {
      final BookingModel pendingBooking = BookingModel.fromJson(
        <String, dynamic>{
          'id': 5,
          'booking_date': '2026-08-12',
          'start_time': '18:00:00',
          'end_time': '19:00:00',
          'booking_status': 'pending',
          'total_amount': 1080,
          'payment': <String, dynamic>{
            'id': 13,
            'payment_method': 'cash',
            'amount': 1080,
            'verification_status': 'pending',
            'has_payment_proof': true,
          },
        },
      );
      final BookingModel approvedVerifyResponse = BookingModel.fromJson(
        <String, dynamic>{
          'id': 5,
          'booking_date': '2026-08-12',
          'start_time': '18:00:00',
          'end_time': '19:00:00',
          'booking_status': 'approved',
          'total_amount': 1080,
          'payment': <String, dynamic>{
            'id': 13,
            'payment_method': 'cash',
            'amount': 1080,
            'verification_status': 'verified',
            'has_payment_proof': true,
          },
        },
      );
      final _FakeBookingRepository repository = _FakeBookingRepository(
        booking: pendingBooking,
        verifyBookingResult: approvedVerifyResponse,
      );
      final BookingDetailsBloc bloc = BookingDetailsBloc(
        GetBookingsUseCase(repository),
        initialBooking: pendingBooking,
        isFutsalView: true,
      );
      addTearDown(bloc.close);

      final Future<BookingDetailsState> verified = bloc.stream.firstWhere(
        (BookingDetailsState state) =>
            state.paymentStatus == PaymentActionStatus.verified,
      );

      bloc.add(
        const VerifyPaymentEvent(
          bookingId: 5,
          paymentId: 13,
          actualAmount: 1080,
          note: 'Received in full',
        ),
      );

      final BookingDetailsState state = await verified;
      expect(repository.verifyPaymentCalls, 1);
      expect(repository.acceptBookingCalls, 0);
      expect(state.booking.status, BookingStatus.pending);
      expect(state.booking.payment?.verificationStatus, 'verified');
    });

    test(
      'confirmed reject failure hides pending booking decision state',
      () async {
        final BookingModel pendingBooking =
            BookingModel.fromJson(<String, dynamic>{
              'id': 6,
              'booking_date': '2026-08-12',
              'start_time': '18:00:00',
              'end_time': '19:00:00',
              'booking_status': 'pending',
              'total_amount': 1080,
            });
        final _FakeBookingRepository repository = _FakeBookingRepository(
          booking: pendingBooking,
          rejectBookingError: DefaultException(
            errorMessage:
                'This booking cannot be rejected because it is already confirmed.',
            statusCode: 422,
          ),
        );
        final BookingDetailsBloc bloc = BookingDetailsBloc(
          GetBookingsUseCase(repository),
          initialBooking: pendingBooking,
          isFutsalView: true,
        );
        addTearDown(bloc.close);

        final Future<BookingDetailsState> failed = bloc.stream.firstWhere(
          (BookingDetailsState state) =>
              state.decisionStatus == DecisionStatus.failure,
        );

        bloc.add(const RejectBookingEvent(bookingId: 6));

        final BookingDetailsState state = await failed;
        expect(repository.rejectBookingCalls, 1);
        expect(state.booking.status, BookingStatus.confirmed);
        expect(
          state.errorMessage,
          'This booking cannot be rejected because it is already confirmed.',
        );
      },
    );
  });
}

final class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({
    this.futsalError,
    BookingModel? booking,
    this.verifyBookingResult,
    this.rejectBookingError,
  }) : booking =
           booking ??
           BookingModel(
             id: 1,
             bookingRef: 'HF-1',
             courtName: 'Court A',
             futsalName: 'Goal Arena',
             date: DateTime(2026, 7, 4),
             startTime: '18:00',
             endTime: '19:00',
             status: BookingStatus.confirmed,
             amount: 1800,
           );

  final AppException? futsalError;
  final BookingModel? verifyBookingResult;
  final AppException? rejectBookingError;
  int myBookingsCalls = 0;
  int futsalBookingsCalls = 0;
  int verifyPaymentCalls = 0;
  int acceptBookingCalls = 0;
  int rejectBookingCalls = 0;

  final BookingModel booking;

  @override
  Future<Either<AppException, List<BookingModel>>> getMyBookings() async {
    myBookingsCalls++;
    return right(<BookingModel>[booking]);
  }

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(
    int bookingId,
  ) async {
    return right(booking);
  }

  @override
  Future<Either<AppException, List<BookingModel>>> getFutsalBookings() async {
    futsalBookingsCalls++;
    final AppException? error = futsalError;
    return error == null
        ? right(<BookingModel>[booking])
        : left<AppException, List<BookingModel>>(error);
  }

  @override
  Future<Either<AppException, BookingModel?>> cancelBooking(
    int bookingId,
  ) async => right(booking);

  @override
  Future<Either<AppException, bool>> getCancelBoundary(int bookingId) async =>
      right(true);

  @override
  Future<Either<AppException, BookingModel?>> verifyBookingPayment({
    required int bookingId,
    required int paymentId,
    required double actualAmount,
    String? note,
  }) async {
    verifyPaymentCalls++;
    return right(verifyBookingResult ?? booking);
  }

  @override
  Future<Either<AppException, BookingModel?>> rejectBookingPayment({
    required int bookingId,
    required int paymentId,
    String? note,
  }) async => right(booking);

  @override
  Future<Either<AppException, BookingModel?>> acceptBooking({
    required int bookingId,
  }) async {
    acceptBookingCalls++;
    return right(booking);
  }

  @override
  Future<Either<AppException, BookingModel?>> rejectBooking({
    required int bookingId,
    String? note,
  }) async {
    rejectBookingCalls++;
    final AppException? error = rejectBookingError;
    return error == null ? right(booking) : left(error);
  }
}
