import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class PublicRemoteDataSource {
  Future<Result> getServices();
  Future<Result> getPackages();
  Future<Result> getCourtTypes();
  Future<Result> getMatchFormats();
  Future<Result> getAmenities();
  Future<Result> getFacilities();
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
  Future<Result> getCourtTypes() async =>
      await Client.instance().getAuthManager().getCourtTypes();

  @override
  Future<Result> getMatchFormats() async =>
      await Client.instance().getAuthManager().getMatchFormats();

  @override
  Future<Result> getAmenities() async =>
      await Client.instance().getAuthManager().getAmenities();

  @override
  Future<Result> getFacilities() async =>
      await Client.instance().getAuthManager().getFacilities();

  @override
  Future<Result> getTemplates() async =>
      await Client.instance().getAuthManager().getPublicTemplates();
}
