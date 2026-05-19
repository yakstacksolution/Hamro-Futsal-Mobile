import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/data/repositories/venue_court_repository_impl.dart';
import 'package:hamro_footsall/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/venue_court/venue_court_bloc.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_templates_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_footsall/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_footsall/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_footsall/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_court_manager.dart';

class VenueCourtsListPage extends StatefulWidget {
  const VenueCourtsListPage({super.key});

  @override
  State<VenueCourtsListPage> createState() => _VenueCourtsListPageState();
}

class _VenueCourtsListPageState extends State<VenueCourtsListPage> {
  final TextEditingController _searchController = TextEditingController();
  late final VenueCourtBloc _venueCourtBloc;
  _VenueFilter _selectedFilter = _VenueFilter.all;

  @override
  void initState() {
    super.initState();
    _venueCourtBloc = VenueCourtBloc(
      GetVenueCourtUseCase(VenueCourtRepositoryImpl()),
    )..add(const FetchVenueCourtEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _venueCourtBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();

    return BlocProvider<VenueCourtBloc>.value(
      value: _venueCourtBloc,
      child: BlocBuilder<VenueCourtBloc, VenueCourtState>(
        builder: (BuildContext context, VenueCourtState state) {
          final List<_FutsalEntry> source = List<_FutsalEntry>.from(
            state.venues.map(_FutsalEntry.fromModel),
          )..sort(_compareFutsals);
          final _PortfolioStats stats = _PortfolioStats.fromEntries(source);

          return AnimatedBuilder(
            animation: _searchController,
            builder: (BuildContext context, _) {
              final String query = _searchController.text.trim().toLowerCase();

              List<_FutsalEntry> filtered = source.where((item) {
                final bool matchesSearch = query.isEmpty
                    ? true
                    : item.matchesQuery(query);

                final bool matchesFilter = switch (_selectedFilter) {
                  _VenueFilter.all => true,
                  _VenueFilter.liveOnly => item.liveCourts > 0,
                  _VenueFilter.needsSetup =>
                    item.liveCourts < item.courts.length,
                };

                return matchesSearch && matchesFilter;
              }).toList();

              return DecoratedBox(
                decoration: const BoxDecoration(color: LightColor.whiteColor),
                child: Column(
                  children: <Widget>[
                    _TopDashboardHeader(
                      stats: stats,
                      onAddFutsal: () {
                        context.pushNamed(AppRouterParams.vendorStepper.name);
                      },
                      onAddCourt: () {
                        context.pushNamed(AppRouterParams.vendorStepper.name);
                      },
                    ),
                    _OperationsStripV2(
                      stats: stats,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (_VenueFilter filter) {
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                    Expanded(
                      child: state.status == VenueCourtStatus.loading
                          ? const Center(child: CircularProgressIndicator())
                          : filtered.isEmpty
                          ? ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: appUtils.getPadding(
                                left: AppDimens.paddingX16,
                                top: AppDimens.paddingX6,
                                right: AppDimens.paddingX16,
                                bottom: AppDimens.paddingX24,
                              ),
                              children: <Widget>[
                                _EmptyStateV2(
                                  isSearching:
                                      query.isNotEmpty ||
                                      _selectedFilter != _VenueFilter.all,
                                  onManageVenue: () {
                                    context.pushNamed(
                                      AppRouterParams.vendorStepper.name,
                                    );
                                  },
                                  onAddCourt: () {
                                    context.pushNamed(
                                      AppRouterParams.vendorStepper.name,
                                    );
                                  },
                                ),
                              ],
                            )
                          : RefreshIndicator(
                              onRefresh: () async {
                                context.read<VenueCourtBloc>().add(
                                  const FetchVenueCourtEvent(),
                                );
                              },
                              child: ListView.separated(
                                physics: const BouncingScrollPhysics(),
                                padding: appUtils.getPadding(
                                  left: AppDimens.paddingX16,
                                  top: AppDimens.paddingX6,
                                  right: AppDimens.paddingX16,
                                  bottom: AppDimens.paddingX24,
                                ),
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: AppDimens.sizeX10),
                                itemBuilder: (_, index) => _VenueCardV2(
                                  entry: filtered[index],
                                  onAddCourt: () {
                                    final int? venueId = filtered[index].id;
                                    final VendorOnboardingCubit
                                    cubit = VendorOnboardingCubit(
                                      const EphemeralVendorDraftRepository(),
                                      onboardingUseCase:
                                          VendorOnboardingUseCase(
                                            VendorOnboardingRepositoryImpl(),
                                          ),
                                    );
                                    if (venueId != null) {
                                      cubit.setRemoteFutsalId(venueId);
                                    }
                                    cubit.addCourt();
                                    final String? courtId =
                                        cubit.state.activeCourtId;
                                    if (courtId == null) return;
                                    Navigator.of(context)
                                        .push<void>(
                                          MaterialPageRoute<void>(
                                            builder: (_) => MultiBlocProvider(
                                              providers: <BlocProvider<dynamic>>[
                                                BlocProvider<
                                                  VendorOnboardingCubit
                                                >(create: (_) => cubit),
                                                BlocProvider<
                                                  PublicTemplatesBloc
                                                >(
                                                  create: (_) =>
                                                      PublicTemplatesBloc(
                                                        GetPublicTemplatesUseCase(
                                                          PublicRepositoryImpl(),
                                                        ),
                                                      )..add(
                                                        FetchPublicTemplatesEvent(),
                                                      ),
                                                ),
                                              ],
                                              child: CourtOnboardingPage(
                                                courtId: courtId,
                                              ),
                                            ),
                                          ),
                                        )
                                        .then((_) {
                                          if (context.mounted) {
                                            final CourtDraft? updated =
                                                cubit.state.courts.firstOrNull;
                                            if (updated != null &&
                                                venueId != null) {
                                              context.read<VenueCourtBloc>().add(
                                                UpsertVenueCourtLocallyEvent(
                                                  venueId: venueId,
                                                  court: updated,
                                                ),
                                              );
                                            }
                                          }
                                        });
                                  },
                                  onEditVenue: () => context.pushNamed(
                                    AppRouterParams.vendorStepper.name,
                                    queryParameters: {
                                      if (filtered[index].id != null)
                                        'futsalId': filtered[index].id
                                            .toString(),
                                      'mainStep': '0',
                                      'subStep': '1',
                                    },
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  int _compareFutsals(_FutsalEntry left, _FutsalEntry right) {
    final int courtCount = right.courts.length.compareTo(left.courts.length);
    if (courtCount != 0) return courtCount;
    return left.title.toLowerCase().compareTo(right.title.toLowerCase());
  }
}

enum _VenueFilter { all, liveOnly, needsSetup }

enum _VenueMenuAction { manageFutsal, addCourt }

enum _VenueApprovalStatus { pending, approved, active, inactive }

class _TopDashboardHeader extends StatelessWidget {
  const _TopDashboardHeader({
    required this.stats,
    required this.onAddFutsal,
    required this.onAddCourt,
  });

  final _PortfolioStats stats;
  final VoidCallback onAddFutsal;
  final VoidCallback onAddCourt;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: appUtils
          .getPadding(left: AppDimens.paddingX16, top: AppDimens.paddingX18)
          .copyWith(bottom: AppDimens.paddingX4, right: AppDimens.paddingX16),
      decoration: const BoxDecoration(color: LightColor.whiteColor),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Futsal Portfolio',
                  style: textTheme.headingSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX6),
                Text(
                  'Manage your futsal venues and court operations in one place.',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor.withValues(
                      alpha: 0.85,
                    ),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppDimens.sizeX8),
          InkWell(
            onTap: onAddFutsal,
            child: Container(
              decoration: BoxDecoration(
                color: LightColor.buttonColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              ),
              child: Padding(
                padding: AppUtils().getPadding(
                  symmetricHorizontal: AppDimens.paddingX12,
                  symmetricVertical: AppDimens.paddingX8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: AppDimens.sizeX18,
                      color: LightColor.whiteColor,
                    ),
                    SizedBox(width: AppDimens.sizeX6),
                    Text(
                      "New Futsal",
                      style: FutsalTheme.getTextTheme(
                        context,
                      ).bodySubTitle?.copyWith(color: LightColor.whiteColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationsStripV2 extends StatelessWidget {
  const _OperationsStripV2({
    required this.stats,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final _PortfolioStats stats;
  final _VenueFilter selectedFilter;
  final ValueChanged<_VenueFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final int needsSetup = stats.courtCount - stats.liveCourtCount;
    final AppUtils appUtils = AppUtils();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: appUtils.getPadding(
        symmetricHorizontal: AppDimens.paddingX16,
        symmetricVertical: AppDimens.paddingX12,
      ),
      child: Row(
        children: <Widget>[
          _FilterChip(
            icon: Icons.apartment_rounded,
            label: 'All Venues',
            isActive: selectedFilter == _VenueFilter.all,
            onTap: () => onFilterChanged(_VenueFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            icon: Icons.check_circle_rounded,
            label: 'Live Only',
            badge: stats.liveCourtCount.toString(),
            isActive: selectedFilter == _VenueFilter.liveOnly,
            onTap: () => onFilterChanged(_VenueFilter.liveOnly),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            icon: Icons.warning_amber_rounded,
            label: 'Needs Setup',
            badge: needsSetup.toString(),
            isActive: selectedFilter == _VenueFilter.needsSetup,
            onTap: () => onFilterChanged(_VenueFilter.needsSetup),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: LightColor.transparentColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Container(
          padding: appUtils.getPadding(
            symmetricHorizontal: AppDimens.paddingX12,
            symmetricVertical: AppDimens.paddingX8,
          ),
          decoration: BoxDecoration(
            color: isActive
                ? LightColor.secondaryColor.withValues(alpha: 0.12)
                : LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: isActive
                  ? LightColor.secondaryColor.withValues(alpha: 0.30)
                  : LightColor.iconGrey.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: AppDimens.sizeX18,
                color: isActive
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX6),
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                ),
              ),
              if (badge != null) ...<Widget>[
                const SizedBox(width: AppDimens.sizeX4),
                Container(
                  padding: appUtils.getPadding(
                    symmetricHorizontal: AppDimens.paddingX6,
                    symmetricVertical: AppDimens.paddingX2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? LightColor.secondaryColor.withValues(alpha: 0.18)
                        : LightColor.iconGrey.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                  ),
                  child: Text(
                    badge!,
                    style: textTheme.bodySubTitle?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: isActive
                          ? LightColor.secondaryColor
                          : LightColor.primaryTextColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _VenueCardV2 extends StatefulWidget {
  const _VenueCardV2({
    required this.entry,
    required this.onAddCourt,
    required this.onEditVenue,
  });

  final _FutsalEntry entry;
  final VoidCallback onAddCourt;
  final VoidCallback onEditVenue;

  @override
  State<_VenueCardV2> createState() => _VenueCardV2State();
}

class _VenueCardV2State extends State<_VenueCardV2> {
  bool _expandedCourts = true;

  void _handleMenuAction(_VenueMenuAction action) {
    switch (action) {
      case _VenueMenuAction.manageFutsal:
        widget.onEditVenue();
      case _VenueMenuAction.addCourt:
        widget.onAddCourt();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    final double? startPrice = widget.entry.startingPrice;
    final String address = widget.entry.address.isEmpty
        ? 'Address not available'
        : widget.entry.address;
    final int liveCourts = widget.entry.liveCourts;
    final int totalCourts = widget.entry.courts.length;

    return Container(
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: AppDimens.radiusX18,
            offset: const Offset(0, AppDimens.sizeX8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Padding(
                padding: appUtils.getPadding(
                  left: AppDimens.paddingX12,
                  top: AppDimens.paddingX12,
                  right: AppDimens.paddingX12,
                  bottom: AppDimens.paddingX10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: AppDimens.sizeX50,
                          height: AppDimens.sizeX50,
                          child: CustomImageView(
                            fit: BoxFit.cover,
                            radius: BorderRadius.circular(AppDimens.radiusX6),
                            url:
                                'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
                          ),
                        ),
                        const SizedBox(width: AppDimens.sizeX8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      widget.entry.title,
                                      style: textTheme.bodyTextMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: LightColor.primaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: AppDimens.sizeX4),
                                    Row(
                                      children: <Widget>[
                                        CustomImageView(
                                          imagePath:
                                              ImageConstants.locationIcon,
                                          height: AppDimens.sizeX14,
                                          width: AppDimens.sizeX14,
                                        ),
                                        const SizedBox(width: AppDimens.sizeX4),
                                        Expanded(
                                          child: Text(
                                            address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: textTheme.bodySubTitle
                                                ?.copyWith(
                                                  color: LightColor
                                                      .secondaryTextColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<_VenueMenuAction>(
                                padding: EdgeInsets.zero,
                                menuPadding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Venue actions',
                                color: LightColor.whiteColor,
                                surfaceTintColor: LightColor.whiteColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.radiusX10,
                                  ),
                                ),
                                onSelected: _handleMenuAction,
                                itemBuilder: (BuildContext context) => [
                                  PopupMenuItem<_VenueMenuAction>(
                                    value: _VenueMenuAction.manageFutsal,
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.edit_outlined,
                                          size: AppDimens.sizeX18,
                                          color: LightColor.primaryTextColor,
                                        ),
                                        const SizedBox(
                                          width: AppDimens.sizeX10,
                                        ),
                                        Text(
                                          'Manage Futsal',
                                          style: textTheme.bodyTextSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    LightColor.primaryTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<_VenueMenuAction>(
                                    value: _VenueMenuAction.addCourt,
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: AppDimens.sizeX18,
                                          color: LightColor.primaryTextColor,
                                        ),
                                        const SizedBox(
                                          width: AppDimens.sizeX10,
                                        ),
                                        Text(
                                          'Add Court',
                                          style: textTheme.bodyTextSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    LightColor.primaryTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem<_VenueMenuAction>(
                                    value: _VenueMenuAction.addCourt,
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.delete,
                                          size: AppDimens.sizeX18,
                                          color: LightColor.primaryTextColor,
                                        ),
                                        const SizedBox(
                                          width: AppDimens.sizeX10,
                                        ),
                                        Text(
                                          'Delete Futsal',
                                          style: textTheme.bodyTextSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    LightColor.primaryTextColor,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                child: const Icon(
                                  Icons.more_vert_rounded,
                                  size: AppDimens.sizeX22,
                                  color: LightColor.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.sizeX14),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _InfoTag(
                            icon: Icons.grid_view_rounded,
                            label: '$totalCourts Courts',
                            color: LightColor.primaryDark,
                          ),
                          const SizedBox(width: AppDimens.sizeX8),
                          _InfoTag(
                            icon: Icons.check_circle_rounded,
                            label: '$liveCourts Live',
                            color: LightColor.secondaryColor,
                          ),
                          const SizedBox(width: AppDimens.sizeX8),
                          if (startPrice != null)
                            _InfoTag(
                              icon: Icons.sell_outlined,
                              label: 'From Rs ${startPrice.toStringAsFixed(0)}',
                              color: LightColor.ratingColor,
                            ),
                          if (widget.entry.phone.isNotEmpty) ...<Widget>[
                            const SizedBox(width: AppDimens.sizeX8),
                            _InfoTag(
                              icon: Icons.call_outlined,
                              label: widget.entry.phone,
                              color: LightColor.secondaryColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX14),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: LightColor.iconGrey.withValues(alpha: 0.30),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _expandedCourts = !_expandedCourts);
                },
                child: Padding(
                  padding: appUtils.getPadding(
                    symmetricHorizontal: AppDimens.paddingX16,
                    symmetricVertical: AppDimens.paddingX12,
                    // top: AppDimens.paddingX12,
                    // bottom: AppDimens.paddingX14,
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(
                        Icons.sports_soccer_rounded,
                        size: AppDimens.sizeX20,
                        color: LightColor.secondaryTextColor,
                      ),
                      const SizedBox(width: AppDimens.sizeX6),
                      Expanded(
                        child: Text(
                          'Courts Inventory ($totalCourts)',
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: LightColor.inputFillColor,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX4,
                          ),
                        ),
                        padding: appUtils.getPadding(all: AppDimens.paddingX4),
                        child: Icon(
                          _expandedCourts
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: AppDimens.sizeX18,
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_expandedCourts)
                Padding(
                  padding: appUtils.getPadding(
                    left: AppDimens.paddingX16,
                    right: AppDimens.paddingX16,
                    bottom: AppDimens.paddingX16,
                  ),
                  child: Column(
                    children: <Widget>[
                      if (widget.entry.courts.isEmpty)
                        const _CourtEmptyHintV2()
                      else
                        ...List<Widget>.generate(
                          widget.entry.courts.length,
                          (int index) => Padding(
                            padding: appUtils.getPadding(
                              bottom: index == widget.entry.courts.length - 1
                                  ? 0
                                  : AppDimens.paddingX10,
                            ),
                            child: _CourtRowV2(
                              court: widget.entry.courts[index],
                              index: index + 1,
                              venueId: widget.entry.id,
                              onManageCourt: () {
                                final CourtDraft court =
                                    widget.entry.courts[index];
                                final VendorOnboardingCubit cubit =
                                    VendorOnboardingCubit(
                                      const EphemeralVendorDraftRepository(),
                                      onboardingUseCase:
                                          VendorOnboardingUseCase(
                                            VendorOnboardingRepositoryImpl(),
                                          ),
                                    );
                                if (widget.entry.id != null) {
                                  cubit.setRemoteFutsalId(widget.entry.id!);
                                }
                                cubit.prepareCourtForEditing(court);
                                Navigator.of(context)
                                    .push<void>(
                                      MaterialPageRoute<void>(
                                        builder: (_) => MultiBlocProvider(
                                          providers: <BlocProvider<dynamic>>[
                                            BlocProvider<VendorOnboardingCubit>(
                                              create: (_) => cubit,
                                            ),
                                            BlocProvider<PublicTemplatesBloc>(
                                              create: (_) =>
                                                  PublicTemplatesBloc(
                                                    GetPublicTemplatesUseCase(
                                                      PublicRepositoryImpl(),
                                                    ),
                                                  )..add(
                                                    FetchPublicTemplatesEvent(),
                                                  ),
                                            ),
                                          ],
                                          child: CourtOnboardingPage(
                                            courtId: court.id,
                                          ),
                                        ),
                                      ),
                                    )
                                    .then((_) {
                                      if (context.mounted) {
                                        final CourtDraft? updated =
                                            cubit.state.courts.firstOrNull;
                                        if (updated != null &&
                                            widget.entry.id != null) {
                                          context.read<VenueCourtBloc>().add(
                                            UpsertVenueCourtLocallyEvent(
                                              venueId: widget.entry.id!,
                                              court: updated,
                                            ),
                                          );
                                        }
                                      }
                                    });
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _VenueApprovalBadge(status: widget.entry.approvalStatus),
          ),
        ],
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  const _InfoTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: appUtils.getPadding(
        symmetricHorizontal: AppDimens.paddingX8,
        symmetricVertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX4),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppDimens.sizeX14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w400,
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueApprovalBadge extends StatelessWidget {
  const _VenueApprovalBadge({required this.status});

  final _VenueApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    final ({String label, Color background, Color foreground}) config =
        switch (status) {
          _VenueApprovalStatus.approved => (
            label: 'Approved',
            background: LightColor.secondaryColor,
            foreground: LightColor.whiteColor,
          ),
          _VenueApprovalStatus.pending => (
            label: 'Pending',
            background: LightColor.ratingColor.withValues(alpha: 0.20),
            foreground: const Color(0xFF92400E),
          ),
          _VenueApprovalStatus.active => (
            label: 'Active',
            background: LightColor.secondaryColor,
            foreground: LightColor.whiteColor,
          ),
          _VenueApprovalStatus.inactive => (
            label: 'Inactive',
            background: LightColor.redColor,
            foreground: LightColor.whiteColor,
          ),
        };

    return Container(
      padding: appUtils.getPadding(
        symmetricHorizontal: AppDimens.paddingX10,
        symmetricVertical: AppDimens.paddingX1,
      ),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.radiusX10),
          topRight: Radius.circular(AppDimens.radiusX10),
        ),
      ),
      child: Text(
        config.label,
        style: textTheme.bodySubTitle?.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: AppDimens.fontBodyMiniSubTitle,
          color: config.foreground,
        ),
      ),
    );
  }
}

class _CourtEmptyHintV2 extends StatelessWidget {
  const _CourtEmptyHintV2();

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: appUtils.getPadding(all: AppDimens.paddingX18),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.iconGrey.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.add_circle_outline_rounded,
            size: AppDimens.sizeX32,
            color: LightColor.secondaryTextColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          Text(
            'No courts added yet',
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add your first court and start accepting bookings.',
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: LightColor.secondaryTextColor.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtRowV2 extends StatelessWidget {
  const _CourtRowV2({
    required this.court,
    required this.index,
    required this.venueId,
    required this.onManageCourt,
  });

  final CourtDraft court;
  final int index;
  final int? venueId;
  final VoidCallback onManageCourt;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    final String name = court.name.trim().isEmpty
        ? 'Court $index'
        : court.name.trim();
    final String type = (court.courtType ?? '').trim();
    final bool isLive = court.enableOnlineBooking;

    final Color iconBg = isLive
        ? LightColor.secondarySoft
        : LightColor.warningLightColor;

    return Stack(
      children: [
        Container(
          padding: appUtils.getPadding(
            symmetricHorizontal: AppDimens.paddingX8,
            symmetricVertical: AppDimens.paddingX8,
          ),
          decoration: BoxDecoration(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: LightColor.iconGrey.withValues(alpha: 0.18),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: AppDimens.radiusX10,
                offset: const Offset(0, AppDimens.sizeX3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: AppDimens.sizeX72,
                height: AppDimens.sizeX72,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),

                child: SizedBox(
                  width: AppDimens.sizeX50,
                  height: AppDimens.sizeX50,
                  child: CustomImageView(
                    fit: BoxFit.cover,
                    radius: BorderRadius.circular(AppDimens.radiusX6),
                    url:
                        'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyTextSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: LightColor.primaryTextColor,
                                ),
                              ),
                              if (type.isNotEmpty) ...<Widget>[
                                const SizedBox(height: AppDimens.sizeX4),
                                Text(
                                  type,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySubTitle?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                    color: LightColor.secondaryTextColor
                                        .withValues(alpha: 0.82),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        PopupMenuButton<_VenueMenuAction>(
                          padding: EdgeInsets.zero,
                          menuPadding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Court actions',
                          color: LightColor.whiteColor,
                          surfaceTintColor: LightColor.whiteColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusX10,
                            ),
                          ),
                          onSelected: (action) {
                            if (action == _VenueMenuAction.manageFutsal) {
                              onManageCourt();
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<_VenueMenuAction>(
                              value: _VenueMenuAction.manageFutsal,
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: AppDimens.sizeX18,
                                    color: LightColor.primaryTextColor,
                                  ),
                                  const SizedBox(width: AppDimens.sizeX10),
                                  Text(
                                    'Manage Court',
                                    style: textTheme.bodyTextSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: LightColor.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem<_VenueMenuAction>(
                              value: _VenueMenuAction.addCourt,
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.delete,
                                    size: AppDimens.sizeX18,
                                    color: LightColor.primaryTextColor,
                                  ),
                                  const SizedBox(width: AppDimens.sizeX10),
                                  Text(
                                    'Delete Court',
                                    style: textTheme.bodyTextSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: LightColor.primaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          child: const Icon(
                            Icons.more_vert_rounded,
                            size: AppDimens.sizeX22,
                            color: LightColor.secondaryTextColor,
                          ),
                        ),
                        // if (court.basePrice != null) ...<Widget>[
                        //   const SizedBox(width: AppDimens.sizeX8),
                        //   Container(
                        //     padding: appUtils.getPadding(
                        //       symmetricHorizontal: AppDimens.paddingX10,
                        //       symmetricVertical: AppDimens.paddingX4,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: LightColor.secondaryColor.withValues(
                        //         alpha: 0.20,
                        //       ),
                        //       borderRadius: BorderRadius.circular(
                        //         AppDimens.radiusX20,
                        //       ),
                        //     ),
                        //     child: Text(
                        //       'Rs ${court.basePrice!.toStringAsFixed(0)}',
                        //       style: textTheme.bodySubTitle?.copyWith(
                        //         fontWeight: FontWeight.w600,
                        //         color: LightColor.secondaryColor,
                        //         height: 1.1,
                        //       ),
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),

                    const SizedBox(height: AppDimens.sizeX8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          _CourtStatusChip(
                            icon: isLive
                                ? Icons.check_circle_rounded
                                : Icons.pending_actions_rounded,
                            label: isLive ? 'Live' : 'Inactive',
                            color: isLive
                                ? LightColor.secondaryColor
                                : LightColor.redColor,
                          ),
                          if (court.advancePaymentRequired) ...<Widget>[
                            const SizedBox(width: AppDimens.sizeX6),
                            const _CourtStatusChip(
                              icon: Icons.account_balance_wallet_outlined,
                              label: 'Advance',
                              color: LightColor.secondaryColor,
                            ),
                          ],
                          const SizedBox(width: AppDimens.sizeX6),
                          const _CourtStatusChip(
                            icon: Icons.schedule_rounded,
                            label: 'Booked',
                            color: LightColor.warningColor,
                          ),
                          const SizedBox(width: AppDimens.sizeX6),
                          const _CourtStatusChip(
                            icon: Icons.sports_soccer_rounded,
                            label: '5v5',
                            color: LightColor.primaryDark,
                          ),
                          const SizedBox(width: AppDimens.sizeX6),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: _VenueApprovalBadge(status: _VenueApprovalStatus.active),
        ),
      ],
    );
  }
}

class _CourtStatusChip extends StatelessWidget {
  const _CourtStatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      height: AppDimens.sizeX24,
      padding: appUtils.getPadding(symmetricHorizontal: AppDimens.paddingX8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX4),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppDimens.sizeX12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.bodySubTitle?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateV2 extends StatelessWidget {
  const _EmptyStateV2({
    required this.isSearching,
    required this.onManageVenue,
    required this.onAddCourt,
  });

  final bool isSearching;
  final VoidCallback onManageVenue;
  final VoidCallback onAddCourt;

  @override
  Widget build(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: appUtils.getPadding(all: AppDimens.paddingX32),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        border: Border.all(
          color: LightColor.borderColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX80,
            height: AppDimens.sizeX80,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: const Icon(
              Icons.dashboard_customize_outlined,
              size: AppDimens.sizeX40,
              color: LightColor.secondaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No matching results' : 'No futsal venues yet',
            style: textTheme.headingSubTitle?.copyWith(
              fontWeight: FontWeight.w900,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try another search or switch your filter.'
                : 'Create your first futsal venue and then add courts for online booking.',
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: LightColor.secondaryTextColor.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (!isSearching) _addFutsalButtonWidget(context),
        ],
      ),
    );
  }

  Widget _addFutsalButtonWidget(BuildContext context) {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onManageVenue,
            style: OutlinedButton.styleFrom(
              padding: appUtils.getPadding(
                symmetricVertical: AppDimens.paddingX12,
              ),
              side: const BorderSide(color: LightColor.secondaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
            ),
            icon: const Icon(
              Icons.add_business_rounded,
              color: LightColor.secondaryColor,
            ),
            label: Text(
              'Add Futsal',
              style: textTheme.bodyTextSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.secondaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PortfolioStats {
  const _PortfolioStats({
    required this.futsalCount,
    required this.courtCount,
    required this.liveCourtCount,
    required this.advanceCourtCount,
    required this.startingPrice,
  });

  final int futsalCount;
  final int courtCount;
  final int liveCourtCount;
  final int advanceCourtCount;
  final double? startingPrice;

  factory _PortfolioStats.fromEntries(List<_FutsalEntry> entries) {
    int courtCount = 0;
    int liveCourtCount = 0;
    int advanceCourtCount = 0;
    double? startingPrice;

    for (final _FutsalEntry entry in entries) {
      courtCount += entry.courts.length;
      for (final CourtDraft court in entry.courts) {
        if (court.enableOnlineBooking) liveCourtCount += 1;
        if (court.advancePaymentRequired) advanceCourtCount += 1;
        final double? price = court.basePrice;
        if (price != null) {
          startingPrice = startingPrice == null
              ? price
              : (price < startingPrice ? price : startingPrice);
        }
      }
    }

    return _PortfolioStats(
      futsalCount: entries.length,
      courtCount: courtCount,
      liveCourtCount: liveCourtCount,
      advanceCourtCount: advanceCourtCount,
      startingPrice: startingPrice,
    );
  }
}

class _FutsalEntry {
  const _FutsalEntry({
    required this.id,
    required this.title,
    required this.address,
    required this.phone,
    required this.courts,
    this.approvalStatus = _VenueApprovalStatus.approved,
  });

  final int? id;
  final String title;
  final String address;
  final String phone;
  final List<CourtDraft> courts;
  final _VenueApprovalStatus approvalStatus;

  factory _FutsalEntry.fromModel(VenueCourtModel model) {
    return _FutsalEntry(
      id: model.id,
      title: model.title.isEmpty ? 'My Futsal' : model.title,
      address: model.address,
      phone: model.phone,
      courts: model.courts,
      approvalStatus: model.isActive
          ? _VenueApprovalStatus.active
          : _VenueApprovalStatus.approved,
    );
  }

  bool matchesQuery(String query) {
    if (title.toLowerCase().contains(query)) return true;
    if (address.toLowerCase().contains(query)) return true;
    if (phone.toLowerCase().contains(query)) return true;
    for (final CourtDraft court in courts) {
      if (court.name.toLowerCase().contains(query)) return true;
      if ((court.courtType ?? '').toLowerCase().contains(query)) return true;
    }
    return false;
  }

  int get liveCourts =>
      courts.where((CourtDraft court) => court.enableOnlineBooking).length;

  double? get startingPrice {
    double? value;
    for (final CourtDraft court in courts) {
      final double? price = court.basePrice;
      if (price == null) continue;
      value = value == null ? price : (price < value ? price : value);
    }
    return value;
  }
}
