import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/data_source/futsal_details_remote_data_source.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/available_courts_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/hosted_by_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_amenities_facilities_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_description_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class FutsalDetailsRepositoryImpl extends FutsalDetailsRepository {
  FutsalDetailsRepositoryImpl({FutsalDetailsRemoteDataSource? remoteDataSource})
    : _remoteDataSource =
          remoteDataSource ?? FutsalDetailsRemoteDataSourceImpl();

  final FutsalDetailsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, HostedByModel>> getHostedBy({
    required int venueId,
  }) async {
    final response = await _remoteDataSource.getHostedBy(venueId: venueId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final Map<String, dynamic> json = _extractHostedBy(response.getValue());
      return right(HostedByModel.fromJson(json));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse host details from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, VenueDescriptionModel>> getVenueDescription({
    required int venueId,
  }) async {
    final response = await _remoteDataSource.getVenueDescription(
      venueId: venueId,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(
        VenueDescriptionModel.fromJson(_extractDataMap(response.getValue())),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse venue description from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, VenueAmenitiesFacilitiesModel>>
  getVenueAmenitiesFacilities({required int venueId}) async {
    final response = await _remoteDataSource.getVenueAmenitiesFacilities(
      venueId: venueId,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(
        VenueAmenitiesFacilitiesModel.fromJson(
          _extractDataMap(response.getValue()),
        ),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse amenities and facilities from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, AvailableCourtsModel>> getAvailableCourts({
    required int venueId,
    required String selectDate,
    String? slotTime,
  }) async {
    final response = await _remoteDataSource.getAvailableCourts(
      venueId: venueId,
      selectDate: selectDate,
      slotTime: slotTime,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(AvailableCourtsModel.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse available courts from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<TimeSlotModel>>> getVenueSlots({
    required int venueId,
    required String date,
  }) async {
    final response = await _remoteDataSource.getVenueSlots(
      venueId: venueId,
      date: date,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(
        AvailableCourtsModel.fromResponse(response.getValue()).timeSlots,
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse venue slots from server.',
          statusCode: 0,
        ),
      );
    }
  }

  Map<String, dynamic> _extractDataMap(dynamic payload) {
    if (payload is! Map) return <String, dynamic>{};

    final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
    final dynamic nested = map['data'];
    if (nested is Map) return _extractDataMap(nested);
    return map;
  }

  Map<String, dynamic> _extractHostedBy(dynamic payload) {
    if (payload is! Map) return <String, dynamic>{};

    final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
    for (final String key in const <String>['data', 'hosted_by', 'host']) {
      final dynamic nested = map[key];
      if (nested is Map) return _extractHostedBy(nested);
    }
    return map;
  }
}
