import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/domain/model/paginated_bookings.dart';
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

    test('sends the endpoint\'s status filter, `all` when none is picked', () async {
      final _FakeBookingRepository repository = _FakeBookingRepository();
      final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
      addTearDown(bloc.close);

      // refreshTick is bumped once per *finished* fetch, so this skips the
      // intermediate emit that clears the old filter's rows.
      int tick = bloc.state.refreshTick;
      Future<BookingState> settled() async {
        final BookingState state = await bloc.stream.firstWhere(
          (BookingState state) => state.refreshTick != tick,
        );
        tick = state.refreshTick;
        return state;
      }

      Future<BookingState> done = settled();
      bloc.add(const FetchMyBookingsEvent());
      await done;
      expect(repository.myStatuses, <String?>['all']);

      // Selecting a status fetches it, from page 1, and makes it the visible
      // one — the `all` rows stay in their own slice.
      done = settled();
      bloc.add(
        const FetchMyBookingsEvent.select(BookingStatusFilter.pending),
      );
      BookingState state = await done;
      expect(repository.myStatuses.last, 'pending');
      expect(state.mySelectedFilter, BookingStatusFilter.pending);
      expect(state.myStatusFilter, BookingStatus.pending);
      expect(state.myCurrentPage, 1);
      expect(state.mySlice(BookingStatusFilter.all).bookings, isNotEmpty);

      // A plain refresh keeps the selected status rather than reverting to all.
      done = settled();
      bloc.add(const FetchMyBookingsEvent(silent: true));
      state = await done;
      expect(repository.myStatuses.last, 'pending');
      expect(state.myStatusFilter, BookingStatus.pending);

      // Selecting a status already loaded is served from state: no request.
      final int calls = repository.myBookingsCalls;
      bloc.add(const FetchMyBookingsEvent.select(BookingStatusFilter.all));
      await Future<void>.delayed(Duration.zero);
      expect(repository.myBookingsCalls, calls);
      expect(bloc.state.mySelectedFilter, BookingStatusFilter.all);
      expect(bloc.state.myBookings, isNotEmpty);

      // …unless it is forced, which is what pull-to-refresh does.
      done = settled();
      bloc.add(
        const FetchMyBookingsEvent.select(
          BookingStatusFilter.all,
          force: true,
        ),
      );
      state = await done;
      expect(repository.myStatuses.last, 'all');
      expect(state.myStatusFilter, isNull);
    });

    test('every status page maps to its query value and back', () {
      expect(
        BookingStatusFilter.values.map((BookingStatusFilter f) => f.query),
        <String>[
          'all',
          'pending',
          'confirmed',
          'completed',
          'cancelled',
          'rejected',
        ],
      );
      for (final BookingStatusFilter filter in BookingStatusFilter.values) {
        expect(BookingStatusFilter.of(filter.status), filter);
      }
      expect(BookingStatus.queryValue(null), 'all');
      expect(BookingStatus.queryValue(BookingStatus.rejected), 'rejected');
    });

    test('landing on a status refetches it without blanking its rows', () async {
      final _FakeBookingRepository repository = _FakeBookingRepository();
      final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
      addTearDown(bloc.close);

      int tick = bloc.state.refreshTick;
      Future<BookingState> settled() async {
        final BookingState state = await bloc.stream.firstWhere(
          (BookingState state) => state.refreshTick != tick,
        );
        tick = state.refreshTick;
        return state;
      }

      Future<BookingState> done = settled();
      bloc.add(const FetchMyBookingsEvent.select(BookingStatusFilter.pending));
      await done;
      final int callsAfterFirstVisit = repository.myBookingsCalls;

      // Coming back to the status asks the endpoint again — the point of the
      // refresh — and the rows already held stay on screen while it does.
      final List<BookingState> emitted = <BookingState>[];
      final StreamSubscription<BookingState> sub = bloc.stream.listen(
        emitted.add,
      );
      done = settled();
      bloc.add(const FetchMyBookingsEvent.refresh(BookingStatusFilter.pending));
      final BookingState state = await done;
      await sub.cancel();

      expect(repository.myBookingsCalls, callsAfterFirstVisit + 1);
      expect(repository.myStatuses.last, 'pending');
      expect(state.mySlice(BookingStatusFilter.pending).bookings, isNotEmpty);
      // No skeleton: nothing along the way dropped the rows or went `loading`.
      for (final BookingState step in emitted) {
        final BookingListSlice slice = step.mySlice(
          BookingStatusFilter.pending,
        );
        expect(slice.loadStatus, BookingLoadStatus.success);
        expect(slice.bookings, isNotEmpty);
      }
      // The refresh announced itself so the page can show its progress line.
      expect(
        emitted.any(
          (BookingState step) =>
              step.mySlice(BookingStatusFilter.pending).isRefreshing,
        ),
        isTrue,
      );
      expect(state.mySlice(BookingStatusFilter.pending).isRefreshing, isFalse);
    });

    test('a second landing while the first is in flight is dropped', () async {
      final _FakeBookingRepository repository = _FakeBookingRepository();
      final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
      addTearDown(bloc.close);

      // Hold the first request open, then swipe onto the same status again.
      repository.myGate = Completer<void>();
      bloc.add(const FetchMyBookingsEvent.refresh(BookingStatusFilter.all));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const FetchMyBookingsEvent.refresh(BookingStatusFilter.all));
      await Future<void>.delayed(Duration.zero);

      // The second is dropped rather than stacked: whichever answered last
      // would otherwise decide what the page shows.
      expect(repository.myBookingsCalls, 1);

      repository.myGate!.complete();
      await bloc.stream.firstWhere(
        (BookingState state) => state.refreshTick > 0,
      );
      expect(repository.myBookingsCalls, 1);
    });

    test('each futsal status keeps its own slice', () async {
      final _FakeBookingRepository repository = _FakeBookingRepository();
      final BookingBloc bloc = BookingBloc(GetBookingsUseCase(repository));
      addTearDown(bloc.close);

      int tick = bloc.state.refreshTick;
      Future<BookingState> settled() async {
        final BookingState state = await bloc.stream.firstWhere(
          (BookingState state) => state.refreshTick != tick,
        );
        tick = state.refreshTick;
        return state;
      }

      Future<BookingState> done = settled();
      bloc.add(const FetchFutsalBookingsEvent());
      await done;

      done = settled();
      bloc.add(
        const FetchFutsalBookingsEvent.select(BookingStatusFilter.cancelled),
      );
      final BookingState state = await done;
      expect(repository.futsalStatuses, <String?>['all', 'cancelled']);
      expect(state.futsalStatusFilter, BookingStatus.cancelled);
      expect(state.futsalCurrentPage, 1);
      // Each status keeps its own slice rather than overwriting one list.
      expect(state.futsalLists.keys, <BookingStatusFilter>[
        BookingStatusFilter.all,
        BookingStatusFilter.cancelled,
      ]);
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
  @override
  Future<Either<AppException, BookingReviewModel?>> getBookingReview(
    int bookingId,
  ) async => right(null);

  @override
  Future<Either<AppException, BookingReviewModel>> submitBookingReview({
    required int bookingId,
    required double rating,
    required String review,
  }) async => right(BookingReviewModel(rating: rating, review: review));

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
  final List<String?> myStatuses = <String?>[];
  Completer<void>? myGate;
  final List<String?> futsalStatuses = <String?>[];
  int verifyPaymentCalls = 0;
  int acceptBookingCalls = 0;
  int rejectBookingCalls = 0;

  final BookingModel booking;

  @override
  Future<Either<AppException, PaginatedBookings>> getMyBookings({
    required int page,
    required int perPage,
    String? status,
  }) async {
    myBookingsCalls++;
    myStatuses.add(status);
    // Lets a test hold a request open, so a second one can be attempted while
    // the first is still out.
    if (myGate != null) await myGate!.future;
    return right(
      PaginatedBookings(
        items: <BookingModel>[booking],
        currentPage: page,
        lastPage: page,
        perPage: perPage,
        total: 1,
        hasMorePages: false,
      ),
    );
  }

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(
    int bookingId,
  ) async {
    return right(booking);
  }

  @override
  Future<Either<AppException, PaginatedBookings>> getFutsalBookings({
    required int page,
    required int perPage,
    String? status,
  }) async {
    futsalBookingsCalls++;
    futsalStatuses.add(status);
    final AppException? error = futsalError;
    return error == null
        ? right(
            PaginatedBookings(
              items: <BookingModel>[booking],
              currentPage: page,
              lastPage: page,
              perPage: perPage,
              total: 1,
              hasMorePages: false,
            ),
          )
        : left<AppException, PaginatedBookings>(error);
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
