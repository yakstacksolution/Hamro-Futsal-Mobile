import 'package:equatable/equatable.dart';

/// Rich amenity and facility data returned by
/// `/venue-amenities-facilities/{venue_id}`.
final class VenueAmenitiesFacilitiesModel extends Equatable {
  const VenueAmenitiesFacilitiesModel({
    this.amenities = const <VenueAmenityFacilityItem>[],
    this.facilities = const <VenueAmenityFacilityItem>[],
  });

  final List<VenueAmenityFacilityItem> amenities;
  final List<VenueAmenityFacilityItem> facilities;

  factory VenueAmenitiesFacilitiesModel.fromJson(Map<String, dynamic> json) {
    return VenueAmenitiesFacilitiesModel(
      amenities: _parseItems(json['amenities'] ?? json['amenity']),
      facilities: _parseItems(json['facilities'] ?? json['facility']),
    );
  }

  bool get hasData => amenities.isNotEmpty || facilities.isNotEmpty;

  static List<VenueAmenityFacilityItem> _parseItems(dynamic value) {
    if (value is! List) return const <VenueAmenityFacilityItem>[];

    return value
        .map<VenueAmenityFacilityItem?>((dynamic item) {
          if (item is Map) {
            return VenueAmenityFacilityItem.fromJson(
              Map<String, dynamic>.from(item),
            );
          }
          final String name = item?.toString().trim() ?? '';
          return name.isEmpty ? null : VenueAmenityFacilityItem(name: name);
        })
        .whereType<VenueAmenityFacilityItem>()
        .where((VenueAmenityFacilityItem item) => item.name.isNotEmpty)
        .toList(growable: false);
  }

  @override
  List<Object?> get props => <Object?>[amenities, facilities];
}

final class VenueAmenityFacilityItem extends Equatable {
  const VenueAmenityFacilityItem({
    this.id,
    required this.name,
    this.title,
    this.slug,
    this.status,
    this.icon,
    this.image,
    this.description,
    this.isActive,
    this.sortOrder,
  });

  final int? id;
  final String name;
  final String? title;
  final String? slug;
  final bool? status;
  final VenueMediaAttachment? icon;
  final VenueMediaAttachment? image;
  final String? description;
  final bool? isActive;
  final int? sortOrder;

  /// Facilities may expose the same asset as both `icon` and `image`.
  String? get displayIconUrl => icon?.url ?? image?.url;

  factory VenueAmenityFacilityItem.fromJson(Map<String, dynamic> json) {
    return VenueAmenityFacilityItem(
      id: _asInt(json['id']),
      name: _asString(json['name'] ?? json['title'] ?? json['label']) ?? '',
      title: _asString(json['title']),
      slug: _asString(json['slug']),
      status: _asBool(json['status']),
      icon: VenueMediaAttachment.tryParse(json['icon']),
      image: VenueMediaAttachment.tryParse(json['image']),
      description: _asString(json['description']),
      isActive: _asBool(json['is_active']),
      sortOrder: _asInt(json['sort_order']),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    title,
    slug,
    status,
    icon,
    image,
    description,
    isActive,
    sortOrder,
  ];
}

final class VenueMediaAttachment extends Equatable {
  const VenueMediaAttachment({this.id, this.name, this.fullUrl, this.media});

  final int? id;
  final String? name;
  final String? fullUrl;
  final VenueMedia? media;

  String? get url => fullUrl ?? media?.fullUrl;

  static VenueMediaAttachment? tryParse(dynamic value) {
    if (value is String) {
      final String? url = _asString(value);
      return url == null ? null : VenueMediaAttachment(fullUrl: url);
    }
    if (value is! Map) return null;
    return VenueMediaAttachment.fromJson(Map<String, dynamic>.from(value));
  }

  factory VenueMediaAttachment.fromJson(Map<String, dynamic> json) {
    return VenueMediaAttachment(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      fullUrl: _asString(json['full_url']),
      media: VenueMedia.tryParse(json['media']),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, fullUrl, media];
}

final class VenueMedia extends Equatable {
  const VenueMedia({this.id, this.name, this.fullUrl, this.status});

  final int? id;
  final String? name;
  final String? fullUrl;
  final String? status;

  static VenueMedia? tryParse(dynamic value) {
    if (value is! Map) return null;
    return VenueMedia.fromJson(Map<String, dynamic>.from(value));
  }

  factory VenueMedia.fromJson(Map<String, dynamic> json) {
    return VenueMedia(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      fullUrl: _asString(json['full_url']),
      status: _asString(json['status']),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, fullUrl, status];
}

String? _asString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

int? _asInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

bool? _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String normalized = value?.toString().trim().toLowerCase() ?? '';
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}
