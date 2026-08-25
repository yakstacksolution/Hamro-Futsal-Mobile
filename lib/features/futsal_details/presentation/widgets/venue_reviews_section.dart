import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_review_model.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/venue_reviews/venue_reviews_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/view/venue_reviews_page.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/venue_review_widgets.dart';

class VenueReviewsSection extends StatelessWidget {
  const VenueReviewsSection({
    super.key,
    required this.venueId,
    this.venueName = '',
    this.fallbackRating = 0,
    this.fallbackReviewCount = 0,
  });

  final int venueId;
  final String venueName;

  final double fallbackRating;
  final int fallbackReviewCount;

  void _openAll(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            VenueReviewsPage(venueId: venueId, venueName: venueName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueReviewsBloc, VenueReviewsState>(
      builder: (BuildContext context, VenueReviewsState state) {
        if (state.isFailure && state.reviews.isEmpty) {
          return const SizedBox.shrink();
        }
        if (state.isEmpty && fallbackReviewCount == 0) {
          return const SizedBox.shrink();
        }

        final double rating = state.page.averageRating > 0
            ? state.page.averageRating
            : fallbackRating;
        final int count = state.totalCount > 0
            ? state.totalCount
            : fallbackReviewCount;
        final List<VenueReviewModel> preview = state.reviews
            .take(kVenueReviewsPreviewSize)
            .toList();
        final bool hasReviews = count > 0 || preview.isNotEmpty;

        return Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.paddingX20,
            top: AppDimens.paddingX12,
            right: AppDimens.paddingX20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      StringConstants.reviews,
                      style: FutsalTheme.getTextTheme(context).headingSubTitle
                          ?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  if (hasReviews)
                    _SeeAllButton(count: count, onTap: () => _openAll(context)),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX14),
              VenueRatingSummaryCard(
                rating: rating,
                reviewCount: count,
                breakdown: state.page.breakdown,
              ),
              const SizedBox(height: AppDimens.sizeX16),
              if (state.isLoading && preview.isEmpty)
                const _PreviewSkeleton()
              else
                for (final VenueReviewModel review in preview)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.marginX12),
                    child: VenueReviewCard(review: review),
                  ),
            ],
          ),
        );
      },
    );
  }
}

class _SeeAllButton extends StatelessWidget {
  const _SeeAllButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.secondaryColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                count > 0 ? 'View all ($count)' : 'View all',
                style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                  color: LightColor.onBrandSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX2),
              Icon(
                Icons.chevron_right_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.onBrandSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder rows while the first five load, so the section keeps its height
/// instead of the page jumping when they arrive.
class _PreviewSkeleton extends StatelessWidget {
  const _PreviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        2,
        (_) => Container(
          height: AppDimens.sizeX72,
          margin: const EdgeInsets.only(bottom: AppDimens.marginX12),
          decoration: BoxDecoration(
            color: LightColor.skeletonBaseColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
        ),
      ),
    );
  }
}
