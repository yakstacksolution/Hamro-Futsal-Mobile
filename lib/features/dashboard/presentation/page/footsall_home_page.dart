import 'package:flutter/material.dart';
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
import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/loading/home_body_loading.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/venue_status_widget.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_venue/public_venue_bloc.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';

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

    // Resolve the device position early so venue cards can show distances.
    VenueDistanceHelper.instance.ensurePosition();
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
            // Show the skeleton only when there is nothing to render yet —
            // location-triggered refetches keep the current list on screen
            // instead of flashing the loading state again.
            final bool showSkeleton =
                state.status == PublicVenueStatus.loading &&
                state.venues.isEmpty;
            return showSkeleton
                ? const HomeBodyLoading()
                : Padding(
                    padding: AppUtils().getPadding(
                      left: AppDimens.paddingX20,
                      right: AppDimens.paddingX20,
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
              padding: AppUtils().getPadding(top: AppDimens.sizeX80),
              child: _VenueMessageView(
                icon: Icons.wifi_off_rounded,
                title: 'Unable to load venues',
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
              padding: AppUtils().getPadding(top: AppDimens.sizeX80),
              child: const _VenueMessageView(
                icon: Icons.stadium_outlined,
                title: 'No venues found',
                message: 'There are no futsal venues to show right now.',
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
              padding: AppUtils().getPadding(top: AppDimens.sizeX80),
              child: const _VenueMessageView(
                icon: Icons.filter_alt_off_rounded,
                title: 'No matching venues',
                message: 'Try adjusting or clearing your filters.',
              ),
            ),
          ),
        ),
      ];
    }

    return <Widget>[
      SliverPadding(
        padding: AppUtils().getPadding(bottom: AppDimens.sizeX20),
        sliver: SliverList.builder(
          itemCount: filtered.length,
          itemBuilder: (BuildContext context, int index) {
            return TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 500 + index * 120),
              curve: Curves.easeOutCubic,
              builder: (BuildContext context, double value, Widget? child) =>
                  Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  ),
              child: Padding(
                padding: AppUtils().getPadding(bottom: AppDimens.sizeX20),
                child: CourtCard(court: filtered[index]),
              ),
            );
          },
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: AppUtils().getPadding(
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
      padding: AppUtils().getPadding(all: AppDimens.paddingX24),
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
                padding: AppUtils().getPadding(
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
  final PublicListingVenueModel court;
  const CourtCard({super.key, required this.court});

  @override
  State<CourtCard> createState() => _CourtCardState();
}

class _CourtCardState extends State<CourtCard> {
  bool _saved = false;
  bool _isPressed = false;

  PublicListingVenueModel _courtWithDistance() {
    final double? latitude = widget.court.latitude;
    final double? longitude = widget.court.longitude;
    if (latitude == null || longitude == null) return widget.court;

    return widget.court.copyWith(
      distanceMeters:
          widget.court.distanceMeters ??
          VenueDistanceHelper.instance.distanceMeters(latitude, longitude),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
      child: AnimatedScale(
        scale: _isPressed ? 0.985 : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: AppDimens.sizeX8,
                spreadRadius: 0.5,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppDimens.radiusX18),
                ),
                child: SizedBox(
                  height: AppDimens.sizeX200,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImageView(
                        url: widget.court.featureImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _saved = !_saved),
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
                                  _saved
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  color: _saved
                                      ? LightColor.secondaryColor
                                      : LightColor.secondaryTextColor,
                                  size: AppDimens.sizeX22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: AppUtils().getPadding(all: AppDimens.sizeX14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.court.name ?? '',
                      style: FutsalTheme.getTextTheme(context).bodyTextLarge
                          ?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppDimens.sizeX6),

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
                            widget.court.address ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: FutsalTheme.getTextTheme(context)
                                .bodyTextSmall
                                ?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                ),
                          ),
                        ),
                        _DistanceLabel(court: widget.court),
                      ],
                    ),
                    const SizedBox(height: AppDimens.sizeX12),
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.court.price == null
                                  ? 'Rs. --'
                                  : 'Rs. ${widget.court.price!.toStringAsFixed(0)}',
                              style: FutsalTheme.getTextTheme(context)
                                  .headingSubTitle
                                  ?.copyWith(
                                    color: LightColor.secondaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(width: AppDimens.sizeX4),
                            Text(
                              '/ hour',
                              style: FutsalTheme.getTextTheme(context)
                                  .bodyTextMedium
                                  ?.copyWith(
                                    color: LightColor.secondaryTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        VenueStatusWidget(isOpen: widget.court.isOpen ?? false),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
