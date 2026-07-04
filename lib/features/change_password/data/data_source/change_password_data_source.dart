import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

/// Authenticated password change — `PUT /auth/password`.
abstract class ChangePasswordRemoteDataSource {
  Future<Result> changePassword(Map<String, dynamic> data);
}

final class ChangePasswordDataSourceImpl
    extends ChangePasswordRemoteDataSource {
  @override
  Future<Result> changePassword(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().updatePassword(data);
}
