import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';

abstract class BookingOverviewRepository {
  Future<Either<AppException, List<BookingFutsalModel>>> getFutsals();
  Future<Either<AppException, List<BookingRecordModel>>> getBookings();
}
