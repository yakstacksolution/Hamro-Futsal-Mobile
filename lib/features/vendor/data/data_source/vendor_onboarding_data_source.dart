import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class VendorOnboardingRemoteDataSource {
  Future<Result> fetchVendorOnboardingFutsal(int futsalId);

  Future<Result> submitFutsal(Map<String, dynamic> body);
  Future<Result> updateFutsal(Map<String, dynamic> body);
}

final class VendorOnboardingRemoteDataSourceImpl
    extends VendorOnboardingRemoteDataSource {
  @override
  Future<Result> fetchVendorOnboardingFutsal(int futsalId) async =>
      await Client.instance().getAuthManager().fetchVendorOnboardingFutsal(
        futsalId,
      );

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
}
