import 'package:equatable/equatable.dart';

/// The review a customer left on one booking, from
/// `GET|POST /bookings/{booking_id}/review`.
class BookingReviewModel extends Equatable {
  const BookingReviewModel({
    this.id = 0,
    this.rating = 0,
    this.review = '',
    this.createdAt,
  });

  final int id;
  final double rating;
  final String review;
  final DateTime? createdAt;

  /// A payload can come back shaped like a review but carry no actual rating,
  /// which is the server saying "nothing here" in a 200.
  bool get isEmpty => rating <= 0 && review.isEmpty;

  factory BookingReviewModel.fromJson(Map<String, dynamic> json) {
    final String rawDate = (json['created_at'] ?? json['reviewed_at'] ?? '')
        .toString()
        .trim();
    return BookingReviewModel(
      id: int.tryParse('${json['id'] ?? ''}'.trim()) ?? 0,
      rating:
          double.tryParse('${json['rating'] ?? json['stars'] ?? ''}'.trim()) ??
          0,
      review: (json['review'] ?? json['comment'] ?? json['message'] ?? '')
          .toString()
          .trim(),
      createdAt: DateTime.tryParse(rawDate)?.toLocal(),
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
    if (node is List) node = node.isEmpty ? null : node.first;
    if (node is! Map) return null;
    final BookingReviewModel parsed = BookingReviewModel.fromJson(
      Map<String, dynamic>.from(node),
    );
    return parsed.isEmpty ? null : parsed;
  }

  @override
  List<Object?> get props => <Object?>[id, rating, review, createdAt];
}
