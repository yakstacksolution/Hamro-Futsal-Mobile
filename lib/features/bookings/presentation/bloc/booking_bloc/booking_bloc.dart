import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._useCase) : super(const BookingState()) {
    on<FetchMyBookingsEvent>(_onFetchMyBookings);
    on<FetchFutsalBookingsEvent>(_onFetchFutsalBookings);
  }

  // ignore: unused_field
  final GetBookingsUseCase _useCase;

  FutureOr<void> _onFetchMyBookings(
    FetchMyBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(
      state.copyWith(
        myBookingsStatus: BookingLoadStatus.success,
        myBookings: _demoMyBookings(),
        clearMyError: true,
      ),
    );
  }

  FutureOr<void> _onFetchFutsalBookings(
    FetchFutsalBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(
      state.copyWith(
        futsalBookingsStatus: BookingLoadStatus.success,
        futsalBookings: _demoFutsalBookings(),
        clearFutsalError: true,
      ),
    );
  }

  static List<BookingModel> _demoMyBookings() {
    final now = DateTime.now();
    return <BookingModel>[
      BookingModel(
        id: 101,
        bookingRef: 'HF-10245',
        courtName: 'Arena A',
        futsalName: 'Goal Arena Futsal',
        futsalAddress: 'Baneshwor, Kathmandu',
        date: DateTime(now.year, now.month, now.day),
        startTime: '06:00 PM',
        endTime: '07:00 PM',
        status: BookingStatus.confirmed,
        amount: 1800,
      ),
      BookingModel(
        id: 102,
        bookingRef: 'HF-10246',
        courtName: 'Arena B',
        futsalName: 'Urban Kick Center',
        futsalAddress: 'Jawalakhel, Lalitpur',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
        startTime: '07:30 PM',
        endTime: '09:00 PM',
        status: BookingStatus.pending,
        amount: 2400,
      ),
      BookingModel(
        id: 103,
        bookingRef: 'HF-10198',
        courtName: 'Training Turf',
        futsalName: 'Champion 5A Side',
        futsalAddress: 'Koteshwor, Kathmandu',
        date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 2)),
        startTime: '05:30 AM',
        endTime: '06:30 AM',
        status: BookingStatus.completed,
        amount: 1600,
      ),
      BookingModel(
        id: 104,
        bookingRef: 'HF-10180',
        courtName: 'Arena A',
        futsalName: 'Royal Futsal Hub',
        futsalAddress: 'Bhaktapur',
        date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 5)),
        startTime: '08:00 PM',
        endTime: '09:00 PM',
        status: BookingStatus.cancelled,
        amount: 1700,
      ),
    ];
  }

  static List<BookingModel> _demoFutsalBookings() {
    final now = DateTime.now();
    return <BookingModel>[
      BookingModel(
        id: 201,
        bookingRef: 'HF-20451',
        courtName: 'Arena A',
        futsalName: 'Hamro Futsal',
        date: DateTime(now.year, now.month, now.day),
        startTime: '06:00 PM',
        endTime: '07:00 PM',
        status: BookingStatus.confirmed,
        amount: 1800,
        playerName: 'Rabin Shrestha',
        playerPhone: '+977 98012 34567',
      ),
      BookingModel(
        id: 202,
        bookingRef: 'HF-20452',
        courtName: 'Arena B',
        futsalName: 'Hamro Futsal',
        date: DateTime(now.year, now.month, now.day),
        startTime: '07:30 PM',
        endTime: '09:00 PM',
        status: BookingStatus.pending,
        amount: 2400,
        playerName: 'KTM Strikers',
        playerPhone: '+977 98023 45678',
      ),
      BookingModel(
        id: 203,
        bookingRef: 'HF-20453',
        courtName: 'Training Turf',
        futsalName: 'Hamro Futsal',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
        startTime: '05:30 AM',
        endTime: '06:30 AM',
        status: BookingStatus.confirmed,
        amount: 1600,
        playerName: 'Shivam Bhattarai',
        playerPhone: '+977 98034 56789',
      ),
      BookingModel(
        id: 204,
        bookingRef: 'HF-20444',
        courtName: 'Arena A',
        futsalName: 'Hamro Futsal',
        date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
        startTime: '09:00 PM',
        endTime: '10:00 PM',
        status: BookingStatus.completed,
        amount: 1800,
        playerName: 'Aakash FC',
        playerPhone: '+977 98045 67890',
      ),
      BookingModel(
        id: 205,
        bookingRef: 'HF-20430',
        courtName: 'Arena B',
        futsalName: 'Hamro Futsal',
        date: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 3)),
        startTime: '06:00 PM',
        endTime: '07:00 PM',
        status: BookingStatus.cancelled,
        amount: 1800,
        playerName: 'Pulchowk United',
        playerPhone: '+977 98056 78901',
      ),
    ];
  }
}
