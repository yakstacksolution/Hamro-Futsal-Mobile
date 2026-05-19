import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/bookings/data/data_source/booking_data_source.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';

final class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({BookingRemoteDataSource? remoteDataSource})
      : _remoteDataSource =
            remoteDataSource ?? BookingRemoteDataSourceImpl();

  final BookingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, List<BookingModel>>> getMyBookings() async {
    final response = await _remoteDataSource.getMyBookings();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.listFromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse bookings from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<BookingModel>>> getFutsalBookings() async {
    final response = await _remoteDataSource.getFutsalBookings();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.listFromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse futsal bookings from server.',
          statusCode: 0,
        ),
      );
    }
  }
}
