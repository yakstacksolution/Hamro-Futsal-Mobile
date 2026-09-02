import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/domain/repository/booking_overview_repository.dart';

final class BookingOverviewUseCase {
  const BookingOverviewUseCase(this.repository);

  final BookingOverviewRepository repository;

  Future<Either<AppException, BookingOverviewResponse>> getOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async => await repository.getOverview(
    dateFilter: dateFilter,
    dateFrom: dateFrom,
    dateTo: dateTo,
    venueIds: venueIds,
  );
}
