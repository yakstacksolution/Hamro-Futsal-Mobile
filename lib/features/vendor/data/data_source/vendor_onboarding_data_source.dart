import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class VendorOnboardingRemoteDataSource {
  Future<Result> fetchVendorOnboardingFutsal(int futsalId);
  Future<Result> fetchCourtsByVenueId(int venueId);

  Future<Result> submitFutsal(Map<String, dynamic> body);
  Future<Result> updateFutsal(Map<String, dynamic> body);
  Future<Result> submitCourt(Map<String, dynamic> body);
  Future<Result> updateCourt(Map<String, dynamic> body);
  Future<Result> deleteCourt(int courtId);
}

final class VendorOnboardingRemoteDataSourceImpl
    extends VendorOnboardingRemoteDataSource {
  @override
  Future<Result> fetchVendorOnboardingFutsal(int venueId) async =>
      await Client.instance().getAuthManager().fetchVendorOnboardingFutsal(
        venueId,
      );

  @override
  Future<Result> fetchCourtsByVenueId(int venueId) async =>
      await Client.instance().getAuthManager().getVenueCourtByVenueId(venueId);

  @override
  Future<Result> submitFutsal(Map<String, dynamic> body) async {
    return await Client.instance()
        .getAuthManager()
        .submitVendorOnboardingFutsal(body);
  }

  @override
  Future<Result> updateFutsal(Map<String, dynamic> body) async {
    return await Client.instance()
        .getAuthManager()
        .updateVendorOnboardingFutsal(body);
  }

  @override
  Future<Result> submitCourt(Map<String, dynamic> body) async {
    return await Client.instance().getAuthManager().submitVendorOnboardingCourt(
      body,
    );
  }

  @override
  Future<Result> updateCourt(Map<String, dynamic> body) async {
    return await Client.instance().getAuthManager().updateVendorOnboardingCourt(
      body,
    );
  }

  @override
  Future<Result> deleteCourt(int courtId) async {
    return await Client.instance()
        .getAuthManager()
        .deleteVendorOnboardingCourt(courtId);
  }
}
