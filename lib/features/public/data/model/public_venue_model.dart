import 'package:equatable/equatable.dart';

final class PublicVenueModel extends Equatable {
  const PublicVenueModel({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.image,
    required this.isOpen,
    required this.distance,
    required this.features,
    required this.raw,
  });

  final String id;
  final String name;
  final String location;
  final String price;
  final double rating;
  final int reviewCount;
  final String image;
  final bool isOpen;
  final String distance;
  final List<String> features;
  final Map<String, dynamic> raw;

  factory PublicVenueModel.fromJson(Map<String, dynamic> json) {
    return PublicVenueModel(
      id: (json['id'] ?? json['_id'] ?? json['uuid'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? json['venue_name'] ?? '')
          .toString(),
      location:
          (json['location'] ?? json['address'] ?? json['city'] ?? '')
              .toString(),
      price: (json['price'] ?? json['hourly_rate'] ?? json['rate'] ?? '')
          .toString(),
      rating: _parseDouble(json['rating'] ?? json['avg_rating']),
      reviewCount: _parseInt(json['review_count'] ?? json['reviews']),
      image: (json['image'] ?? json['cover_image'] ?? json['logo'] ?? '')
          .toString(),
      isOpen: _parseBool(json['is_open'] ?? json['open']),
      distance: (json['distance'] ?? '').toString(),
      features: _parseFeatures(json['features'] ?? json['amenities']),
      raw: Map<String, dynamic>.from(json),
    );
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

  static List<String> _parseFeatures(dynamic value) {
    if (value is List) {
      return value
          .map((dynamic item) => item.toString())
          .where((String item) => item.trim().isNotEmpty)
          .toList(growable: false);
    }
    return const <String>[];
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    location,
    price,
    rating,
    reviewCount,
    image,
    isOpen,
    distance,
    features,
    raw,
  ];
}

/// A single page of public venues plus the pagination metadata needed to
/// decide whether more pages can be fetched.
final class PublicVenuePage extends Equatable {
  const PublicVenuePage({
    required this.venues,
    required this.page,
    required this.perPage,
    required this.total,
  });

  final List<PublicVenueModel> venues;
  final int page;
  final int perPage;
  final int total;

  /// Whether there is at least one more page to load after this one.
  bool get hasMore => page * perPage < total;

  factory PublicVenuePage.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json['venues'] ?? json['items'];
    final List<dynamic> items = data is List ? data : const <dynamic>[];

    final Map<String, dynamic> meta = json['meta'] is Map
        ? Map<String, dynamic>.from(json['meta'] as Map)
        : json;

    return PublicVenuePage(
      venues: items
          .whereType<Map>()
          .map(
            (Map item) =>
                PublicVenueModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      page: PublicVenueModel._parseInt(
        meta['current_page'] ?? meta['page'] ?? 1,
      ),
      perPage: PublicVenueModel._parseInt(
        meta['per_page'] ?? meta['perPage'] ?? items.length,
      ),
      total: PublicVenueModel._parseInt(
        meta['total'] ?? meta['total_count'] ?? items.length,
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[venues, page, perPage, total];
}
