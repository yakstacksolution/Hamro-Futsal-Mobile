import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/helper/device_location_helper.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/dashboard_layout.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/loading/home_body_loading.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/venue_status_widget.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_venue/public_venue_bloc.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_footsall/core/helper/wishlist_store.dart';
import 'package:hamro_footsall/features/wishlist/domain/usecase/toggle_wishlist_use_case.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class FootsallHomePage extends StatelessWidget {
  const FootsallHomePage({super.key, this.filter = VenueFilter.empty});

  final VenueFilter filter;

  @override
  Widget build(BuildContext context) {
    return CourtsListScreen(filter: filter);
  }
}

class CourtsListScreen extends StatefulWidget {
  const CourtsListScreen({super.key, this.filter = VenueFilter.empty});

  final VenueFilter filter;

  @override
  State<CourtsListScreen> createState() => _CourtsListScreenState();
}

class _CourtsListScreenState extends State<CourtsListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late final PublicVenueBloc _publicVenueBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

    _publicVenueBloc = PublicVenueBloc(
      GetPublicVenuesUseCase(PublicRepositoryImpl()),
    )..add(FetchPublicVenuesEvent(filter: widget.filter));
    _scrollController.addListener(_onScroll);

    DashboardScreen.selectedNavIndex.addListener(_retryFailedFetchOnTabVisible);

    // Resolve the device position early: `GET /venues` carries it as
    // latitude/longitude, and the server computes `distance_km` from it.
    DeviceLocationHelper.instance.ensurePosition();
    DeviceLocationHelper.instance.position.addListener(_onPositionChanged);
  }

  void _retryFailedFetchOnTabVisible() {
    if (!mounted || DashboardScreen.selectedNavIndex.value != 0) return;
    if (_publicVenueBloc.state.status == PublicVenueStatus.failure) {
      _publicVenueBloc.add(FetchPublicVenuesEvent(filter: widget.filter));
    }
  }

  @override
  void didUpdateWidget(covariant CourtsListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      _publicVenueBloc.add(FetchPublicVenuesEvent(filter: widget.filter));
    }
  }

  @override
  void dispose() {
    DashboardScreen.selectedNavIndex.removeListener(
      _retryFailedFetchOnTabVisible,
    );
    DeviceLocationHelper.instance.position.removeListener(_onPositionChanged);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _publicVenueBloc.close();
    _animController.dispose();
    super.dispose();
  }

  /// Distance from the bottom of the list at which the next page is requested.
  static const double _loadMoreThreshold = 300;

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (!_publicVenueBloc.state.canLoadMore) return;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - _loadMoreThreshold) {
      _publicVenueBloc.add(const LoadMorePublicVenuesEvent());
    }
  }

  /// Requests the next page when the loaded venues do not fill the viewport.
  ///
  /// The scroll listener alone cannot cover this: with a short first page (or a
  /// tall tablet screen) there is nothing to scroll, so the list would sit at
  /// page 1 even though the server reports more.
  void _loadMoreIfViewportNotFilled() {
    if (!mounted || !_scrollController.hasClients) return;
    if (!_publicVenueBloc.state.canLoadMore) return;
    if (_scrollController.position.maxScrollExtent <= 0) {
      _publicVenueBloc.add(const LoadMorePublicVenuesEvent());
    }
  }

  /// Refetches the listing when a location fix arrives.
  ///
  /// The first page is requested before the GPS lock resolves, so it comes back
  /// without distances; re-running the query with coordinates is what fills the
  /// `distance_km` on the cards. Only the first fix triggers this — later
  /// updates would silently reset the user's scroll position.
  void _onPositionChanged() {
    if (!mounted) return;
    if (DeviceLocationHelper.instance.position.value == null) return;
    if (_publicVenueBloc.state.hasOrigin) return;
    _publicVenueBloc.add(FetchPublicVenuesEvent(filter: widget.filter));
  }

  Future<void> _refresh() async {
    context.read<ProfileBloc>().add(const FetchProfileEvent());
    _publicVenueBloc.add(FetchPublicVenuesEvent(filter: widget.filter));
    await _publicVenueBloc.stream.firstWhere(
      (PublicVenueState state) => state.status != PublicVenueStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PublicVenueBloc>.value(
      value: _publicVenueBloc,
      child: FadeTransition(
        opacity: _fadeIn,
        child: BlocBuilder<PublicVenueBloc, PublicVenueState>(
          builder: (BuildContext context, PublicVenueState state) {
            // Only the very first load shows the skeleton. A refetch (pull to
            // refresh, or the re-query once the GPS fix lands) keeps the cards
            // on screen instead of swapping the whole list for the shimmer.
            final bool showSkeleton =
                state.venues.isEmpty &&
                (state.status == PublicVenueStatus.loading ||
                    state.status == PublicVenueStatus.idle);

            final double horizontal = context.responsive<double>(
              mobile: AppDimens.paddingX20,
              tablet: AppDimens.paddingX32,
            );
            // Derived from the window, not from SliverConstraints: the sliver
            // ones change on every scroll frame, which would rebuild the whole
            // list each frame (see _buildContentSlivers).
            final double availableWidth =
                MediaQuery.sizeOf(context).width - (horizontal * 2);

            return showSkeleton
                ? const HomeBodyLoading()
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      color: LightColor.secondaryColor,
                      child: CustomScrollView(
                        controller: _scrollController,
                        // Keep the next cards laid out and their resized images
                        // decoded before they enter the viewport. This trades a
                        // small, bounded amount of memory for steadier flings.
                        scrollCacheExtent: const ScrollCacheExtent.pixels(700),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: SizedBox(height: AppDimens.sizeX22),
                          ),
                          ..._buildContentSlivers(state, availableWidth),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(
    PublicVenueState state,
    double availableWidth,
  ) {
    final List<PublicListingVenueModel> venues = state.venues;

    if (state.status == PublicVenueStatus.failure && venues.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimens.sizeX80),
              child: _VenueMessageView(
                icon: Icons.wifi_off_rounded,
                title: StringConstants.unableToLoadVenues,
                message:
                    state.errorMessage ??
                    'Please check your connection and try again.',
                actionLabel: 'Retry',
                onAction: () => _publicVenueBloc.add(
                  FetchPublicVenuesEvent(filter: widget.filter),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    if (venues.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimens.sizeX80),
              child: const _VenueMessageView(
                icon: Icons.stadium_outlined,
                title: StringConstants.noVenuesFound,
                message: StringConstants.thereAreNoFutsalVenuesToShowRightNow,
              ),
            ),
          ),
        ),
      ];
    }

    final List<PublicListingVenueModel> filtered = widget.filter.apply(venues);

    // A page that does not fill the screen leaves nothing to scroll, so top up
    // once the layout is known. `canLoadMore` makes this a no-op afterwards.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadMoreIfViewportNotFilled(),
    );

    if (filtered.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: AppDimens.sizeX80),
              child: const _VenueMessageView(
                icon: Icons.filter_alt_off_rounded,
                title: StringConstants.noMatchingVenues,
                message: StringConstants.tryAdjustingOrClearingYourFilters,
              ),
            ),
          ),
        ),
      ];
    }

    // One column on phone (unchanged), a grid from tablet up.
    //
    // Rows deliberately have no per-item entry animation: a staggered
    // Transform+Opacity per row repainted every frame (with a saveLayer per
    // card) is what made scrolling stutter. The page-level fade stays.

    // The column count comes from [availableWidth] rather than a
    // SliverLayoutBuilder. SliverConstraints carry the scroll offset, so a
    // sliver-level builder re-runs every frame of a scroll and hands the sliver
    // a fresh child delegate each time — which rebuilds every visible card on
    // every frame. Deriving it from the window keeps the delegate stable, so
    // scrolling only paints.
    final int columns = venueGridColumns(context, availableWidth);

    return <Widget>[
      SliverPadding(
        padding: const EdgeInsets.only(bottom: AppDimens.sizeX20),
        sliver: columns == 1
            ? SliverList.builder(
                itemCount: filtered.length,
                itemBuilder: (BuildContext context, int index) {
                  final PublicListingVenueModel venue = filtered[index];
                  return Padding(
                    key: ValueKey<Object>(venue.id ?? index),
                    padding: const EdgeInsets.only(bottom: AppDimens.sizeX20),
                    child: CourtCard(publicListingVenueModel: venue),
                  );
                },
              )
            : SliverGrid.builder(
                itemCount: filtered.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: AppDimens.sizeX20,
                  mainAxisSpacing: AppDimens.sizeX20,
                  mainAxisExtent: AppDimens.courtCardGridExtent,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final PublicListingVenueModel venue = filtered[index];
                  return CourtCard(
                    key: ValueKey<Object>(venue.id ?? index),
                    publicListingVenueModel: venue,
                    flexibleCover: true,
                  );
                },
              ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppDimens.sizeX4,
            bottom: AppDimens.sizeX120,
          ),
          child: _VenueListFooter(
            state: state,
            onRetry: () =>
                _publicVenueBloc.add(const RetryLoadMorePublicVenuesEvent()),
          ),
        ),
      ),
    ];
  }
}

/// Bottom-of-list state for the paginated venue listing: the next-page spinner
/// or a retry for a failed page.
class _VenueListFooter extends StatelessWidget {
  const _VenueListFooter({required this.state, required this.onRetry});

  final PublicVenueState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    if (state.isLoadingMore) {
      return const Center(
        child: CustomLoading(
          color: LightColor.secondaryColor,
          size: 24,
          strokeWidth: 3,
          secondCircleColor: LightColor.secondaryLight,
          thirdCircleColor: LightColor.secondaryLight,
        ),
      );
    }

    if (state.hasLoadMoreError) {
      return Column(
        children: <Widget>[
          Text(
            state.loadMoreErrorMessage ?? StringConstants.unableToLoadVenues,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
              size: AppDimens.sizeX16,
              color: LightColor.secondaryColor,
            ),
            label: Text(
              StringConstants.retry,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _VenueMessageView extends StatelessWidget {
  const _VenueMessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.paddingX24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: AppDimens.sizeX48,
            color: LightColor.secondaryTextColor,
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX16),
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded, size: AppDimens.sizeX18),
              label: Text(actionLabel!),
              style: OutlinedButton.styleFrom(
                foregroundColor: LightColor.secondaryColor,
                side: const BorderSide(color: LightColor.secondaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX20,
                  vertical: AppDimens.paddingX10,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class CourtCard extends StatefulWidget {
  final PublicListingVenueModel publicListingVenueModel;

  /// When true the cover image flexes to fill whatever height is left over
  /// instead of being pinned to [AppDimens.sizeX200].
  ///
  /// Set this in the grid layout, where the cell height is fixed: the text
  /// block below takes its natural height and the cover absorbs the rest, so
  /// the card can never overflow its cell. The list layout leaves it false and
  /// keeps the original fixed-height cover.
  final bool flexibleCover;

  const CourtCard({
    super.key,
    required this.publicListingVenueModel,
    this.flexibleCover = false,
  });

  @override
  State<CourtCard> createState() => _CourtCardState();
}

class _CourtCardState extends State<CourtCard> {
  bool _isPressed = false;
  bool _isHovered = false;

  /// The richer treatment is only used from tablet up; phones keep the
  /// original card exactly as it was.
  bool get _wide => context.isTabletOrWider;

  Future<void> _toggleWishlist() async {
    final int? venueId = widget.publicListingVenueModel.id;
    if (venueId == null) return;
    HapticFeedback.selectionClick();
    final String? error = await ToggleWishlistUseCase(PublicRepositoryImpl())(
      venueId,
    );
    if (error != null && mounted) {
      AppUtils().showSnackBar(context, MsgType.error, error);
    }
  }

  Widget _cover() {
    // Only the decode *width* is hinted: passing both width and height makes the
    // codec resize to exactly those dimensions, which squashes photos whose
    // aspect ratio differs from the cover box. Height follows from the aspect
    // ratio, and BoxFit.cover crops the overflow.
    final Widget image = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomImageView(
              url: widget.publicListingVenueModel.featureImage,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              cacheWidth: constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : null,
            ),
            Positioned(
              top: 12,
              right: 12,
              child: _WishlistButton(
                venueId: widget.publicListingVenueModel.id,
                onTap: _toggleWishlist,
              ),
            ),
          ],
        );
      },
    );

    // Grid cells have a fixed height, so the cover flexes; list items keep the
    // original pinned height. One clip either way.
    final Widget clipped = ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(_wide ? AppDimens.radiusX24 : AppDimens.radiusX18),
      ),
      child: widget.flexibleCover
          ? image
          : SizedBox(height: AppDimens.sizeX200, child: image),
    );

    return widget.flexibleCover ? Expanded(child: clipped) : clipped;
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = _wide;
    // Resolved once: getTextTheme() rebuilds ten TextStyles per call, and the
    // card reads five of them.
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    // Hover only means something with a pointer, i.e. desktop; it also drives
    // the click cursor, which the phone card has no use for.
    final bool lifted = wide && _isHovered;

    final Widget card = AnimatedScale(
      scale: _isPressed
          ? 0.985
          : lifted
          ? 1.01
          : 1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(
            wide ? AppDimens.radiusX24 : AppDimens.radiusX18,
          ),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowOf(lifted ? 0.12 : 0.03),
              blurRadius: lifted ? AppDimens.sizeX24 : AppDimens.sizeX8,
              spreadRadius: 0.5,
              offset: Offset(0, lifted ? 6 : 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cover(),

            Padding(
              padding: EdgeInsets.all(
                wide ? AppDimens.sizeX18 : AppDimens.sizeX14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.publicListingVenueModel.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                      fontSize: wide ? AppDimens.fontHeadingSubTitle : null,
                    ),
                  ),
                  SizedBox(height: wide ? AppDimens.sizeX8 : AppDimens.sizeX6),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CustomImageView(
                              imagePath: ImageConstants.locationIcon,
                              height: AppDimens.sizeX14,
                              width: AppDimens.sizeX14,
                              fit: BoxFit.contain,
                              color: LightColor.secondaryTextColor,
                            ),
                            const SizedBox(width: AppDimens.sizeX6),
                            Flexible(
                              child: Text(
                                widget.publicListingVenueModel.address ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyTextSmall?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimens.sizeX12),
                      _DistanceLabel(venue: widget.publicListingVenueModel),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sizeX12),
                  // Price left, status right. The column count is derived from
                  // a minimum card width (see venueGridColumns), so the cell is
                  // always wide enough for both on one line.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // One rich text rather than a Row of two: the "/ hour"
                      // suffix sits at the end, so it is what ellipsizes first
                      // if the cell is ever tighter than expected -- the price
                      // digits stay visible.
                      Flexible(
                        child: Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text:
                                    widget.publicListingVenueModel.price == null
                                    ? 'Rs. --'
                                    : 'Rs. ${widget.publicListingVenueModel.price!.toStringAsFixed(0)}',
                                style: textTheme.headingSubTitle?.copyWith(
                                  color: LightColor.secondaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              TextSpan(
                                text: ' ${StringConstants.perHourSuffix}',
                                style: textTheme.bodyTextMedium?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppDimens.sizeX8),
                      VenueStatusWidget(
                        isOpen: widget.publicListingVenueModel.isOpen ?? false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    final Widget tappable = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        context.pushNamed(
          AppRouterParams.courtDetails.name,
          extra: widget.publicListingVenueModel,
        );
      },
      child: card,
    );

    if (!wide) return tappable;

    // Pointer affordances for tablet/desktop: a click cursor and a hover lift.
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: tappable,
    );
  }
}

/// Save/unsave chip on the cover.
///
/// Split out of [CourtCard] so a wishlist change repaints this 36px chip
/// instead of rebuilding the whole card subtree.
class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.venueId, required this.onTap});

  final int? venueId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: WishlistStore.instance.ids,
      builder: (BuildContext context, Set<int> ids, _) {
        final bool saved = venueId != null && ids.contains(venueId);
        return GestureDetector(
          onTap: onTap,
          // A solid translucent chip rather than a BackdropFilter: the blur
          // forced a saveLayer for every card on screen, which is expensive on
          // every scroll frame for no visible gain here.
          child: Container(
            height: AppDimens.sizeX36,
            width: AppDimens.sizeX36,
            decoration: BoxDecoration(
              // The chip follows the card surface rather than being pinned to
              // white: a white chip forced the heart to stay dark, and the
              // unsaved grey then vanished against it in dark mode.
              color: LightColor.elevatedCardColor.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: LightColor.elevatedCardColor.withValues(alpha: 0.6),
              ),
            ),
            child: Icon(
              saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: saved
                  ? LightColor.successColor
                  : LightColor.secondaryTextColor,
              size: AppDimens.sizeX22,
            ),
          ),
        );
      },
    );
  }
}

/// Distance for one venue, as reported by the API.
///
/// `distance_km` is computed server-side from the `latitude`/`longitude` sent
/// with the listing request, so there is nothing to resolve on the client:
/// either the venue carries a distance or the label is omitted.
class _DistanceLabel extends StatelessWidget {
  const _DistanceLabel({required this.venue});

  final PublicListingVenueModel venue;

  @override
  Widget build(BuildContext context) {
    final String? text = _formatHomeDistanceKm(venue.distanceKm);
    if (text == null) return const SizedBox.shrink();

    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
        color: LightColor.secondaryTextColor.withValues(alpha: 0.8),
      ),
    );
  }

  /// Converts the API's numeric `distance_km` to home-card text without
  /// throwing away its precision. Trailing zeroes are removed, so values such
  /// as 184.50 remain compact while 21.53 is not rounded to 22.
  static String? _formatHomeDistanceKm(double? distanceKm) {
    if (distanceKm == null || !distanceKm.isFinite || distanceKm < 0) {
      return null;
    }

    final String value = distanceKm
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'\.?0+$'), '');
    return '$value km';
  }
}
