import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/courts/data/data_source/venue_court_data_source.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_page_model.dart';
import 'package:hamro_footsall/features/courts/domain/repository/venue_court_repository.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

final class VenueCourtRepositoryImpl implements VenueCourtRepository {
  VenueCourtRepositoryImpl({VenueCourtRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? VenueCourtRemoteDataSourceImpl();

  final VenueCourtRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, VenueCourtPageModel>> getVenueCourt({
    required int page,
    required int perPage,
  }) async {
    final response = await _remoteDataSource.getVenueCourt(
      page: page,
      perPage: perPage,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(VenueCourtPageModel.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseVenueCourtsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, CourtDraft>> getCourtDetails(int courtId) async {
    final response = await _remoteDataSource.getCourtDetails(courtId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(VenueCourtModel.courtFromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseCourtDetailsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<SlotPricingDraft>>> getCourtSlots(
    int courtId,
  ) async {
    final response = await _remoteDataSource.getCourtSlots(courtId);
    return _parseSlots(response, 'Could not parse court slots from server.');
  }

  @override
  Future<Either<AppException, List<SlotPricingDraft>>> createCourtSlot(
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.createCourtSlot(data);
    return _parseSlots(response, 'Could not create the court slot.');
  }

  @override
  Future<Either<AppException, List<SlotPricingDraft>>> updateCourtSlot(
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updateCourtSlot(data);
    return _parseSlots(response, 'Could not save the court slot.');
  }

  @override
  Future<Either<AppException, List<SlotPricingDraft>>> deleteCourtSlot(
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.deleteCourtSlot(data);
    return _parseSlots(response, 'Could not delete the court slot.');
  }

  @override
  Future<Either<AppException, Unit>> updateCourtStatus(
    Map<String, dynamic> data,
  ) async {
    final response = await _remoteDataSource.updateCourtStatus(data);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(unit);
  }

  @override
  Future<Either<AppException, Unit>> deleteCourt(int courtId) async {
    final response = await _remoteDataSource.deleteCourt(courtId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(unit);
  }

  Either<AppException, List<SlotPricingDraft>> _parseSlots(
    Result response,
    String errorMessage,
  ) {
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(VenueCourtModel.slotsFromResponse(response.getValue()));
    } catch (_) {
      return left(DefaultException(errorMessage: errorMessage, statusCode: 0));
    }
  }
}
