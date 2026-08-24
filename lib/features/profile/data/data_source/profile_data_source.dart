import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class ProfileRemoteDataSource {
  Future<Result> getProfile();
  Future<Result> requestVendorUpgrade(Map<String, dynamic> data);
  Future<Result> updateProfile(Map<String, dynamic> data);
  Future<Result> updateNotificationPreferences(Map<String, dynamic> data);
  Future<Result> deleteAccount(Map<String, dynamic> data);
}

final class ProfileDataSourceImpl extends ProfileRemoteDataSource {
  @override
  Future<Result> getProfile() async =>
      await Client.instance().getAuthManager().getProfile();

  @override
  Future<Result> requestVendorUpgrade(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().requestVendorUpgrade(data);

  @override
  Future<Result> updateProfile(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().updateProfile(data);

  @override
  Future<Result> updateNotificationPreferences(
    Map<String, dynamic> data,
  ) async => await Client.instance()
      .getAuthManager()
      .updateNotificationPreferences(data);

  @override
  Future<Result> deleteAccount(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().deleteAccount(data);
}
