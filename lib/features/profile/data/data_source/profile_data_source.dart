import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class ProfileRemoteDataSource {
  Future<Result> getProfile();
}

final class ProfileDataSourceImpl extends ProfileRemoteDataSource {
  @override
  Future<Result> getProfile() async =>
      await Client.instance().getAuthManager().getProfile();
}
