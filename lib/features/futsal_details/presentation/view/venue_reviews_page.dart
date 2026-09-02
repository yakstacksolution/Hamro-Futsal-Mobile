import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/widgets/venue_review_widgets.dart';
import 'package:hamro_futsal/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/get_venue_reviews_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/bloc/venue_reviews/venue_reviews_bloc.dart';

/// Every review for a venue, five from the API at a time.
///
/// Reached from "View all" on the details page, which only ever shows the first
/// [kVenueReviewsPreviewSize]. This page owns its own bloc: the preview's
/// instance holds a different page size, and sharing it would make the two
/// surfaces fight over the same list.
class VenueReviewsPage extends StatefulWidget {
  const VenueReviewsPage({
    super.key,
    required this.venueId,
    this.venueName = '',
  });

  final int venueId;
  final String venueName;

  @override
  State<VenueReviewsPage> createState() => _VenueReviewsPageState();
}

class _VenueReviewsPageState extends State<VenueReviewsPage> {
  late final VenueReviewsBloc _bloc;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _bloc =
        VenueReviewsBloc(GetVenueReviewsUseCase(FutsalDetailsRepositoryImpl()))
          ..add(
            FetchVenueReviewsEvent(
              venueId: widget.venueId,
              perPage: kVenueReviewsPageSize,
            ),
          );
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl
      ..removeListener(_onScroll)
      ..dispose();
    _bloc.close();
    super.dispose();
  }

  /// Fetches ahead of the bottom so the next page is usually there by the time
  /// the reader arrives. The bloc guards against the repeat firings.
  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final double remaining =
        _scrollCtrl.position.maxScrollExtent - _scrollCtrl.position.pixels;
    if (remaining < 400) {
      _bloc.add(const LoadMoreVenueReviewsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VenueReviewsBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: LightColor.background,
        appBar: CustomAppBar(
          title: widget.venueName.isEmpty
              ? StringConstants.reviews
              : widget.venueName,
        ),
        body: SafeArea(
          top: false,
          child: BlocBuilder<VenueReviewsBloc, VenueReviewsState>(
            builder: (BuildContext context, VenueReviewsState state) {
              if (state.isLoading && state.reviews.isEmpty) {
                return const Center(child: LoadingWidget());
              }
              if (state.isFailure && state.reviews.isEmpty) {
                return _ReviewsError(
                  message: state.errorMessage,
                  onRetry: () => _bloc.add(
                    FetchVenueReviewsEvent(
                      venueId: widget.venueId,
                      perPage: kVenueReviewsPageSize,
                    ),
                  ),
                );
              }
              if (state.isEmpty) return const _ReviewsEmpty();

              final double inset = context.responsive<double>(
                mobile: AppDimens.paddingX20,
                tablet: AppDimens.paddingX32,
              );
              return RefreshIndicator(
                color: LightColor.brandTextColor,
                onRefresh: () async => _bloc.add(
                  FetchVenueReviewsEvent(
                    venueId: widget.venueId,
                    perPage: kVenueReviewsPageSize,
                    refresh: true,
                  ),
                ),
                child: ListView.separated(
                  controller: _scrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    inset,
                    AppDimens.paddingX16,
                    inset,
                    AppDimens.paddingX32,
                  ),
                  // Header + rows + footer.
                  itemCount: state.reviews.length + 2,
                  separatorBuilder: (_, int index) => SizedBox(
                    height: index == 0 ? AppDimens.sizeX16 : AppDimens.sizeX12,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return VenueRatingSummaryCard(
                        rating: state.page.averageRating,
                        reviewCount: state.totalCount,
                        breakdown: state.page.breakdown,
                      );
                    }
                    if (index == state.reviews.length + 1) {
                      return _ListFooter(state: state);
                    }
                    return VenueReviewCard(review: state.reviews[index - 1]);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Bottom-of-list status: a spinner while the next page loads, the reason it
/// stopped when it failed, and a full stop when everything is loaded.
class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.state});

  final VenueReviewsState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    if (state.isLoadingMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
        child: Center(
          child: SizedBox(
            width: AppDimens.sizeX22,
            height: AppDimens.sizeX22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: LightColor.brandTextColor,
            ),
          ),
        ),
      );
    }
    // A paging failure leaves the loaded rows in place, so it is reported here
    // rather than replacing the list with an error screen.
    if (state.errorMessage != null && state.reviews.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
        child: Center(
          child: TextButton.icon(
            onPressed: () => context.read<VenueReviewsBloc>().add(
              const LoadMoreVenueReviewsEvent(),
            ),
            icon: const Icon(Icons.refresh_rounded, size: AppDimens.sizeX16),
            label: Text(StringConstants.retry),
            style: TextButton.styleFrom(
              foregroundColor: LightColor.brandTextColor,
            ),
          ),
        ),
      );
    }
    if (!state.canLoadMore && state.reviews.length > kVenueReviewsPageSize) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX16),
        child: Center(
          child: Text(
            'That is every review.',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _ReviewsEmpty extends StatelessWidget {
  const _ReviewsEmpty();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: AppDimens.sizeX64,
              height: AppDimens.sizeX64,
              decoration: BoxDecoration(
                color: LightColor.categoryContainer(LightColor.secondaryColor),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rate_review_outlined,
                size: AppDimens.sizeX28,
                color: LightColor.brandTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX16),
            Text(
              'No reviews yet',
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX6),
            Text(
              'Play here and be the first to leave one.',
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsError extends StatelessWidget {
  const _ReviewsError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: AppDimens.sizeX32,
              color: LightColor.redColor,
            ),
            const SizedBox(height: AppDimens.sizeX12),
            Text(
              message ?? StringConstants.couldNotParseReviewsFromServer,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: AppDimens.sizeX16),
              label: Text(StringConstants.retry),
              style: TextButton.styleFrom(
                foregroundColor: LightColor.brandTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
