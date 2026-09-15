import 'package:equatable/equatable.dart';

final class CourtTypeModel extends Equatable {
  const CourtTypeModel({this.id, this.name, this.slug});

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
    return <String, dynamic>{'id': id, 'name': name, 'slug': slug};
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
      imageUrl: PublicListingVenueModel._parseString(json['image_url']),
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

final class VenueShareModel extends Equatable {
  const VenueShareModel({
    this.title,
    this.description,
    this.address,
    this.startingPrice,
    this.url,
    this.deepLink,
    this.image,
    this.message,
  });

  final String? title;
  final String? description;
  final String? address;
  final double? startingPrice;
  final String? url;
  final String? deepLink;
  final String? image;
  final String? message;

  /// The link to put in a share, preferring the web URL over [deepLink].
  ///
  /// [deepLink] uses the app's private `hamrofutsal://` scheme: it is the right
  /// thing to hand the OS once the app is installed, but pasted into a chat it
  /// is dead text for everyone who does not have the app, and most targets will
  /// not even linkify it. The https URL opens for everyone and, as a universal
  /// link, still lands in the app for those who have it — so that is what gets
  /// shared, with the custom scheme kept only as a last resort.
  String? get shareUrl {
    final String webUrl = (url ?? '').trim();
    final Uri? parsed = Uri.tryParse(webUrl);
    if (webUrl.isNotEmpty &&
        parsed != null &&
        (parsed.scheme == 'http' || parsed.scheme == 'https')) {
      return webUrl;
    }

    final String appLink = (deepLink ?? '').trim();
    return appLink.isEmpty ? null : appLink;
  }

  /// The human sentence for a share, without any link appended.
  ///
  /// [shareText] bakes the link into the same string, which is what a plain
  /// text share needs; this keeps them separate so a link-only share can hand
  /// the URL to the OS as a URL and get a rich preview instead of a raw string.
  String? get shareMessage {
    for (final String? candidate in <String?>[message, title, description]) {
      final String text = (candidate ?? '').trim();
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  String? get shareText {
    final String text = (message ?? '').trim();
    if (text.isNotEmpty) {
      final String link = (deepLink ?? url ?? '').trim();
      if (link.isNotEmpty && !text.contains(link)) return '$text\n$link';
      return text;
    }

    final String link = (deepLink ?? url ?? '').trim();
    if (link.isEmpty) return null;
    final String heading = (title ?? description ?? '').trim();
    return heading.isEmpty ? link : '$heading\n$link';
  }

  factory VenueShareModel.fromJson(Map<String, dynamic> json) {
    return VenueShareModel(
      title: PublicListingVenueModel._parseString(json['title']),
      description: PublicListingVenueModel._parseString(json['description']),
      address: PublicListingVenueModel._parseString(json['address']),
      startingPrice: PublicListingVenueModel._parseDouble(
        json['starting_price'],
      ),
      url: PublicListingVenueModel._parseString(json['url']),
      deepLink: PublicListingVenueModel._parseString(json['deep_link']),
      image: PublicListingVenueModel._parseString(json['image']),
      message: PublicListingVenueModel._parseString(json['message']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'description': description,
      'address': address,
      'starting_price': startingPrice,
      'url': url,
      'deep_link': deepLink,
      'image': image,
      'message': message,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    title,
    description,
    address,
    startingPrice,
    url,
    deepLink,
    image,
    message,
  ];
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
    this.distanceKm,
    this.share,
    this.isVerified = false,
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
  final VenueShareModel? share;

  /// Whether the venue has been verified by Hamro Futsal.
  ///
  /// Defaults to false, so a payload without the flag simply shows no badge —
  /// an unverified venue must never be presented as verified.
  final bool isVerified;

  /// Road/haversine distance from the requested origin, in kilometres, as
  /// returned by the API (`distance_km`). Null when the request carried no
  /// `latitude`/`longitude`, or the venue has no coordinates.
  final double? distanceKm;

  /// [distanceKm] in metres, for callers that work in metres.
  double? get distanceMeters => distanceKm == null ? null : distanceKm! * 1000;

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
      distanceKm: _parseDistanceKm(json),
      share: _parseShare(json['share']),
      isVerified: _parseVerified(json),
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
    double? distanceKm,
    VenueShareModel? share,
    bool? isVerified,
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
      distanceKm: distanceKm ?? this.distanceKm,
      share: share ?? this.share,
      isVerified: isVerified ?? this.isVerified,
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
      'court_types': courtTypes
          ?.map((type) => type.toJson())
          .toList(growable: false),
      'max_player': maxPlayer,
      'min_time': minTime,
      'max_time': maxTime,
      'distance_km': distanceKm,
      'share': share?.toJson(),
      'is_verified': isVerified,
    };
  }

  static VenueShareModel? _parseShare(dynamic value) {
    if (value is Map) {
      return VenueShareModel.fromJson(Map<String, dynamic>.from(value));
    }
    return null;
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

  /// Reads the distance in kilometres.
  ///
  /// `distance_km` is what the venue listing sends; the metre-based keys are
  /// kept as a fallback for older responses and are converted on the way in, so
  /// the rest of the app only deals with kilometres.
  static double? _parseDistanceKm(Map<String, dynamic> json) {
    final double? km = _parseDouble(json['distance_km'] ?? json['distanceKm']);
    if (km != null) return km;

    final double? meters = _parseDouble(
      json['distance_meters'] ?? json['distance_meter'] ?? json['distance'],
    );
    return meters == null ? null : meters / 1000;
  }

  /// Reads the verified flag from whichever key the payload carries.
  ///
  /// The venue listing does not send one yet, so several spellings are
  /// accepted: a boolean (`is_verified`/`verified`) or a status string, where
  /// only `verified`/`approved` count — `pending` and `rejected` are not
  /// verified.
  static bool _parseVerified(Map<String, dynamic> json) {
    final dynamic flag = json['is_verified'] ?? json['verified'];
    if (flag != null) return _parseBool(flag) ?? false;

    final String status =
        _parseString(
          json['verification_status'] ?? json['verified_status'],
        )?.trim().toLowerCase() ??
        '';
    return status == 'verified' || status == 'approved';
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
            (Map item) =>
                CourtTypeModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    }
    return null;
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
    distanceKm,
    share,
    isVerified,
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
    this.lastPage,
    this.paginationMetaData = const <String, dynamic>{},
  });

  final List<PublicListingVenueModel> venues;
  final int page;
  final int perPage;
  final int total;

  /// Last page number from the API (`pagination.last_page`); null if absent.
  final int? lastPage;
  final Map<String, dynamic> paginationMetaData;

  /// 1-based index of the first/last row on this page (`pagination.from` /
  /// `pagination.to`); null when the API omits them.
  int? get from =>
      PublicListingVenueModel._parseInt(paginationMetaData['from']);

  int? get to => PublicListingVenueModel._parseInt(paginationMetaData['to']);

  /// Whether there is at least one more page to load after this one.
  ///
  /// An empty page always ends the list: without this, a server that answers
  /// `has_more_pages: true` with no rows would keep the loader spinning.
  bool get hasMore {
    if (venues.isEmpty) return false;

    // Prefer the API's explicit signal, then last_page, then a size estimate.
    final bool? hasMorePages = PublicListingVenueModel._parseBool(
      paginationMetaData['has_more_pages'],
    );
    if (hasMorePages != null) return hasMorePages;
    if (lastPage != null) return page < lastPage!;
    return page * perPage < total;
  }

  factory PublicListingVenuePage.fromJson(Map<String, dynamic> json) {
    // Unwrap the `{status, message, data: {venues: [...]}}` envelope.
    final dynamic dataField = json['data'];
    final Map<String, dynamic> root = dataField is Map
        ? Map<String, dynamic>.from(dataField)
        : json;

    final dynamic listSource =
        root['venues'] ??
        root['wishlists'] ??
        root['wishlist'] ??
        root['futsals'] ??
        root['items'] ??
        root['results'];
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
          .map((Map item) {
            final Map<String, dynamic> map = Map<String, dynamic>.from(item);
            final dynamic wrappedVenue =
                map['venue'] ?? map['futsal'] ?? map['court'];
            if (wrappedVenue is Map) {
              final Map<String, dynamic> venue = Map<String, dynamic>.from(
                wrappedVenue,
              );
              venue['id'] ??= map['venue_id'] ?? map['futsal_id'];
              return PublicListingVenueModel.fromJson(venue);
            }
            return PublicListingVenueModel.fromJson(map);
          })
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
      lastPage: PublicListingVenueModel._parseInt(
        meta['last_page'] ?? meta['lastPage'],
      ),
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
      'last_page': lastPage,
      'meta_data': paginationMetaData,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    venues,
    page,
    perPage,
    total,
    lastPage,
    paginationMetaData,
  ];
}
