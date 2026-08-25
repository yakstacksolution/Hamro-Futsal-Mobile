import 'package:equatable/equatable.dart';

/// The review a customer left on one booking, from
/// `GET|POST /bookings/{booking_id}/review`.
class BookingReviewModel extends Equatable {
  const BookingReviewModel({
    this.id = 0,
    this.bookingId = 0,
    this.userId = 0,
    this.venueId = 0,
    this.courtId = 0,
    this.rating = 0,
    this.review = '',
    this.status = '',
    this.createdAt,
  });

  final int id;
  final int bookingId;
  final int userId;
  final int venueId;
  final int courtId;
  final double rating;
  final String review;
  final String status;
  final DateTime? createdAt;

  /// A payload can come back shaped like a review but carry no actual rating,
  /// which is the server saying "nothing here" in a 200.
  bool get isEmpty => rating <= 0 && review.isEmpty;

  String get statusLabel {
    final String value = status.trim();
    if (value.isEmpty) return '';
    return value[0].toUpperCase() + value.substring(1).replaceAll('_', ' ');
  }

  String get displayDate {
    final DateTime? at = createdAt;
    if (at == null) return '';
    final Duration age = DateTime.now().difference(at);
    if (age.inDays >= 1) {
      return age.inDays == 1 ? 'Yesterday' : '${age.inDays} days ago';
    }
    if (age.inHours >= 1) {
      return age.inHours == 1 ? '1 hour ago' : '${age.inHours} hours ago';
    }
    if (age.inMinutes >= 1) return '${age.inMinutes} min ago';
    return 'Just now';
  }

  factory BookingReviewModel.fromJson(Map<String, dynamic> json) {
    final String rawDate = (json['created_at'] ?? json['reviewed_at'] ?? '')
        .toString()
        .trim();
    return BookingReviewModel(
      id: int.tryParse('${json['id'] ?? ''}'.trim()) ?? 0,
      bookingId: int.tryParse('${json['booking_id'] ?? ''}'.trim()) ?? 0,
      userId: int.tryParse('${json['user_id'] ?? ''}'.trim()) ?? 0,
      venueId: int.tryParse('${json['venue_id'] ?? ''}'.trim()) ?? 0,
      courtId: int.tryParse('${json['court_id'] ?? ''}'.trim()) ?? 0,
      rating:
          double.tryParse('${json['rating'] ?? json['stars'] ?? ''}'.trim()) ??
          0,
      review: (json['review'] ?? json['comment'] ?? json['message'] ?? '')
          .toString()
          .trim(),
      status: (json['status'] ?? '').toString().trim(),
      createdAt: DateTime.tryParse(rawDate.replaceFirst(' ', 'T'))?.toLocal(),
    );
  }

  /// Null when the booking has not been reviewed.
  ///
  /// The endpoint expresses "no review" in more than one way depending on the
  /// path taken — an absent `data`, an explicit null, an empty object, or an
  /// empty list — so all of them resolve to null rather than an empty review
  /// that the UI would then have to re-check.
  static BookingReviewModel? fromResponse(dynamic payload) {
    dynamic node = payload;
    if (node is Map && node['data'] != null) node = node['data'];
    if (node is Map && node['review'] != null) node = node['review'];
    if (node is List) node = node.isEmpty ? null : node.first;
    if (node is! Map) return null;
    final BookingReviewModel parsed = BookingReviewModel.fromJson(
      Map<String, dynamic>.from(node),
    );
    return parsed.isEmpty ? null : parsed;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    bookingId,
    userId,
    venueId,
    courtId,
    rating,
    review,
    status,
    createdAt,
  ];
}
