import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class VenueCourtRemoteDataSource {
  Future<Result> getVenueCourt();
}

final class VenueCourtRemoteDataSourceImpl
    implements VenueCourtRemoteDataSource {
  @override
  Future<Result> getVenueCourt() async =>
      await Client.instance().getAuthManager().getVenueCourt();
}
