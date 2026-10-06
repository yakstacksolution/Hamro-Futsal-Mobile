import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/review_change_request.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_review_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/submit_review_change_request_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/widgets/review_change_request_sheet.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/widgets/venue_review_widgets.dart';
import 'package:hamro_futsal/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/get_venue_reviews_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/bloc/venue_reviews/venue_reviews_bloc.dart';

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
    final FutsalDetailsRepositoryImpl repository =
        FutsalDetailsRepositoryImpl();
    _bloc =
        VenueReviewsBloc(
          GetVenueReviewsUseCase(repository),
          SubmitReviewChangeRequestUseCase(repository),
        )..add(
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

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final double remaining =
        _scrollCtrl.position.maxScrollExtent - _scrollCtrl.position.pixels;
    if (remaining < 400) {
      _bloc.add(const LoadMoreVenueReviewsEvent());
    }
  }

  Future<void> _onChangeRequest(
    VenueReviewModel review,
    ReviewChangeRequestType type,
  ) async {
    final ReviewChangeRequestInput? input = await ReviewChangeRequestSheet.show(
      context,
      type: type,
      initialComment: review.comment,
    );
    if (input == null || !mounted) return;
    _bloc.add(
      SubmitReviewChangeRequestEvent(reviewId: review.id, input: input),
    );
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
          child: BlocConsumer<VenueReviewsBloc, VenueReviewsState>(
            listenWhen: (VenueReviewsState prev, VenueReviewsState next) =>
                prev.changeRequestStatus != next.changeRequestStatus &&
                next.changeRequestStatus !=
                    ReviewChangeRequestStatus.submitting,
            listener: (BuildContext context, VenueReviewsState state) {
              final String? message = state.changeRequestMessage;
              if (message == null || message.isEmpty) return;
              AppUtils().showSnackBar(
                context,
                state.changeRequestStatus == ReviewChangeRequestStatus.success
                    ? MsgType.success
                    : MsgType.error,
                message,
              );
            },
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

              final Widget summary = VenueRatingSummaryCard(
                rating: state.page.averageRating,
                reviewCount: state.totalCount,
                breakdown: state.page.breakdown,
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
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool twoPane =
                        constraints.maxWidth >=
                        AppDimens.venueReviewsListMaxWidth +
                            AppDimens.venueReviewsSummaryWidth +
                            (AppDimens.venueDesktopGap * 3);

                    if (twoPane) {
                      return _ReviewsTwoPane(
                        controller: _scrollCtrl,
                        state: state,
                        summary: summary,
                        onChangeRequest: _onChangeRequest,
                      );
                    }

                    return _ReviewsSingleColumn(
                      controller: _scrollCtrl,
                      state: state,
                      summary: summary,
                      onChangeRequest: _onChangeRequest,
                    );
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

class _ReviewsSingleColumn extends StatelessWidget {
  const _ReviewsSingleColumn({
    required this.controller,
    required this.state,
    required this.summary,
    required this.onChangeRequest,
  });

  final ScrollController controller;
  final VenueReviewsState state;
  final Widget summary;
  final _ReviewChangeRequestCallback onChangeRequest;

  @override
  Widget build(BuildContext context) {
    final double inset = context.responsive<double>(
      mobile: AppDimens.paddingX20,
      tablet: AppDimens.paddingX32,
    );

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimens.venueReviewsListMaxWidth,
        ),
        child: ListView.separated(
          controller: controller,
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
            if (index == 0) return summary;
            return _ReviewListItem(
              state: state,
              index: index - 1,
              onChangeRequest: onChangeRequest,
            );
          },
        ),
      ),
    );
  }
}

class _ReviewsTwoPane extends StatelessWidget {
  const _ReviewsTwoPane({
    required this.controller,
    required this.state,
    required this.summary,
    required this.onChangeRequest,
  });

  final ScrollController controller;
  final VenueReviewsState state;
  final Widget summary;
  final _ReviewChangeRequestCallback onChangeRequest;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppDimens.venueReviewsShellMaxWidth,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX32,
            AppDimens.paddingX20,
            AppDimens.paddingX32,
            AppDimens.paddingX32,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: AppDimens.venueReviewsSummaryWidth,
                child: summary,
              ),
              const SizedBox(width: AppDimens.venueDesktopGap),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimens.venueReviewsListMaxWidth,
                    ),
                    child: ListView.separated(
                      controller: controller,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.zero,
                      itemCount: state.reviews.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppDimens.sizeX12),
                      itemBuilder: (BuildContext context, int index) {
                        return _ReviewListItem(
                          state: state,
                          index: index,
                          onChangeRequest: onChangeRequest,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _ReviewChangeRequestCallback =
    Future<void> Function(
      VenueReviewModel review,
      ReviewChangeRequestType type,
    );

class _ReviewListItem extends StatelessWidget {
  const _ReviewListItem({
    required this.state,
    required this.index,
    required this.onChangeRequest,
  });

  final VenueReviewsState state;
  final int index;
  final _ReviewChangeRequestCallback onChangeRequest;

  @override
  Widget build(BuildContext context) {
    if (index == state.reviews.length) {
      return _ListFooter(state: state);
    }

    final VenueReviewModel review = state.reviews[index];
    return VenueReviewCard(
      review: review,
      isSubmittingChangeRequest:
          state.isSubmittingChangeRequest &&
          state.changeRequestReviewId == review.id,
      onChangeRequest: (ReviewChangeRequestType type) =>
          onChangeRequest(review, type),
    );
  }
}

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
