import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_review_model.dart';

/// Average rating plus the star distribution, shared by the details-page
/// preview and the full reviews page so both read identically.
class VenueRatingSummaryCard extends StatelessWidget {
  const VenueRatingSummaryCard({
    super.key,
    required this.rating,
    required this.reviewCount,
    required this.breakdown,
  });

  final double rating;
  final int reviewCount;

  /// Real counts from the server. The bars used to be hardcoded percentages.
  final VenueRatingBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[LightColor.secondaryColor, LightColor.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                rating.toStringAsFixed(1),
                style: textTheme.headingLarge?.copyWith(
                  color: LightColor.onBrandSurface,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX4),
              _Stars(rating: rating, color: LightColor.onBrandSurface),
              const SizedBox(height: AppDimens.sizeX4),
              Text(
                reviewCount == 1 ? '1 review' : '$reviewCount reviews',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.onBrandSurface.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimens.sizeX22),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int star = 5; star >= 1; star--)
                  _RatingBar(
                    label: '$star',
                    value: breakdown.fractionFor(star),
                    count: breakdown.counts[star] ?? 0,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One review: reviewer, when, what they said, and their score.
class VenueReviewCard extends StatelessWidget {
  const VenueReviewCard({super.key, required this.review});

  final VenueReviewModel review;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _Avatar(name: review.name, url: review.avatar),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      review.name.isEmpty ? 'Anonymous' : review.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (review.displayDate.isNotEmpty)
                      Text(
                        review.displayDate,
                        style: textTheme.bodyMiniSubTitle?.copyWith(
                          color: LightColor.hintTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              _ScorePill(rating: review.rating),
            ],
          ),
          if (review.comment.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            Text(
              review.comment,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.url});

  final String name;
  final String url;

  static const double _size = AppDimens.sizeX40;

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: CustomImageView(
          url: url,
          width: _size,
          height: _size,
          cacheWidth: _size * 2,
          cacheHeight: _size * 2,
          fit: BoxFit.cover,
        ),
      );
    }
    final String initial = name.trim().isEmpty
        ? '?'
        : name.trim().substring(0, 1).toUpperCase();
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Text(
        initial,
        style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
          color: LightColor.onBrandSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: <Widget>[
          Icon(
            Icons.star_rounded,
            color: LightColor.onBrandSurface,
            size: AppDimens.sizeX14,
          ),
          const SizedBox(width: AppDimens.sizeX3),
          Text(
            rating.toStringAsFixed(1),
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.onBrandSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating, required this.color});

  final double rating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(5, (int i) {
        return Icon(
          i < rating.floor()
              ? Icons.star_rounded
              : i < rating
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded,
          color: color,
          size: AppDimens.sizeX16,
        );
      }),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.label,
    required this.value,
    required this.count,
  });

  final String label;
  final double value;
  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.paddingX4),
      child: Row(
        children: <Widget>[
          Text(
            label,
            style: textTheme.bodySubTitle?.copyWith(
              color: LightColor.onBrandSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: LightColor.onBrandSurface.withValues(
                  alpha: 0.15,
                ),
                color: LightColor.onBrandSurface,
                minHeight: AppDimens.sizeX4,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sizeX8),
          SizedBox(
            width: AppDimens.sizeX24,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.onBrandSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
