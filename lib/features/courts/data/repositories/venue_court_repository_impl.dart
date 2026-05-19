import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/courts/data/data_source/venue_court_data_source.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/domain/repository/venue_court_repository.dart';

final class VenueCourtRepositoryImpl implements VenueCourtRepository {
  VenueCourtRepositoryImpl({VenueCourtRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? VenueCourtRemoteDataSourceImpl();

  final VenueCourtRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, List<VenueCourtModel>>> getVenueCourt() async {
    final response = await _remoteDataSource.getVenueCourt();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(VenueCourtModel.listFromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse venue courts from server.',
          statusCode: 0,
        ),
      );
    }
  }
}
