import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'dart:ui';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_venue/public_venue_bloc.dart';

class FootsallHomePage extends StatelessWidget {
  const FootsallHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CourtsListScreen();
  }
}

class CourtsListScreen extends StatefulWidget {
  const CourtsListScreen({super.key});

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
    )..add(const FetchPublicVenuesEvent());
    _scrollController.addListener(_onScroll);
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
    // Start loading the next page slightly before the user hits the bottom.
    if (currentScroll >= maxScroll - 300) {
      _publicVenueBloc.add(const LoadMorePublicVenuesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return BlocProvider<PublicVenueBloc>.value(
      value: _publicVenueBloc,
      child: Padding(
        padding: AppUtils().getPadding(
          left: AppDimens.paddingX20,
          right: AppDimens.paddingX20,
        ),
        child: FadeTransition(
          opacity: _fadeIn,
          child: BlocBuilder<PublicVenueBloc, PublicVenueState>(
            builder: (BuildContext context, PublicVenueState state) {
              final List<PublicVenueModel> courts = state.venues;
              return CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: AppDimens.sizeX8)),
                  SliverPadding(
                    padding: AppUtils().getPadding(bottom: AppDimens.sizeX120),
                    sliver: SliverList.builder(
                      itemCount: courts.length,
                      itemBuilder: (context, index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 500 + index * 120),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) =>
                              Transform.translate(
                                offset: Offset(0, 30 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              ),
                          child: Padding(
                            padding: AppUtils().getPadding(
                              bottom: AppDimens.sizeX20,
                            ),
                            child: CourtCard(court: courts[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class CourtCard extends StatefulWidget {
  final PublicVenueModel court;
  const CourtCard({super.key, required this.court});

  @override
  State<CourtCard> createState() => _CourtCardState();
}

class _CourtCardState extends State<CourtCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(AppRouterParams.courtDetails.name);
      },
      child: Container(
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
                      url: widget.court.image,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.court.name,
                          style: FutsalTheme.getTextTheme(context).bodyTextLarge
                              ?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      const SizedBox(width: AppDimens.sizeX8),
                      _ratingWidget(),
                    ],
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
                      Text(
                        widget.court.location,

                        style: FutsalTheme.getTextTheme(context).bodyTextSmall
                            ?.copyWith(color: LightColor.secondaryTextColor),
                      ),
                      const SizedBox(width: AppDimens.sizeX10),
                      Container(
                        width: AppDimens.sizeX3,
                        height: AppDimens.sizeX3,
                        decoration: BoxDecoration(
                          color: LightColor.secondaryTextColor.withValues(
                            alpha: 0.4,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppDimens.sizeX8),
                      Text(
                        widget.court.distance,
                        style: FutsalTheme.getTextTheme(context).bodyTextSmall
                            ?.copyWith(
                              color: LightColor.secondaryTextColor.withValues(
                                alpha: 0.8,
                              ),
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sizeX12),
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.court.price,
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
                      _StatusPill(isOpen: widget.court.isOpen),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.sizeX30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX6,
          ),
          decoration: BoxDecoration(
            color: LightColor.whiteColor.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppDimens.sizeX30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: LightColor.ratingColor,
                size: AppDimens.sizeX14,
              ),
              const SizedBox(width: AppDimens.sizeX4),
              Text(
                widget.court.rating.toString(),
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: LightColor.ratingColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: AppDimens.sizeX4),
              Text(
                '(${widget.court.reviewCount})',
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: LightColor.secondaryDark,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isOpen;
  const _StatusPill({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.sizeX30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX4,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppDimens.sizeX30),
            border: Border.all(
              color: isOpen
                  ? LightColor.secondaryColor.withValues(alpha: 0.3)
                  : LightColor.redColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: AppDimens.sizeX6,
                width: AppDimens.sizeX6,
                decoration: BoxDecoration(
                  color: isOpen
                      ? LightColor.secondaryColor
                      : LightColor.redColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX4),
              Text(
                isOpen ? 'Open Now' : 'Closed',
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      fontSize: AppDimens.sizeX10,
                      color: isOpen
                          ? LightColor.secondaryColor
                          : LightColor.redColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
