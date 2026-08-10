import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/domain/model/paginated_bookings.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._useCase) : super(const BookingState()) {
    on<FetchMyBookingsEvent>(_onFetchMyBookings);
    on<FetchFutsalBookingsEvent>(_onFetchFutsalBookings);
  }

  final GetBookingsUseCase _useCase;

  FutureOr<void> _onFetchMyBookings(
    FetchMyBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(
          myBookingsStatus: BookingLoadStatus.loading,
          clearMyError: true,
        ),
      );
    }

    if (event.loadMore && (!state.myHasMorePages || state.myIsLoadingMore)) {
      return;
    }
    final int page = event.loadMore ? state.myCurrentPage + 1 : 1;
    if (event.loadMore) {
      emit(state.copyWith(myIsLoadingMore: true, clearMyError: true));
    }

    final Either<AppException, PaginatedBookings> result;
    try {
      result = await _useCase.getMyBookings(page: page, perPage: 10);
    } catch (error) {
      // Anything the layers below fail to turn into a Left (a socket drop, a
      // token-refresh crash) would otherwise escape this handler and leave the
      // status on `loading` — an endless skeleton with no way back. Surface it
      // as a failure so the list shows its error view with a retry.
      emit(
        state.copyWith(
          myBookingsStatus: event.loadMore
              ? BookingLoadStatus.success
              : BookingLoadStatus.failure,
          myBookingsError: _messageFor(error),
          myIsLoadingMore: false,
          refreshTick: state.refreshTick + 1,
        ),
      );
      return;
    }
    result.fold(
      (error) => emit(
        state.copyWith(
          myBookingsStatus: event.loadMore
              ? BookingLoadStatus.success
              : BookingLoadStatus.failure,
          myBookingsError: error.errorMessage,
          myIsLoadingMore: false,
          refreshTick: state.refreshTick + 1,
        ),
      ),
      (pageResult) => emit(
        state.copyWith(
          myBookingsStatus: BookingLoadStatus.success,
          myBookings: event.loadMore
              ? _mergeBookings(state.myBookings, pageResult.items)
              : pageResult.items,
          myCurrentPage: pageResult.currentPage,
          myLastPage: pageResult.lastPage,
          myTotal: pageResult.total,
          myHasMorePages: pageResult.hasMorePages,
          myIsLoadingMore: false,
          clearMyError: true,
          refreshTick: state.refreshTick + 1,
        ),
      ),
    );
  }

  FutureOr<void> _onFetchFutsalBookings(
    FetchFutsalBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(
          futsalBookingsStatus: BookingLoadStatus.loading,
          clearFutsalError: true,
        ),
      );
    }

    if (event.loadMore &&
        (!state.futsalHasMorePages || state.futsalIsLoadingMore)) {
      return;
    }
    final int page = event.loadMore ? state.futsalCurrentPage + 1 : 1;
    if (event.loadMore) {
      emit(state.copyWith(futsalIsLoadingMore: true, clearFutsalError: true));
    }

    final Either<AppException, PaginatedBookings> result;
    try {
      result = await _useCase.getFutsalBookings(page: page, perPage: 10);
    } catch (error) {
      emit(
        state.copyWith(
          futsalBookingsStatus: event.loadMore
              ? BookingLoadStatus.success
              : BookingLoadStatus.failure,
          futsalBookingsError: _messageFor(error),
          futsalIsLoadingMore: false,
          refreshTick: state.refreshTick + 1,
        ),
      );
      return;
    }
    result.fold(
      (error) => emit(
        state.copyWith(
          futsalBookingsStatus: event.loadMore
              ? BookingLoadStatus.success
              : BookingLoadStatus.failure,
          futsalBookingsError: error.errorMessage,
          futsalIsLoadingMore: false,
          refreshTick: state.refreshTick + 1,
        ),
      ),
      (pageResult) => emit(
        state.copyWith(
          futsalBookingsStatus: BookingLoadStatus.success,
          futsalBookings: event.loadMore
              ? _mergeBookings(state.futsalBookings, pageResult.items)
              : pageResult.items,
          futsalCurrentPage: pageResult.currentPage,
          futsalLastPage: pageResult.lastPage,
          futsalTotal: pageResult.total,
          futsalHasMorePages: pageResult.hasMorePages,
          futsalIsLoadingMore: false,
          clearFutsalError: true,
          refreshTick: state.refreshTick + 1,
        ),
      ),
    );
  }

  List<BookingModel> _mergeBookings(
    List<BookingModel> existing,
    List<BookingModel> incoming,
  ) {
    final Map<int, BookingModel> byId = <int, BookingModel>{
      for (final BookingModel booking in existing) booking.id: booking,
      for (final BookingModel booking in incoming) booking.id: booking,
    };
    return byId.values.toList(growable: false);
  }

  /// Readable text for an exception that never became an [AppException].
  String _messageFor(Object error) {
    if (error is AppException) {
      final String message = error.errorMessage.trim();
      if (message.isNotEmpty) return message;
    }
    if (error is SocketException || error is TimeoutException) {
      return 'No internet connection. Check your network and try again.';
    }
    return 'Something went wrong while loading bookings. Please try again.';
  }
}
