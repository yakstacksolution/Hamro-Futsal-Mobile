import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class CourtReviewItem {
  const CourtReviewItem({
    required this.name,
    required this.date,
    required this.comment,
    required this.rating,
  });

  final String name;
  final String date;
  final String comment;
  final double rating;
}

class CourtReviewsSection extends StatelessWidget {
  const CourtReviewsSection({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.reviews,
  });

  final double rating;
  final int reviewCount;
  final List<CourtReviewItem> reviews;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Reviews',
                  style: TextStyle(
                    color: LightColor.titleText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: LightColor.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'See All ($reviewCount)',
                  style: const TextStyle(
                    color: LightColor.secondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRatingSummary(),
          const SizedBox(height: 16),
          ...reviews.map(_buildReviewCard),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LightColor.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: LightColor.secondary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating.floor()
                        ? Icons.star_rounded
                        : i < rating
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.white,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '$reviewCount reviews',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 22),
          const Expanded(
            child: Column(
              children: [
                _RatingBar(label: '5', value: 0.72),
                _RatingBar(label: '4', value: 0.18),
                _RatingBar(label: '3', value: 0.07),
                _RatingBar(label: '2', value: 0.02),
                _RatingBar(label: '1', value: 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(CourtReviewItem review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightColor.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightColor.border.withValues(alpha: 0.65)),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: LightColor.secondaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _safeInitial(review.name),
                    style: const TextStyle(
                      color: LightColor.secondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: const TextStyle(
                        color: LightColor.titleText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      review.date,
                      style: const TextStyle(
                        color: LightColor.subtitleText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LightColor.secondaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: LightColor.secondary,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: LightColor.secondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              color: LightColor.subtitleText,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  String _safeInitial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                color: Colors.white,
                minHeight: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
