import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';

/// User-selected filters for the public venue list.
///
/// Every field is optional — an unset field means "no constraint" for that
/// dimension. Filtering is applied client-side over the venues already loaded
/// from the backend.
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

  /// Preferred play windows, e.g. `{'06:00-08:00', '17:00-19:00'}`.
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
      timeSlots.isEmpty;

  /// Number of active filter dimensions — drives the badge on the filter
  /// button.
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
    bool clearLocation = false,
    bool clearRadius = false,
    bool clearPrice = false,
    bool clearMatchTypeId = false,
    bool clearCourtTypeId = false,
    bool clearMinRating = false,
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
    );
  }

  Map<String, dynamic> toVenueListPayload({int page = 1, int perPage = 10}) {
    final Map<String, dynamic> payload = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (latitude != null) payload['latitude'] = latitude;
    if (longitude != null) payload['longitude'] = longitude;
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

    return payload;
  }

  /// Whether [venue] satisfies every active constraint.
  bool matches(PublicListingVenueModel venue) {
    final double? price = _venuePrice(venue);
    if (minPrice != null && (price == null || price < minPrice!)) return false;
    if (maxPrice != null && (price == null || price > maxPrice!)) return false;

    // ID-based filters, rating and time-slot availability are applied by the
    // venue list API. The local pass only keeps price fallback behavior for
    // already-loaded data.

    return true;
  }

  /// Applies this filter to [venues], returning the matching subset.
  List<PublicListingVenueModel> apply(List<PublicListingVenueModel> venues) {
    if (isEmpty) return venues;
    return venues.where(matches).toList(growable: false);
  }

  /// The venue's hourly price, or null when the backend sent no usable value.
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
  ];
}
