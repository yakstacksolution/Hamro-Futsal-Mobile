import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';

abstract class BookingRepository {
  Future<Either<AppException, List<BookingModel>>> getMyBookings();
  Future<Either<AppException, List<BookingModel>>> getFutsalBookings();
}
