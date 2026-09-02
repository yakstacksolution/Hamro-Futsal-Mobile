import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/features/booking_overview/data/data_source/booking_overview_data_source.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/domain/repository/booking_overview_repository.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

final class BookingOverviewRepositoryImpl extends BookingOverviewRepository {
  BookingOverviewRepositoryImpl({BookingOverviewDataSource? dataSource})
    : _dataSource = dataSource ?? BookingOverviewRemoteDataSourceImpl();

  final BookingOverviewDataSource _dataSource;

  @override
  Future<Either<AppException, BookingOverviewResponse>> getOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async {
    final response = await _dataSource.fetchBookingOverview(
      dateFilter: dateFilter,
      dateFrom: dateFrom,
      dateTo: dateTo,
      venueIds: venueIds,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingOverviewResponse.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotLoadBookings,
          statusCode: 0,
        ),
      );
    }
  }
}
