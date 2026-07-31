import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/helper/venue_distance_helper.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'dart:ui';
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

    _publicVenueBloc = PublicVenueBloc(
      GetPublicVenuesUseCase(PublicRepositoryImpl()),
    )..add(FetchPublicVenuesEvent(filter: widget.filter));
    _scrollController.addListener(_onScroll);

    // Tabs stay alive inside the dashboard's IndexedStack, so a fetch that
    // failed while offline would otherwise show a stale error forever.
    // Re-fetch automatically whenever this tab becomes visible again.
    DashboardScreen.selectedNavIndex.addListener(_retryFailedFetchOnTabVisible);

    // Resolve the device position early so venue cards can show distances.
    VenueDistanceHelper.instance.ensurePosition();
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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _publicVenueBloc.close();
    _animController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 300) {
      _publicVenueBloc.add(const LoadMorePublicVenuesEvent());
    }
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
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return BlocProvider<PublicVenueBloc>.value(
      value: _publicVenueBloc,
      child: FadeTransition(
        opacity: _fadeIn,
        child: BlocBuilder<PublicVenueBloc, PublicVenueState>(
          builder: (BuildContext context, PublicVenueState state) {
            final bool showSkeleton =
                state.status == PublicVenueStatus.loading ||
                state.status == PublicVenueStatus.idle;
            return showSkeleton
                ? const HomeBodyLoading()
                : Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.responsive<double>(
                        mobile: AppDimens.paddingX20,
                        tablet: AppDimens.paddingX32,
                      ),
                    ),
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      color: LightColor.secondaryColor,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: SizedBox(height: AppDimens.sizeX22),
                          ),
                          ..._buildContentSlivers(state),
                        ],
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  List<Widget> _buildContentSlivers(PublicVenueState state) {
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

    Widget animateIn(int index, Widget child) {
      return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(milliseconds: 500 + index * 120),
        curve: Curves.easeOutCubic,
        builder: (BuildContext context, double value, Widget? animated) =>
            Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value, child: animated),
            ),
        child: child,
      );
    }

    return <Widget>[
      SliverLayoutBuilder(
        builder: (BuildContext context, SliverConstraints sliverConstraints) {
          final int columns = venueGridColumns(
            context,
            sliverConstraints.crossAxisExtent,
          );
          return SliverPadding(
            padding: const EdgeInsets.only(bottom: AppDimens.sizeX20),
            sliver: columns == 1
                ? SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (BuildContext context, int index) {
                      return animateIn(
                        index,
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppDimens.sizeX20,
                          ),
                          child: CourtCard(
                            publicListingVenueModel: filtered[index],
                          ),
                        ),
                      );
                    },
                  )
                : SliverGrid.builder(
                    itemCount: filtered.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: AppDimens.sizeX20,
                      mainAxisSpacing: AppDimens.sizeX20,
                      // A fixed row height rather than childAspectRatio: card
                      // height then does not depend on column width, so it cannot
                      // overflow at some widths. The cover flexes to fill it.
                      mainAxisExtent: AppDimens.courtCardGridExtent,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return animateIn(
                        index,
                        CourtCard(
                          publicListingVenueModel: filtered[index],
                          flexibleCover: true,
                        ),
                      );
                    },
                  ),
          );
        },
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(
            top: AppDimens.sizeX4,
            bottom: AppDimens.sizeX120,
          ),
          child: state.isLoadingMore
              ? const Center(
                  child: CustomLoading(
                    color: LightColor.secondaryColor,
                    size: 24,
                    strokeWidth: 3,
                    secondCircleColor: LightColor.secondaryLight,
                    thirdCircleColor: LightColor.secondaryLight,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    ];
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

  PublicListingVenueModel _courtWithDistance() {
    final double? latitude = widget.publicListingVenueModel.latitude;
    final double? longitude = widget.publicListingVenueModel.longitude;
    if (latitude == null || longitude == null)
      return widget.publicListingVenueModel;

    return widget.publicListingVenueModel.copyWith(
      distanceMeters:
          widget.publicListingVenueModel.distanceMeters ??
          VenueDistanceHelper.instance.distanceMeters(latitude, longitude),
    );
  }

  Widget _cover() {
    final Widget image = Stack(
      fit: StackFit.expand,
      children: [
        CustomImageView(
          url: widget.publicListingVenueModel.featureImage,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        Positioned(
          top: 12,
          right: 12,
          child: ValueListenableBuilder<Set<int>>(
            valueListenable: WishlistStore.instance.ids,
            builder: (context, ids, _) {
              final bool saved =
                  widget.publicListingVenueModel.id != null &&
                  ids.contains(widget.publicListingVenueModel.id);
              return GestureDetector(
                onTap: _toggleWishlist,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      height: AppDimens.sizeX36,
                      width: AppDimens.sizeX36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Icon(
                        saved
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: saved
                            ? LightColor.secondaryColor
                            : LightColor.secondaryTextColor,
                        size: AppDimens.sizeX22,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    final Widget clipped = ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(_wide ? AppDimens.radiusX24 : AppDimens.radiusX18),
      ),
      child: image,
    );

    // Grid cells have a fixed height, so the cover flexes; list items keep the
    // original pinned height.
    return widget.flexibleCover
        ? Expanded(child: clipped)
        : ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusX18),
            ),
            child: SizedBox(height: AppDimens.sizeX200, child: image),
          );
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = _wide;
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
              color: Colors.black.withValues(alpha: lifted ? 0.12 : 0.03),
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
                    style: FutsalTheme.getTextTheme(context).bodyTextLarge
                        ?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: wide ? AppDimens.fontHeadingSubTitle : null,
                        ),
                  ),
                  SizedBox(height: wide ? AppDimens.sizeX8 : AppDimens.sizeX6),

                  Row(
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
                          style: FutsalTheme.getTextTheme(context).bodyTextSmall
                              ?.copyWith(color: LightColor.secondaryTextColor),
                        ),
                      ),
                      _DistanceLabel(court: widget.publicListingVenueModel),
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
                                style: FutsalTheme.getTextTheme(context)
                                    .headingSubTitle
                                    ?.copyWith(
                                      color: LightColor.secondaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              TextSpan(
                                text: ' ${StringConstants.perHourSuffix}',
                                style: FutsalTheme.getTextTheme(context)
                                    .bodyTextMedium
                                    ?.copyWith(
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
          extra: _courtWithDistance(),
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

class _DistanceLabel extends StatefulWidget {
  const _DistanceLabel({required this.court});

  final PublicListingVenueModel court;

  @override
  State<_DistanceLabel> createState() => _DistanceLabelState();
}

class _DistanceLabelState extends State<_DistanceLabel> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      VenueDistanceHelper.instance.ensurePosition();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Position?>(
      valueListenable: VenueDistanceHelper.instance.position,
      builder: (BuildContext context, Position? position, Widget? child) {
        if (position == null) {
          return const SizedBox.shrink();
        }

        final double? latitude = widget.court.latitude;
        final double? longitude = widget.court.longitude;

        if (latitude == null || longitude == null) {
          return const SizedBox.shrink();
        }

        final String? distance =
            _formatDistanceMeters(widget.court.distanceMeters) ??
            VenueDistanceHelper.instance.formatDistance(latitude, longitude);

        if (distance == null) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: AppDimens.sizeX10),
            Container(
              width: AppDimens.sizeX3,
              height: AppDimens.sizeX3,
              decoration: BoxDecoration(
                color: LightColor.secondaryTextColor.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppDimens.sizeX28),
            Text(
              distance,
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        );
      },
    );
  }

  String? _formatDistanceMeters(double? meters) {
    if (meters == null) return null;
    if (meters < 1000) return '${meters.round()} m';
    final double km = meters / 1000;
    return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
  }
}
