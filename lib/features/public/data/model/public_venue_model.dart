import 'package:equatable/equatable.dart';

final class VenueGalleryImageModel extends Equatable {
  const VenueGalleryImageModel({
    required this.id,
    required this.mediaId,
    required this.imageUrl,
    required this.sortOrder,
  });

  final int id;
  final int mediaId;
  final String imageUrl;
  final int sortOrder;

  factory VenueGalleryImageModel.fromJson(Map<String, dynamic> json) {
    return VenueGalleryImageModel(
      id: PublicListingVenueModel._parseInt(json['id']),
      mediaId: PublicListingVenueModel._parseInt(json['media_id']),
      imageUrl: (json['image_url'] ?? '').toString(),
      sortOrder: PublicListingVenueModel._parseInt(json['sort_order']),
    );
  }

  @override
  List<Object?> get props => <Object?>[id, mediaId, imageUrl, sortOrder];
}

/// One venue row from the public venue listing endpoint
/// (`data.venues[]`).
final class PublicListingVenueModel extends Equatable {
  const PublicListingVenueModel({
    required this.name,
    required this.slug,
    required this.address,
    required this.featureImage,
    required this.exactLocation,
    required this.price,
    required this.isOpen,
    required this.openCloseStatus,
    required this.galleryImages,
    required this.longitude,
    required this.latitude,
  });

  final String name;
  final String slug;
  final String address;
  final String featureImage;
  final String exactLocation;
  final double price;
  final bool isOpen;
  final String openCloseStatus;
  final List<VenueGalleryImageModel> galleryImages;
  final double longitude;
  final double latitude;

  factory PublicListingVenueModel.fromJson(Map<String, dynamic> json) {
    return PublicListingVenueModel(
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      featureImage: (json['feature_image'] ?? '').toString(),
      exactLocation: (json['exact_location'] ?? '').toString(),
      price: _parseDouble(json['price']),
      isOpen: _parseBool(json['is_open']),
      openCloseStatus: (json['open_close_status'] ?? '').toString(),
      galleryImages: _parseGalleryImages(json['venue_gallery_images']),
      longitude: _parseDouble(json['longitude']),
      latitude: _parseDouble(json['latitude']),
    );
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

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    final String text = value?.toString().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'open';
  }

  @override
  List<Object?> get props => <Object?>[
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
  });

  final List<PublicListingVenueModel> venues;
  final int page;
  final int perPage;
  final int total;

  /// Whether there is at least one more page to load after this one.
  bool get hasMore => page * perPage < total;

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
      page: PublicListingVenueModel._parseInt(
        meta['current_page'] ?? meta['page'] ?? 1,
      ),
      perPage: PublicListingVenueModel._parseInt(
        meta['per_page'] ?? meta['perPage'] ?? items.length,
      ),
      total: PublicListingVenueModel._parseInt(
        meta['total'] ?? meta['total_count'] ?? items.length,
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[venues, page, perPage, total];
}
