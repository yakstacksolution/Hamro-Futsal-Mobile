import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';

abstract class BookingRemoteDataSource {
  Future<Result> getMyBookings(BookingListQuery query);
  Future<Result> getBookingDetails(int bookingId);
  Future<Result> getFutsalBookings(BookingListQuery query);
  Future<Result> cancelBooking(int bookingId);
  Future<Result> getBookingCancelBoundary(int bookingId);
  Future<Result> getBookingReview(int bookingId);
  Future<Result> submitBookingReview(int bookingId, Map<String, dynamic> data);
  Future<Result> verifyBookingPayment(
    int bookingId,
    int paymentId,
    Map<String, dynamic> data,
  );
  Future<Result> rejectBookingPayment(
    int bookingId,
    int paymentId,
    Map<String, dynamic> data,
  );
  Future<Result> acceptBooking(int bookingId, Map<String, dynamic> data);
  Future<Result> rejectBooking(int bookingId, Map<String, dynamic> data);
}

final class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  @override
  Future<Result> getMyBookings(BookingListQuery query) async =>
      await Client.instance().getAuthManager().getMyBookings(
        query: query.toQueryParameters(),
      );

  @override
  Future<Result> getBookingDetails(int bookingId) async =>
      await Client.instance().getAuthManager().getBookingDetails(bookingId);

  @override
  Future<Result> getFutsalBookings(BookingListQuery query) async =>
      await Client.instance().getAuthManager().getFutsalBookings(
        query: query.toQueryParameters(),
      );

  @override
  Future<Result> cancelBooking(int bookingId) async =>
      await Client.instance().getAuthManager().cancelBooking(bookingId);

  @override
  Future<Result> getBookingCancelBoundary(int bookingId) async =>
      await Client.instance().getAuthManager().getBookingCancelBoundary(
        bookingId,
      );

  @override
  Future<Result> getBookingReview(int bookingId) async =>
      await Client.instance().getAuthManager().getBookingReview(bookingId);

  @override
  Future<Result> submitBookingReview(
    int bookingId,
    Map<String, dynamic> data,
  ) async => await Client.instance().getAuthManager().submitBookingReview(
    bookingId,
    data,
  );

  @override
  Future<Result> verifyBookingPayment(
    int bookingId,
    int paymentId,
    Map<String, dynamic> data,
  ) async => await Client.instance().getAuthManager().verifyBookingPayment(
    bookingId,
    paymentId,
    data,
  );

  @override
  Future<Result> rejectBookingPayment(
    int bookingId,
    int paymentId,
    Map<String, dynamic> data,
  ) async => await Client.instance().getAuthManager().rejectBookingPayment(
    bookingId,
    paymentId,
    data,
  );

  @override
  Future<Result> acceptBooking(
    int bookingId,
    Map<String, dynamic> data,
  ) async =>
      await Client.instance().getAuthManager().acceptBooking(bookingId, data);

  @override
  Future<Result> rejectBooking(
    int bookingId,
    Map<String, dynamic> data,
  ) async =>
      await Client.instance().getAuthManager().rejectBooking(bookingId, data);
}
