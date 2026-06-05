import 'package:equatable/equatable.dart';

/// Amenity and facility names returned by
/// `/venue-amenities-facilities/{venue_id}`.
final class VenueAmenitiesFacilitiesModel extends Equatable {
  const VenueAmenitiesFacilitiesModel({
    this.amenities = const <String>[],
    this.facilities = const <String>[],
  });

  final List<String> amenities;
  final List<String> facilities;

  factory VenueAmenitiesFacilitiesModel.fromJson(Map<String, dynamic> json) {
    return VenueAmenitiesFacilitiesModel(
      amenities: _parseNames(json['amenities'] ?? json['amenity']),
      facilities: _parseNames(json['facilities'] ?? json['facility']),
    );
  }

  bool get hasData => amenities.isNotEmpty || facilities.isNotEmpty;

  /// Accepts a list of maps (`{id, name, ...}`) or plain strings and returns
  /// the trimmed, non-empty names.
  static List<String> _parseNames(dynamic value) {
    if (value is! List) return const <String>[];
    return value
        .map((dynamic item) {
          if (item is Map) {
            return (item['name'] ?? item['title'] ?? item['label'])
                    ?.toString()
                    .trim() ??
                '';
          }
          return item?.toString().trim() ?? '';
        })
        .where((String name) => name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  List<Object?> get props => <Object?>[amenities, facilities];
}
