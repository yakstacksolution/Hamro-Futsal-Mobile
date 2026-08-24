import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class VenueCourtRemoteDataSource {
  Future<Result> getVenueCourt({required int page, required int perPage});
  Future<Result> getCourtDetails(int courtId);
  Future<Result> getCourtSlots(int courtId);
  Future<Result> createCourtSlot(Map<String, dynamic> data);
  Future<Result> updateCourtSlot(Map<String, dynamic> data);
  Future<Result> deleteCourtSlot(Map<String, dynamic> data);
  Future<Result> updateCourtStatus(Map<String, dynamic> data);
  Future<Result> deleteCourt(int courtId);
}

final class VenueCourtRemoteDataSourceImpl
    implements VenueCourtRemoteDataSource {
  @override
  Future<Result> getVenueCourt({
    required int page,
    required int perPage,
  }) async => await Client.instance().getAuthManager().getVenueCourt(
    page: page,
    perPage: perPage,
  );

  @override
  Future<Result> getCourtDetails(int courtId) async =>
      await Client.instance().getAuthManager().getCourtDetails(courtId);

  @override
  Future<Result> getCourtSlots(int courtId) async =>
      await Client.instance().getAuthManager().getCourtSlots(courtId);

  @override
  Future<Result> createCourtSlot(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().createCourtSlot(data);

  @override
  Future<Result> updateCourtSlot(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().updateCourtSlot(data);

  @override
  Future<Result> deleteCourtSlot(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().deleteCourtSlot(data);

  @override
  Future<Result> updateCourtStatus(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().updateVendorOnboardingCourt(
        data,
      );

  @override
  Future<Result> deleteCourt(int courtId) async => await Client.instance()
      .getAuthManager()
      .deleteVendorCourt(<String, dynamic>{'court_id': courtId});
}
