import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class FutsalDetailsRemoteDataSource {
  Future<Result> getHostedBy({required int venueId});
  Future<Result> getVenueDescription({required int venueId});
  Future<Result> getVenueAmenitiesFacilities({required int venueId});
}

final class FutsalDetailsRemoteDataSourceImpl
    extends FutsalDetailsRemoteDataSource {
  @override
  Future<Result> getHostedBy({required int venueId}) async =>
      await Client.instance().getAuthManager().getVenueHostedBy(venueId);

  @override
  Future<Result> getVenueDescription({required int venueId}) async =>
      await Client.instance().getAuthManager().getVenueDescription(venueId);

  @override
  Future<Result> getVenueAmenitiesFacilities({required int venueId}) async =>
      await Client.instance().getAuthManager().getVenueAmenitiesFacilities(
        venueId,
      );
}
