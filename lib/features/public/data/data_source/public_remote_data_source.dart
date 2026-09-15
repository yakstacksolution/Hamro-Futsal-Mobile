import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';
import 'package:hamro_futsal/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_futsal/core/api/api_client/api_constants.dart';

abstract class PublicRemoteDataSource {
  Future<Result> getServices();
  Future<Result> getPackages();
  Future<Result> getCourtTypes();
  Future<Result> getMatchFormats();
  Future<Result> getAmenities();
  Future<Result> getFacilities();
  Future<Result> getTemplates();
  Future<Result> getVenueList({
    int page,
    int perPage,
    VenueFilter? filter,
    double? latitude,
    double? longitude,
  });

  /// `GET /venues` narrowed to one venue by slug and/or id — what a shared
  /// link carries.
  Future<Result> getVenueByLink({
    String? slug,
    int? id,
    double? latitude,
    double? longitude,
  });
  Future<Result> getCategoryFilter();
  Future<Result> getWishlist();
  Future<Result> toggleWishlist(int venueId);
  Future<Result> getFaqs();
  Future<Result> getHelps();
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
    int perPage = kVenueListPerPage,
    VenueFilter? filter,
    double? latitude,
    double? longitude,
  }) async => await Client.instance().getAuthManager().getPublicVenueList(
    data: (filter ?? VenueFilter.empty).toVenueListPayload(
      page: page,
      perPage: perPage,
      latitude: latitude,
      longitude: longitude,
    ),
  );

  @override
  Future<Result> getVenueByLink({
    String? slug,
    int? id,
    double? latitude,
    double? longitude,
  }) async => await Client.instance().getAuthManager().getPublicVenueList(
    data: <String, dynamic>{
      'page': 1,
      'per_page': kVenueLinkLookupPerPage,
      // Sent together on purpose: a backend that filters on `slug`/`venue_id`
      // answers with the one venue, and one that ignores them still returns a
      // name search the caller can match the slug against.
      if (slug != null && slug.trim().isNotEmpty) ...<String, dynamic>{
        'slug': slug.trim(),
        'search': slug.trim().replaceAll('-', ' '),
      },
      if (id != null) ...<String, dynamic>{'venue_id': id, 'venue': id},
      if (latitude != null && longitude != null) ...<String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
      },
    },
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

  @override
  Future<Result> getFaqs() async =>
      await Client.instance().getAuthManager().getFaqs();

  @override
  Future<Result> getHelps() async =>
      await Client.instance().getAuthManager().getHelps();
}
