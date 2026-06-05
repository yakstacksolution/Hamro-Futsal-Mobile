import 'package:equatable/equatable.dart';

/// Host information returned by `/hosted-by/{venue_id}`.
///
/// Response shape:
/// ```json
/// {
///   "status": "success",
///   "data": {
///     "hosted_by": {
///       "id": 4,
///       "name": "Dilli Bhandari",
///       "image": "https://.../scaled_1000066098.jpg",
///       "created_at": "2026-05-27 12:54:06",
///       "court_count": 1,
///       "venue_count": 2,
///       "rating": 0
///     }
///   }
/// }
/// ```
final class HostedByModel extends Equatable {
  const HostedByModel({
    this.id,
    this.name,
    this.image,
    this.hostingSince,
    this.courtCount,
    this.venueCount,
    this.rating,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? hostingSince;
  final int? courtCount;
  final int? venueCount;
  final double? rating;

  factory HostedByModel.fromJson(Map<String, dynamic> json) {
    return HostedByModel(
      id: _parseInt(json['id']),
      name: _parseString(json['name']),
      image: _parseString(json['image']),
      hostingSince: _parseSinceYear(json['created_at']),
      courtCount: _parseInt(json['court_count']),
      venueCount: _parseInt(json['venue_count']),
      rating: _parseDouble(json['rating']),
    );
  }

  bool get hasData => (name ?? '').trim().isNotEmpty;

  static String? _parseString(dynamic value) {
    final String text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  /// Accepts a date string ("2026-05-27 12:54:06") or a plain year ("2026")
  /// and returns just the year portion for the "Hosting since" label.
  static String? _parseSinceYear(dynamic value) {
    final String? text = _parseString(value);
    if (text == null) return null;
    final DateTime? date = DateTime.tryParse(text);
    if (date != null) return date.year.toString();
    return text;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    image,
    hostingSince,
    courtCount,
    venueCount,
    rating,
  ];
}
