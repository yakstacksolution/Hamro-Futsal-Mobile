import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';

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
}

final class _FakeBookingRepository implements BookingRepository {
  _FakeBookingRepository({this.futsalError});

  final AppException? futsalError;
  int myBookingsCalls = 0;
  int futsalBookingsCalls = 0;

  final BookingModel booking = BookingModel(
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
}
