import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/domain/model/booking_export_file.dart';

abstract class BookingOverviewRepository {
  Future<Either<AppException, BookingOverviewResponse>> getOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  });

  Future<Either<AppException, BookingExportFile>> exportBookingsOverView({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  });
}
