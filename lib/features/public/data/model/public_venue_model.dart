import 'package:equatable/equatable.dart';

final class CourtTypeModel extends Equatable {
  const CourtTypeModel({
    this.id,
    this.name,
    this.slug,
  });

  final int? id;
  final String? name;
  final String? slug;

  factory CourtTypeModel.fromJson(Map<String, dynamic> json) {
    return CourtTypeModel(
      id: PublicListingVenueModel._parseInt(json['id']),
      name: PublicListingVenueModel._parseString(json['name']),
      slug: PublicListingVenueModel._parseString(json['slug']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'slug': slug,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, name, slug];
}

final class VenueGalleryImageModel extends Equatable {
  const VenueGalleryImageModel({
    this.id,
    this.mediaId,
    this.imageUrl,
    this.sortOrder,
  });

  final int? id;
  final int? mediaId;
  final String? imageUrl;
  final int? sortOrder;

  factory VenueGalleryImageModel.fromJson(Map<String, dynamic> json) {
    return VenueGalleryImageModel(
      id: PublicListingVenueModel._parseInt(json['id']),
      mediaId: PublicListingVenueModel._parseInt(json['media_id']),
      imageUrl: (json['image_url'] ?? '').toString(),
      sortOrder: PublicListingVenueModel._parseInt(json['sort_order']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'media_id': mediaId,
      'image_url': imageUrl,
      'sort_order': sortOrder,
    };
  }

  @override
  List<Object?> get props => <Object?>[id, mediaId, imageUrl, sortOrder];
}

/// One venue row from the public venue listing endpoint
/// (`data.venues[]`).
final class PublicListingVenueModel extends Equatable {
  const PublicListingVenueModel({
    this.id,
    this.name,
    this.slug,
    this.address,
    this.featureImage,
    this.exactLocation,
    this.price,
    this.isOpen,
    this.openCloseStatus,
    this.galleryImages,
    this.longitude,
    this.latitude,
    this.courtTypes,
    this.maxPlayer,
    this.minTime,
    this.maxTime,
    this.distanceMeters,
  });

  final int? id;
  final String? name;
  final String? slug;
  final String? address;
  final String? featureImage;
  final String? exactLocation;
  final double? price;
  final bool? isOpen;
  final String? openCloseStatus;
  final List<VenueGalleryImageModel>? galleryImages;
  final double? longitude;
  final double? latitude;
  final List<CourtTypeModel>? courtTypes;
  final int? maxPlayer;
  final String? minTime;
  final String? maxTime;
  final double? distanceMeters;

  factory PublicListingVenueModel.fromJson(Map<String, dynamic> json) {
    return PublicListingVenueModel(
      id: _parseInt(json['id'] ?? json['venue_id']),
      name: _parseString(json['name']),
      slug: _parseString(json['slug']),
      address: _parseString(json['address']),
      featureImage: _parseString(json['feature_image']),
      exactLocation: _parseString(json['exact_location']),
      price: _parseDouble(json['price']),
      isOpen: _parseBool(json['is_open']),
      openCloseStatus: _parseString(json['open_close_status']),
      galleryImages: _parseGalleryImages(json['venue_gallery_images']),
      longitude: _parseDouble(json['longitude']),
      latitude: _parseDouble(json['latitude']),
      courtTypes: _parseCourtTypes(json['court_types']),
      maxPlayer: _parseInt(
        json['max_player'] ?? json['max_players'] ?? json['capacity'],
      ),
      minTime: _parseString(json['min_time'] ?? json['opening_time']),
      maxTime: _parseString(json['max_time'] ?? json['closing_time']),
      distanceMeters: _parseDouble(
        json['distance_meters'] ?? json['distance_meter'] ?? json['distance'],
      ),
    );
  }

  PublicListingVenueModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? address,
    String? featureImage,
    String? exactLocation,
    double? price,
    bool? isOpen,
    String? openCloseStatus,
    List<VenueGalleryImageModel>? galleryImages,
    double? longitude,
    double? latitude,
    List<CourtTypeModel>? courtTypes,
    int? maxPlayer,
    String? minTime,
    String? maxTime,
    double? distanceMeters,
  }) {
    return PublicListingVenueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      address: address ?? this.address,
      featureImage: featureImage ?? this.featureImage,
      exactLocation: exactLocation ?? this.exactLocation,
      price: price ?? this.price,
      isOpen: isOpen ?? this.isOpen,
      openCloseStatus: openCloseStatus ?? this.openCloseStatus,
      galleryImages: galleryImages ?? this.galleryImages,
      longitude: longitude ?? this.longitude,
      latitude: latitude ?? this.latitude,
      courtTypes: courtTypes ?? this.courtTypes,
      maxPlayer: maxPlayer ?? this.maxPlayer,
      minTime: minTime ?? this.minTime,
      maxTime: maxTime ?? this.maxTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'slug': slug,
      'address': address,
      'feature_image': featureImage,
      'exact_location': exactLocation,
      'price': price,
      'is_open': isOpen,
      'open_close_status': openCloseStatus,
      'venue_gallery_images': galleryImages
          ?.map((VenueGalleryImageModel image) => image.toJson())
          .toList(growable: false),
      'longitude': longitude,
      'latitude': latitude,
      'court_types': courtTypes?.map((type) => type.toJson()).toList(growable: false),
      'max_player': maxPlayer,
      'min_time': minTime,
      'max_time': maxTime,
      'distance_meters': distanceMeters,
    };
  }

  static List<VenueGalleryImageModel> _parseGalleryImages(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (Map item) => VenueGalleryImageModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);
    }
    return const <VenueGalleryImageModel>[];
  }

  static String? _parseString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    final double? parsed = value is num
        ? value.toDouble()
        : double.tryParse(value.toString());
    // `double.tryParse('NaN'/'Infinity')` succeeds — treat non-finite as null
    // so callers see "no value" rather than a NaN that crashes math/widgets.
    if (parsed == null || !parsed.isFinite) return null;
    return parsed;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    final String text = value?.toString().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'open';
  }

  static List<CourtTypeModel>? _parseCourtTypes(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (Map item) => CourtTypeModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false);
    }
    return null;
  }

  static String? _parseOptionText(dynamic value) {
    if (value is Map) {
      return _parseString(
        value['name'] ??
            value['title'] ??
            value['label'] ??
            value['type'] ??
            value['format'] ??
            value['value'],
      );
    }
    return _parseString(value);
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    slug,
    address,
    featureImage,
    exactLocation,
    price,
    isOpen,
    openCloseStatus,
    galleryImages,
    longitude,
    latitude,
    courtTypes,
    maxPlayer,
    minTime,
    maxTime,
    distanceMeters,
  ];
}

/// A single page of public venues plus the pagination metadata needed to
/// decide whether more pages can be fetched.
final class PublicListingVenuePage extends Equatable {
  const PublicListingVenuePage({
    required this.venues,
    required this.page,
    required this.perPage,
    required this.total,
    this.paginationMetaData = const <String, dynamic>{},
  });

  final List<PublicListingVenueModel> venues;
  final int page;
  final int perPage;
  final int total;
  final Map<String, dynamic> paginationMetaData;

  /// Whether there is at least one more page to load after this one.
  bool get hasMore {
    // Use has_more_pages from API if available, otherwise fall back to calculation
    final bool? hasMorePages = PublicListingVenueModel._parseBool(paginationMetaData['has_more_pages']);
    if (hasMorePages != null) return hasMorePages;
    return page * perPage < total;
  }

  factory PublicListingVenuePage.fromJson(Map<String, dynamic> json) {
    // Unwrap the `{status, message, data: {venues: [...]}}` envelope.
    final dynamic dataField = json['data'];
    final Map<String, dynamic> root = dataField is Map
        ? Map<String, dynamic>.from(dataField)
        : json;

    final dynamic listSource = root['venues'];
    final List<dynamic> items = listSource is List
        ? listSource
        : const <dynamic>[];

    // Pagination metadata may sit under `meta`, `pagination`, or alongside the
    // list; when absent (as in the current response) the page is treated as
    // the full result set.
    final Map<String, dynamic> meta = root['meta'] is Map
        ? Map<String, dynamic>.from(root['meta'] as Map)
        : root['pagination'] is Map
        ? Map<String, dynamic>.from(root['pagination'] as Map)
        : root;

    return PublicListingVenuePage(
      venues: items
          .whereType<Map>()
          .map(
            (Map item) => PublicListingVenueModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      page:
          PublicListingVenueModel._parseInt(
            meta['current_page'] ?? meta['page'] ?? 1,
          ) ??
          1,
      perPage:
          PublicListingVenueModel._parseInt(
            meta['per_page'] ?? meta['perPage'] ?? items.length,
          ) ??
          items.length,
      total:
          PublicListingVenueModel._parseInt(
            meta['total'] ?? meta['total_count'] ?? items.length,
          ) ??
          items.length,
      paginationMetaData: meta,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'venues': venues
          .map((PublicListingVenueModel venue) => venue.toJson())
          .toList(growable: false),
      'page': page,
      'per_page': perPage,
      'total': total,
      'meta_data': paginationMetaData,
    };
  }

  @override
  List<Object?> get props => <Object?>[venues, page, perPage, total, paginationMetaData];
}
