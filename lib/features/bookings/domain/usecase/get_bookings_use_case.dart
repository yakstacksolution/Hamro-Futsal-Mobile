import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';

final class GetBookingsUseCase {
  const GetBookingsUseCase(this._repository);

  final BookingRepository _repository;

  Future<Either<AppException, List<BookingModel>>> getMyBookings() =>
      _repository.getMyBookings();

  Future<Either<AppException, List<BookingModel>>> getFutsalBookings() =>
      _repository.getFutsalBookings();
}
