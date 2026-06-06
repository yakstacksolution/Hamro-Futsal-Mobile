import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_footsall/features/booking_overview/domain/repository/booking_overview_repository.dart';

final class BookingOverviewUseCase {
  const BookingOverviewUseCase(this.repository);

  final BookingOverviewRepository repository;

  Future<Either<AppException, List<BookingFutsalModel>>> getFutsals() async =>
      await repository.getFutsals();

  Future<Either<AppException, List<BookingRecordModel>>> getBookings() async =>
      await repository.getBookings();
}
