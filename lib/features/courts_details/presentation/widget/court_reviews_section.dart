import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

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
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX20,
        top: AppDimens.paddingX12,
        right: AppDimens.paddingX20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  StringConstants.reviews,
                  style: textTheme.headingSubTitle?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX10,
                  vertical: AppDimens.paddingX4,
                ),
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                ),
                child: Text(
                  'See All ($reviewCount)',
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.inverseTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX14),
          _buildRatingSummary(context),
          const SizedBox(height: AppDimens.sizeX16),
          ...reviews.map((review) => _buildReviewCard(context, review)),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        boxShadow: [
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.35),
            blurRadius: AppDimens.sizeX18,
            offset: const Offset(0, AppDimens.sizeX8),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: textTheme.headingLarge?.copyWith(
                  color: LightColor.inverseTextColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX4),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating.floor()
                        ? Icons.star_rounded
                        : i < rating
                        ? Icons.star_half_rounded
                        : Icons.star_outline_rounded,
                    color: LightColor.inverseTextColor,
                    size: AppDimens.sizeX16,
                  );
                }),
              ),
              const SizedBox(height: AppDimens.sizeX4),
              Text(
                '$reviewCount reviews',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.inverseTextColor.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimens.sizeX22),
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

  Widget _buildReviewCard(BuildContext context, CourtReviewItem review) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.marginX12),
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.04),
            blurRadius: AppDimens.sizeX8,
            offset: const Offset(0, AppDimens.sizeX3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppDimens.sizeX40,
                height: AppDimens.sizeX40,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Center(
                  child: Text(
                    _safeInitial(review.name),
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.inverseTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      review.date,
                      style: textTheme.bodySubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX8,
                  vertical: AppDimens.paddingX4,
                ),
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: LightColor.inverseTextColor,
                      size: AppDimens.sizeX14,
                    ),
                    const SizedBox(width: AppDimens.sizeX3),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.inverseTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Text(
            review.comment,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
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
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX4),
      child: Row(
        children: [
          Text(
            label,
            style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
              color: LightColor.inverseTextColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: LightColor.inverseTextColor.withValues(
                  alpha: 0.15,
                ),
                color: LightColor.inverseTextColor,
                minHeight: AppDimens.sizeX4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
