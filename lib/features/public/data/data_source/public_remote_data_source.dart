import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class PublicRemoteDataSource {
  Future<Result> getServices();
  Future<Result> getPackages();
  Future<Result> getTemplates();
}

final class PublicRemoteDataSourceImpl extends PublicRemoteDataSource {
  @override
  Future<Result> getServices() async =>
      await Client.instance().getAuthManager().getPublicServices();

  @override
  Future<Result> getPackages() async =>
      await Client.instance().getAuthManager().getPublicPackages();

  @override
  Future<Result> getTemplates() async =>
      await Client.instance().getAuthManager().getPublicTemplates();
}
