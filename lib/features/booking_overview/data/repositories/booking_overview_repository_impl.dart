import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/booking_overview/data/data_source/booking_overview_data_source.dart';
import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_footsall/features/booking_overview/domain/repository/booking_overview_repository.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

final class BookingOverviewRepositoryImpl extends BookingOverviewRepository {
  BookingOverviewRepositoryImpl({BookingOverviewDataSource? dataSource})
    : _dataSource = dataSource ?? BookingOverviewLocalDataSourceImpl();

  final BookingOverviewDataSource _dataSource;

  @override
  Future<Either<AppException, List<BookingFutsalModel>>> getFutsals() async {
    try {
      return right(await _dataSource.fetchFutsals());
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotLoadVenues,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<BookingRecordModel>>> getBookings() async {
    try {
      return right(await _dataSource.fetchBookings());
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
