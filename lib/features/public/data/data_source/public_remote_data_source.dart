import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';

abstract class PublicRemoteDataSource {
  Future<Result> getServices();
  Future<Result> getPackages();
  Future<Result> getCourtTypes();
  Future<Result> getMatchFormats();
  Future<Result> getAmenities();
  Future<Result> getFacilities();
  Future<Result> getTemplates();
  Future<Result> getVenueList({int page, int perPage, VenueFilter? filter});
  Future<Result> getCategoryFilter();
  Future<Result> getWishlist();
  Future<Result> toggleWishlist(int venueId);
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

  @override
  Future<Result> getVenueList({
    int page = 1,
    int perPage = 10,
    VenueFilter? filter,
  }) async => await Client.instance().getAuthManager().getPublicVenueList(
    page: page,
    perPage: perPage,
    data: filter?.toVenueListPayload(page: page, perPage: perPage),
  );

  @override
  Future<Result> getCategoryFilter() async =>
      await Client.instance().getAuthManager().getCategoryFilter();

  @override
  Future<Result> getWishlist() async =>
      await Client.instance().getAuthManager().getWishlist();

  @override
  Future<Result> toggleWishlist(int venueId) async =>
      await Client.instance().getAuthManager().toggleWishlist(venueId);
}
