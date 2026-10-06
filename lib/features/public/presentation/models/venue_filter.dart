import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/core/api/api_client/api_constants.dart';

class VenueFilter extends Equatable {
  const VenueFilter({
    this.latitude,
    this.longitude,
    this.radius,
    this.categoryFilterIds = const <int>{},
    this.minPrice,
    this.maxPrice,
    this.matchTypeId,
    this.courtTypeId,
    this.minRating,
    this.timeSlots = const <String>{},
    this.search,
  });

  final double? latitude;
  final double? longitude;
  final double? radius;
  final Set<int> categoryFilterIds;
  final double? minPrice;
  final double? maxPrice;
  final int? matchTypeId;
  final int? courtTypeId;
  final double? minRating;

  final String? search;

  final Set<String> timeSlots;

  static const VenueFilter empty = VenueFilter();

  bool get isEmpty =>
      latitude == null &&
      longitude == null &&
      radius == null &&
      categoryFilterIds.isEmpty &&
      minPrice == null &&
      maxPrice == null &&
      matchTypeId == null &&
      courtTypeId == null &&
      minRating == null &&
      timeSlots.isEmpty &&
      (search == null || search!.trim().isEmpty);

  int get activeCount {
    int count = 0;
    if (categoryFilterIds.isNotEmpty) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (matchTypeId != null) count++;
    if (courtTypeId != null) count++;
    if (minRating != null) count++;
    if (timeSlots.isNotEmpty) count++;
    return count;
  }

  VenueFilter copyWith({
    double? latitude,
    double? longitude,
    double? radius,
    Set<int>? categoryFilterIds,
    double? minPrice,
    double? maxPrice,
    int? matchTypeId,
    int? courtTypeId,
    double? minRating,
    Set<String>? timeSlots,
    String? search,
    bool clearLocation = false,
    bool clearRadius = false,
    bool clearPrice = false,
    bool clearMatchTypeId = false,
    bool clearCourtTypeId = false,
    bool clearMinRating = false,
    bool clearSearch = false,
  }) {
    return VenueFilter(
      latitude: clearLocation ? null : latitude ?? this.latitude,
      longitude: clearLocation ? null : longitude ?? this.longitude,
      radius: clearRadius ? null : radius ?? this.radius,
      categoryFilterIds: categoryFilterIds ?? this.categoryFilterIds,
      minPrice: clearPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearPrice ? null : maxPrice ?? this.maxPrice,
      matchTypeId: clearMatchTypeId ? null : matchTypeId ?? this.matchTypeId,
      courtTypeId: clearCourtTypeId ? null : courtTypeId ?? this.courtTypeId,
      minRating: clearMinRating ? null : minRating ?? this.minRating,
      timeSlots: timeSlots ?? this.timeSlots,
      search: clearSearch ? null : search ?? this.search,
    );
  }

  Map<String, dynamic> toVenueListPayload({
    int page = 1,
    int perPage = kVenueListPerPage,
    double? latitude,
    double? longitude,
  }) {
    final double? originLatitude = latitude ?? this.latitude;
    final double? originLongitude = longitude ?? this.longitude;

    final Map<String, dynamic> payload = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    // Both coordinates or neither: a lone axis is meaningless to the server.
    if (originLatitude != null && originLongitude != null) {
      payload['latitude'] = originLatitude;
      payload['longitude'] = originLongitude;
    }
    if (radius != null) payload['radius'] = radius;
    if (categoryFilterIds.isNotEmpty) {
      payload['filter'] = categoryFilterIds.toList(growable: false);
    }
    if (minPrice != null || maxPrice != null) {
      payload['price_range'] = <String, dynamic>{
        if (minPrice != null) 'start_price': minPrice!.round(),
        if (maxPrice != null) 'end_price': maxPrice!.round(),
      };
    }
    if (matchTypeId != null) payload['match_type_id'] = matchTypeId;
    if (courtTypeId != null) payload['court_type_id'] = courtTypeId;
    if (minRating != null) payload['rating'] = minRating;
    if (timeSlots.isNotEmpty) {
      payload['time_slot'] = timeSlots.toList(growable: false);
    }
    final String? term = search?.trim();
    if (term != null && term.isNotEmpty) payload['search'] = term;

    return payload;
  }

  bool matches(PublicListingVenueModel venue) {
    final double? price = _venuePrice(venue);
    if (minPrice != null && (price == null || price < minPrice!)) return false;
    if (maxPrice != null && (price == null || price > maxPrice!)) return false;

    final String? term = search?.trim();
    if (term != null && term.isNotEmpty) {
      final String name = venue.name?.toLowerCase() ?? '';
      if (!name.contains(term.toLowerCase())) return false;
    }

    // ID-based filters, rating and time-slot availability are applied by the
    // venue list API. The local pass keeps price + name fallbacks for
    // already-loaded data.

    return true;
  }

  List<PublicListingVenueModel> apply(List<PublicListingVenueModel> venues) {
    if (isEmpty) return venues;
    return venues.where(matches).toList(growable: false);
  }

  static double? _venuePrice(PublicListingVenueModel venue) {
    final double? price = venue.price;
    return price != null && price > 0 ? price : null;
  }

  @override
  List<Object?> get props => <Object?>[
    latitude,
    longitude,
    radius,
    categoryFilterIds,
    minPrice,
    maxPrice,
    matchTypeId,
    courtTypeId,
    minRating,
    timeSlots,
    search,
  ];
}
