import 'package:equatable/equatable.dart';

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}'.trim()) ?? 0;
}

double _asDouble(dynamic v) {
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? ''}'.trim()) ?? 0;
}

String _asString(dynamic v) => (v ?? '').toString().trim();

/// One review on `/venues/{venue_id}/reviews`.
///
/// The reviewer may arrive either nested (`user: { name, avatar }`) or flat
/// (`user_name`, `reviewer_name`), so both are read.
class VenueReviewModel extends Equatable {
  const VenueReviewModel({
    this.id = 0,
    this.name = '',
    this.avatar = '',
    this.rating = 0,
    this.comment = '',
    this.createdAt,
    this.rawDate = '',
  });

  final int id;
  final String name;
  final String avatar;
  final double rating;
  final String comment;

  /// Parsed timestamp, when the server sent one this side could understand.
  final DateTime? createdAt;

  /// The server's own date string, used verbatim when [createdAt] is null so a
  /// format this parser does not know still reaches the screen.
  final String rawDate;

  /// Relative age — "2 days ago" reads better on a review than a raw date.
  /// Falls back to whatever string the server sent.
  String get displayDate {
    final DateTime? at = createdAt;
    if (at == null) return rawDate;
    final Duration age = DateTime.now().difference(at);
    if (age.inDays >= 365) {
      final int years = age.inDays ~/ 365;
      return years == 1 ? 'a year ago' : '$years years ago';
    }
    if (age.inDays >= 30) {
      final int months = age.inDays ~/ 30;
      return months == 1 ? 'a month ago' : '$months months ago';
    }
    if (age.inDays >= 1) {
      return age.inDays == 1 ? 'yesterday' : '${age.inDays} days ago';
    }
    if (age.inHours >= 1) {
      return age.inHours == 1 ? 'an hour ago' : '${age.inHours} hours ago';
    }
    if (age.inMinutes >= 1) return '${age.inMinutes} min ago';
    return 'just now';
  }

  factory VenueReviewModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : const <String, dynamic>{};
    final String rawDate = _asString(
      json['created_at'] ?? json['date'] ?? json['reviewed_at'],
    );
    return VenueReviewModel(
      id: _asInt(json['id'] ?? json['review_id']),
      name: _asString(
        user['name'] ??
            user['full_name'] ??
            json['user_name'] ??
            json['reviewer_name'] ??
            json['name'],
      ),
      avatar: _asString(
        user['avatar'] ??
            user['image'] ??
            user['profile_image'] ??
            json['avatar'],
      ),
      rating: _asDouble(json['rating'] ?? json['stars'] ?? json['score']),
      comment: _asString(
        json['comment'] ?? json['review'] ?? json['message'] ?? json['body'],
      ),
      createdAt: DateTime.tryParse(rawDate)?.toLocal(),
      rawDate: rawDate,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, name, rating, comment, rawDate];
}

/// How the venue's ratings are distributed, 5 stars down to 1.
///
/// The section used to draw this from hardcoded percentages; it now comes from
/// the server, and is derived from the loaded page when the server omits it.
class VenueRatingBreakdown extends Equatable {
  const VenueRatingBreakdown({this.counts = const <int, int>{}});

  /// Star value (1–5) to number of reviews at that value.
  final Map<int, int> counts;

  int get total => counts.values.fold(0, (int sum, int c) => sum + c);

  bool get isEmpty => total == 0;

  /// Share of all reviews at [star], as a 0–1 fraction for a progress bar.
  double fractionFor(int star) {
    final int all = total;
    if (all == 0) return 0;
    return (counts[star] ?? 0) / all;
  }

  factory VenueRatingBreakdown.fromJson(dynamic payload) {
    if (payload is! Map) return const VenueRatingBreakdown();
    final Map<int, int> counts = <int, int>{};
    payload.forEach((dynamic key, dynamic value) {
      // Keys arrive as "5" / 5 / "5_star" depending on the serializer.
      final int star = _asInt('$key'.replaceAll(RegExp(r'[^0-9]'), ''));
      if (star >= 1 && star <= 5) counts[star] = _asInt(value);
    });
    return VenueRatingBreakdown(counts: Map<int, int>.unmodifiable(counts));
  }

  /// Distribution of the reviews actually loaded. Only a fallback: it describes
  /// the current page, not the venue, so it is used when the server sent none.
  factory VenueRatingBreakdown.fromReviews(List<VenueReviewModel> reviews) {
    final Map<int, int> counts = <int, int>{};
    for (final VenueReviewModel review in reviews) {
      final int star = review.rating.round().clamp(1, 5);
      counts[star] = (counts[star] ?? 0) + 1;
    }
    return VenueRatingBreakdown(counts: Map<int, int>.unmodifiable(counts));
  }

  @override
  List<Object?> get props => <Object?>[counts];
}

/// One page of `/venues/{venue_id}/reviews?page=&per_page=`.
class VenueReviewPageModel extends Equatable {
  const VenueReviewPageModel({
    this.items = const <VenueReviewModel>[],
    this.averageRating = 0,
    this.breakdown = const VenueRatingBreakdown(),
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.hasMorePages = false,
  });

  final List<VenueReviewModel> items;
  final double averageRating;
  final VenueRatingBreakdown breakdown;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  static const VenueReviewPageModel empty = VenueReviewPageModel();

  VenueReviewPageModel copyWith({
    List<VenueReviewModel>? items,
    double? averageRating,
    VenueRatingBreakdown? breakdown,
    int? currentPage,
    int? lastPage,
    int? perPage,
    int? total,
    bool? hasMorePages,
  }) {
    return VenueReviewPageModel(
      items: items ?? this.items,
      averageRating: averageRating ?? this.averageRating,
      breakdown: breakdown ?? this.breakdown,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      perPage: perPage ?? this.perPage,
      total: total ?? this.total,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  factory VenueReviewPageModel.fromResponse(
    dynamic payload, {
    required int requestedPage,
    required int requestedPerPage,
  }) {
    final Map<String, dynamic> root = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    // A bare array is a valid response too — some endpoints skip the envelope
    // entirely when there is no pagination to report.
    final dynamic dataNode = payload is List ? payload : (root['data'] ?? root);
    final Map<String, dynamic> data = dataNode is Map
        ? Map<String, dynamic>.from(dataNode)
        : <String, dynamic>{};

    // The list is either the data node itself or one of the usual keys under it.
    final dynamic listNode = dataNode is List
        ? dataNode
        : (data['reviews'] ??
              data['items'] ??
              data['data'] ??
              data['results'] ??
              root['reviews']);
    final List<VenueReviewModel> items = listNode is List
        ? listNode
              .whereType<Map>()
              .map(
                (Map e) =>
                    VenueReviewModel.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList()
        : const <VenueReviewModel>[];

    final Map<String, dynamic> pagination = _mapOf(
      data['pagination'] ?? data['meta'] ?? root['pagination'] ?? root['meta'],
    );
    final Map<String, dynamic> summary = _mapOf(
      data['summary'] ?? data['rating_summary'] ?? root['summary'],
    );

    final int currentPage = pagination['current_page'] == null
        ? requestedPage
        : _asInt(pagination['current_page']);
    final int perPage = pagination['per_page'] == null
        ? requestedPerPage
        : _asInt(pagination['per_page']);
    // Without a `last_page`, a full page means another probably follows.
    final int lastPage = pagination['last_page'] == null
        ? (items.length >= perPage ? currentPage + 1 : currentPage)
        : _asInt(pagination['last_page']);

    final VenueRatingBreakdown breakdown = VenueRatingBreakdown.fromJson(
      summary['breakdown'] ??
          summary['distribution'] ??
          summary['rating_breakdown'] ??
          data['breakdown'] ??
          data['rating_distribution'],
    );

    return VenueReviewPageModel(
      items: List<VenueReviewModel>.unmodifiable(items),
      averageRating: _asDouble(
        summary['average_rating'] ??
            summary['average'] ??
            data['average_rating'] ??
            root['average_rating'],
      ),
      breakdown: breakdown.isEmpty
          ? VenueRatingBreakdown.fromReviews(items)
          : breakdown,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: pagination['total'] == null
          ? _asInt(
              summary['total_reviews'] ?? data['total_reviews'] ?? items.length,
            )
          : _asInt(pagination['total']),
      hasMorePages: pagination['has_more_pages'] == null
          ? currentPage < lastPage
          : pagination['has_more_pages'] == true,
    );
  }

  static Map<String, dynamic> _mapOf(dynamic value) => value is Map
      ? Map<String, dynamic>.from(value)
      : const <String, dynamic>{};

  @override
  List<Object?> get props => <Object?>[
    items,
    averageRating,
    breakdown,
    currentPage,
    lastPage,
    perPage,
    total,
    hasMorePages,
  ];
}
