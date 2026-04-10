import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class VendorOnboardingRemoteDataSource {
  Future<Result> submitFutsal(Map<String, dynamic> body);
}

final class VendorOnboardingRemoteDataSourceImpl
    extends VendorOnboardingRemoteDataSource {
  @override
  Future<Result> submitFutsal(Map<String, dynamic> body) async {
    return await Client.instance()
        .getAuthManager()
        .submitVendorOnboardingFutsal(body);
  }
}
