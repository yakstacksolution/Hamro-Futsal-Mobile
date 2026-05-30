import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class VenueCourtRemoteDataSource {
  Future<Result> getVenueCourt();
  Future<Result> getCourtDetails(int courtId);
}

final class VenueCourtRemoteDataSourceImpl
    implements VenueCourtRemoteDataSource {
  @override
  Future<Result> getVenueCourt() async =>
      await Client.instance().getAuthManager().getVenueCourt();

  @override
  Future<Result> getCourtDetails(int courtId) async =>
      await Client.instance().getAuthManager().getCourtDetails(courtId);
}
