import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/scroll_behavior.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/message/presentation/pages/chat_launcher.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_amenities.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_booking_policies_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_description_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_hosted_by_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_intro_widget.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_location_map_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_reviews_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_rules_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/details_image_gallery.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/hosted_by_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_amenities_facilities_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_hosted_by_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_venue_amenities_facilities_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_venue_description_use_case.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/hosted_by/hosted_by_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/venue_amenities_facilities/venue_amenities_facilities_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/venue_description/venue_description_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/loading/hosted_by_section_loading.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';

class FutsalDetailsPageView extends StatefulWidget {
  final CourtDetailModel? court;
  final PublicListingVenueModel? publicVenue;

  const FutsalDetailsPageView({super.key, this.court, this.publicVenue})
    : assert(
        court != null || publicVenue != null,
        'Either court or publicVenue must be provided',
      );

  @override
  State<FutsalDetailsPageView> createState() => _FutsalDetailsPageViewState();
}

class _FutsalDetailsPageViewState extends State<FutsalDetailsPageView>
    with TickerProviderStateMixin {
  late final AnimationController _bottomBarController;
  late final Animation<Offset> _bottomBarSlide;

  late final CourtDetailModel _court;
  HostedByBloc? _hostedByBloc;
  VenueDescriptionBloc? _venueDescriptionBloc;
  VenueAmenitiesFacilitiesBloc? _venueAmenitiesFacilitiesBloc;

  @override
  void initState() {
    super.initState();

    _court = widget.court ?? _fromPublicVenue(widget.publicVenue!);

    final int? venueId = widget.publicVenue?.id;
    if (venueId != null) {
      final FutsalDetailsRepositoryImpl repository =
          FutsalDetailsRepositoryImpl();
      _hostedByBloc = HostedByBloc(GetHostedByUseCase(repository))
        ..add(FetchHostedByEvent(venueId: venueId));
      _venueDescriptionBloc = VenueDescriptionBloc(
        GetVenueDescriptionUseCase(repository),
      )..add(FetchVenueDescriptionEvent(venueId: venueId));
      _venueAmenitiesFacilitiesBloc = VenueAmenitiesFacilitiesBloc(
        GetVenueAmenitiesFacilitiesUseCase(repository),
      )..add(FetchVenueAmenitiesFacilitiesEvent(venueId: venueId));
    }

    _bottomBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bottomBarSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _bottomBarController,
            curve: Curves.easeOutCubic,
          ),
        );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bottomBarController.forward();
    });
  }

  CourtDetailModel _fromPublicVenue(PublicListingVenueModel venue) {
    final List<String> images =
        <String>[
              venue.featureImage ?? '',
              ...(venue.galleryImages ?? const <VenueGalleryImageModel>[]).map(
                (VenueGalleryImageModel image) => image.imageUrl ?? '',
              ),
            ]
            .map((String value) => value.trim())
            .where((String value) => value.isNotEmpty)
            .toSet()
            .toList(growable: false);

    final String addressText = venue.address?.trim() ?? '';
    final String exactLocationText = venue.exactLocation?.trim() ?? '';
    final String address = addressText.isEmpty
        ? exactLocationText
        : addressText;
    final String exactLocation = exactLocationText.isEmpty
        ? address
        : exactLocationText;
    // Get court type from the court_types array
    final String courtType = (venue.courtTypes?.isNotEmpty ?? false)
        ? venue.courtTypes!.first.name ?? 'Not specified'
        : 'Not specified';

    final int maxPlayers = venue.maxPlayer ?? 0;
    final String openTime = (venue.minTime ?? '').trim();
    final String closeTime = (venue.maxTime ?? '').trim();

    return CourtDetailModel(
      name: venue.name ?? '',
      location: address,
      address: exactLocation,
      price: venue.price == null ? '' : 'Rs ${venue.price!.toStringAsFixed(0)}',
      rating: 0,
      reviewCount: 0,
      images: images,
      isOpen: venue.isOpen ?? false,
      distance: _formatDistanceMeters(venue.distanceMeters),
      features: <String>[courtType, if (maxPlayers > 0) '$maxPlayers Players'],
      description: '',
      hostedByName: '',
      hostedByAvatar: '',
      hostedSince: '',
      hostedCourts: 0,
      responseRate: 0,
      policies: const <String>[],
      rules: const <String>[],
      reviews: const <ReviewModel>[],
      openTime: openTime,
      closeTime: closeTime,
      courtType: courtType,
      surfaceType: '',
      maxPlayers: maxPlayers,
    );
  }

  String _formatDistanceMeters(double? meters) {
    if (meters == null) return '';
    if (meters < 1000) return '${meters.round()} m';
    final double km = meters / 1000;
    return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
  }

  @override
  void dispose() {
    _hostedByBloc?.close();
    _venueDescriptionBloc?.close();
    _venueAmenitiesFacilitiesBloc?.close();
    _bottomBarController.dispose();
    super.dispose();
  }

  void _openSlotsSelection() {
    HapticFeedback.mediumImpact();
    context.pushNamed(
      AppRouterParams.slotsSelection.name,
      extra: _courtForSlotsSelection(),
    );
  }

  CourtDetailModel _courtForSlotsSelection() {
    final int hostedCourts =
        _hostedByBloc?.state.hostedBy?.courtCount ?? _court.hostedCourts;
    if (hostedCourts <= 0 || hostedCourts == _court.hostedCourts) {
      return _court;
    }

    return CourtDetailModel(
      name: _court.name,
      location: _court.location,
      address: _court.address,
      price: _court.price,
      rating: _court.rating,
      reviewCount: _court.reviewCount,
      images: _court.images,
      isOpen: _court.isOpen,
      distance: _court.distance,
      features: _court.features,
      description: _court.description,
      hostedByName: _court.hostedByName,
      hostedByAvatar: _court.hostedByAvatar,
      hostedSince: _court.hostedSince,
      hostedCourts: hostedCourts,
      responseRate: _court.responseRate,
      policies: _court.policies,
      rules: _court.rules,
      reviews: _court.reviews,
      openTime: _court.openTime,
      closeTime: _court.closeTime,
      courtType: _court.courtType,
      surfaceType: _court.surfaceType,
      maxPlayers: _court.maxPlayers,
    );
  }

  Widget _buildHostedBySection() {
    final HostedByBloc? bloc = _hostedByBloc;

    if (bloc == null) {
      return CourtHostedBySection(
        hostName: _court.hostedByName,
        hostSince: _court.hostedSince,
        hostedCourts: _court.hostedCourts,
        responseRate: _court.responseRate,
        rating: _court.rating,
      );
    }

    return BlocBuilder<HostedByBloc, HostedByState>(
      bloc: bloc,
      builder: (BuildContext context, HostedByState state) {
        switch (state.status) {
          case HostedByStatus.idle:
          case HostedByStatus.loading:
            return const HostedBySectionLoading();
          case HostedByStatus.failure:
            return const SizedBox.shrink();
          case HostedByStatus.success:
            final HostedByModel? hostedBy = state.hostedBy;
            if (hostedBy == null || !hostedBy.hasData) {
              return const SizedBox.shrink();
            }
            final int? hostUserId = hostedBy.id;
            return CourtHostedBySection(
              hostName: hostedBy.name ?? '',
              hostSince: hostedBy.hostingSince ?? '-',
              avatarUrl: hostedBy.image,
              hostedCourts: hostedBy.courtCount ?? 0,
              hostedVenues: hostedBy.venueCount ?? 0,
              rating: hostedBy.rating ?? 0,
              onMessage: hostUserId == null
                  ? null
                  : () => ChatLauncher.startDirect(
                      context,
                      vendorId: hostUserId,
                      venueId: widget.publicVenue?.id,
                    ),
            );
        }
      },
    );
  }

  Widget _buildDescriptionSection() {
    final VenueDescriptionBloc? bloc = _venueDescriptionBloc;

    if (bloc == null) {
      return CourtDescriptionSection(description: _court.description);
    }

    return BlocBuilder<VenueDescriptionBloc, VenueDescriptionState>(
      bloc: bloc,
      builder: (BuildContext context, VenueDescriptionState state) {
        if (state.status != VenueDescriptionStatus.success) {
          return const SizedBox.shrink();
        }
        return CourtDescriptionSection(
          description: state.venueDescription.description,
        );
      },
    );
  }

  Widget _buildAmenitiesSection() {
    final VenueAmenitiesFacilitiesBloc? bloc = _venueAmenitiesFacilitiesBloc;

    if (bloc == null) {
      return CourtAmenitiesSection(features: _court.features);
    }

    return BlocBuilder<
      VenueAmenitiesFacilitiesBloc,
      VenueAmenitiesFacilitiesState
    >(
      bloc: bloc,
      builder: (BuildContext context, VenueAmenitiesFacilitiesState state) {
        if (state.status != VenueAmenitiesFacilitiesStatus.success) {
          return const SizedBox.shrink();
        }

        final VenueAmenitiesFacilitiesModel data = state.amenitiesFacilities;
        if (!data.hasData) return const SizedBox.shrink();

        return CourtAmenitiesSection(
          features: <String>[...data.amenities, ...data.facilities],
          categories: <String, String>{
            for (final String amenity in data.amenities) amenity: 'Amenities',
            for (final String facility in data.facilities)
              facility: 'Facilities',
          },
        );
      },
    );
  }

  Widget _buildPolicySection() {
    final VenueDescriptionBloc? bloc = _venueDescriptionBloc;

    if (bloc == null) {
      return CourtBookingPoliciesSection(policies: _court.policies);
    }

    return BlocBuilder<VenueDescriptionBloc, VenueDescriptionState>(
      bloc: bloc,
      builder: (BuildContext context, VenueDescriptionState state) {
        if (state.status != VenueDescriptionStatus.success) {
          return const SizedBox.shrink();
        }
        return CourtDescriptionSection(
          description: state.venueDescription.policy,
          title: 'Cancellation Policy',
          subtitle: 'Booking and cancellation terms',
          icon: Icons.policy_outlined,
        );
      },
    );
  }

  Widget _buildRulesSection() {
    final VenueDescriptionBloc? bloc = _venueDescriptionBloc;

    // No venue id to fetch with — fall back to the data already on the court.
    if (bloc == null) {
      return CourtRulesSection(rules: _court.rules);
    }

    return BlocBuilder<VenueDescriptionBloc, VenueDescriptionState>(
      bloc: bloc,
      builder: (BuildContext context, VenueDescriptionState state) {
        if (state.status != VenueDescriptionStatus.success) {
          return const SizedBox.shrink();
        }
        return CourtDescriptionSection(
          description: state.venueDescription.rules,
          title: 'Futsal Rules',
          subtitle: 'Rules to follow at this venue',
          icon: Icons.gavel_rounded,
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return SlideTransition(
      position: _bottomBarSlide,
      child: Container(
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimens.radiusX20),
            topRight: Radius.circular(AppDimens.radiusX20),
          ),
          border: Border.all(
            color: LightColor.dividerColor.withValues(alpha: 0.7),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: AppDimens.radiusX28,
              offset: const Offset(0, AppDimens.sizeX10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: AppUtils().getPadding(all: AppDimens.paddingX12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: AppUtils().getPadding(left: AppDimens.paddingX6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          _court.price,
                          style: FutsalTheme.getTextTheme(context).headingSmall
                              ?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        SizedBox(width: AppDimens.sizeX4),
                        Padding(
                          padding: AppUtils().getPadding(
                            bottom: AppDimens.paddingX2,
                          ),
                          child: Text(
                            '/ hour',
                            style: FutsalTheme.getTextTheme(context)
                                .bodyTextSmall
                                ?.copyWith(
                                  color: LightColor.hintTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: AppDimens.sizeX10),
                Expanded(
                  child: CustomButton(
                    text: 'Book Now',
                    onPressed: _openSlotsSelection,
                    backgroundColor: LightColor.secondaryColor,
                    minHeight: AppDimens.sizeX46,
                    borderRadius: AppDimens.radiusX10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: FutsalScrollBehavior(),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Scaffold(
          backgroundColor: LightColor.background,
          body: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: DetailsImageGallery(
                        images: _court.images,
                        venueId: widget.publicVenue?.id,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: LightColor.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppDimens.radiusX28),
                          ),
                        ),
                        transform: Matrix4.translationValues(
                          0,
                          -AppDimens.sizeX24,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Container(
                                margin: AppUtils().getMargin(
                                  top: AppDimens.marginX12,
                                  bottom: AppDimens.marginX4,
                                ),
                                width: AppDimens.sizeX40,
                                height: AppDimens.sizeX4,
                                decoration: BoxDecoration(
                                  color: LightColor.dividerColor,
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.radiusX50,
                                  ),
                                ),
                              ),
                            ),

                            CourtIntroWidget(court: _court),
                            _buildHostedBySection(),

                            _buildDescriptionSection(),

                            _buildAmenitiesSection(),

                            CourtLocationMapSection(
                              latitude: widget.publicVenue?.latitude,
                              longitude: widget.publicVenue?.longitude,
                              venueName: _court.name,
                              address: _court.address.trim().isEmpty
                                  ? _court.location
                                  : _court.address,
                            ),

                            _buildPolicySection(),
                            _buildRulesSection(),
                            // Hide the reviews section until the venue has
                            // at least one review.
                            if (_court.reviewCount > 0)
                              CourtReviewsSection(
                                rating: _court.rating,
                                reviewCount: _court.reviewCount,
                                reviews: _court.reviews
                                    .map(
                                      (r) => CourtReviewItem(
                                        name: r.name,
                                        date: r.date,
                                        comment: r.comment,
                                        rating: r.rating,
                                      ),
                                    )
                                    .toList(),
                              ),

                            SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom +
                                  AppDimens.sizeX100,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomBar(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
