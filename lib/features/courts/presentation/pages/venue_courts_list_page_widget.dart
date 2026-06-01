import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TopDashboardHeader(
                      stats: stats,
                      onAddFutsal: () {
                        context.pushNamed(AppRouterParams.vendorStepper.name);
                      },
                    ),
                    const SizedBox(height: AppDimens.paddingX16),
                    _VenueSearchField(controller: _searchController),
                    const SizedBox(height: AppDimens.paddingX14),
                    _VenueFilterRow(
                      stats: stats,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (_VenueFilter filter) {
                        if (_selectedFilter == filter) return;
                        setState(() => _selectedFilter = filter);
                      },
                    ),
                    const SizedBox(height: AppDimens.paddingX10),
                    Expanded(
                      child: state.status == VenueCourtStatus.loading
                          ? const LoadingWidget()
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

enum _VenueMenuAction { manageFutsal, addCourt, deleteFutsal, deleteCourt }

enum _VenueApprovalStatus { pending, approved, active, inactive }

class _TopDashboardHeader extends StatelessWidget {
  const _TopDashboardHeader({required this.stats, required this.onAddFutsal});

  final _PortfolioStats stats;
  final VoidCallback onAddFutsal;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final int needsSetup = stats.courtCount - stats.liveCourtCount;
    final String subtitle = stats.futsalCount == 0
        ? 'Add your first futsal venue to get started.'
        : '${stats.futsalCount} ${stats.futsalCount == 1 ? 'venue' : 'venues'}'
              ' · ${stats.courtCount} ${stats.courtCount == 1 ? 'court' : 'courts'}'
              '${needsSetup > 0 ? ' · $needsSetup need setup' : ''}';

    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
        top: AppDimens.paddingX24,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Futsal Portfolio',
                  style: textTheme.bodyTextLarge?.copyWith(
                    fontSize: AppDimens.fontHeadingSmall,
                    fontWeight: FontWeight.w700,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX4),
                Text(
                  subtitle,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX10),
          _AddFutsalButton(onTap: onAddFutsal),
        ],
      ),
    );
  }
}

class _AddFutsalButton extends StatelessWidget {
  const _AddFutsalButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.secondaryColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX8,
            vertical: AppDimens.paddingX8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.add_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.whiteColor,
              ),
              const SizedBox(width: AppDimens.paddingX4),
              Text(
                'New Futsal',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.whiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenueSearchField extends StatefulWidget {
  const _VenueSearchField({required this.controller});

  final TextEditingController controller;

  @override
  State<_VenueSearchField> createState() => _VenueSearchFieldState();
}

class _VenueSearchFieldState extends State<_VenueSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool hasText = widget.controller.text.isNotEmpty;

    return Padding(
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX20),
      child: SizedBox(
        height: 42,
        child: TextField(
          controller: widget.controller,
          cursorColor: LightColor.secondaryColor,
          textAlignVertical: TextAlignVertical.center,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: LightColor.whiteColor,
            hintText: 'Search venues, courts or location',
            hintStyle: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: LightColor.iconGrey,
              size: AppDimens.sizeX18,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            suffixIcon: !hasText
                ? null
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.controller.clear(),
                    child: const Icon(
                      Icons.close_rounded,
                      color: LightColor.iconGrey,
                      size: AppDimens.sizeX16,
                    ),
                  ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 40,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              borderSide: const BorderSide(color: LightColor.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              borderSide: const BorderSide(color: LightColor.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              borderSide: const BorderSide(
                color: LightColor.secondaryColor,
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VenueFilterRow extends StatelessWidget {
  const _VenueFilterRow({
    required this.stats,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final _PortfolioStats stats;
  final _VenueFilter selectedFilter;
  final ValueChanged<_VenueFilter> onFilterChanged;

  int _countFor(_VenueFilter filter) {
    switch (filter) {
      case _VenueFilter.all:
        return stats.futsalCount;
      case _VenueFilter.liveOnly:
        return stats.liveCourtCount;
      case _VenueFilter.needsSetup:
        return stats.courtCount - stats.liveCourtCount;
    }
  }

  String _labelFor(_VenueFilter filter) {
    switch (filter) {
      case _VenueFilter.all:
        return 'All';
      case _VenueFilter.liveOnly:
        return 'Live';
      case _VenueFilter.needsSetup:
        return 'Needs Setup';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
        ),
        itemCount: _VenueFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (BuildContext context, int index) {
          final _VenueFilter filter = _VenueFilter.values[index];
          return _VenueFilterChip(
            label: _labelFor(filter),
            count: _countFor(filter),
            isSelected: selectedFilter == filter,
            onTap: () => onFilterChanged(filter),
          );
        },
      ),
    );
  }
}

class _VenueFilterChip extends StatelessWidget {
  const _VenueFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isSelected
                      ? LightColor.whiteColor
                      : LightColor.secondaryTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              if (count > 0) ...<Widget>[
                const SizedBox(width: AppDimens.paddingX6),
                Text(
                  count.toString(),
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: isSelected
                        ? LightColor.whiteColor.withValues(alpha: 0.7)
                        : LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: AppDimens.fontBodySubTitle,
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
      case _VenueMenuAction.deleteFutsal:
        break;
      case _VenueMenuAction.deleteCourt:
        break;
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

    final bool needsAttention = liveCourts < totalCourts || totalCourts == 0;

    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(
          color: needsAttention
              ? LightColor.secondaryColor.withValues(alpha: 0.18)
              : LightColor.dividerColor,
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: <Widget>[
              Padding(
                padding: appUtils.getPadding(
                  left: AppDimens.paddingX14,
                  top: AppDimens.paddingX14,
                  right: AppDimens.paddingX14,
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
                            radius: BorderRadius.circular(AppDimens.radiusX10),
                            url:
                                'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingX12),
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
                                    value: _VenueMenuAction.deleteFutsal,
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
              const Divider(
                height: 1,
                thickness: 1,
                color: LightColor.dividerColor,
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppDimens.radiusX14),
          topRight: Radius.circular(AppDimens.radiusX14),
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

  Future<void> _confirmDeleteCourt(BuildContext context) async {
    final VenueCourtBloc bloc = context.read<VenueCourtBloc>();
    final String name = court.name.trim().isEmpty
        ? 'Court $index'
        : court.name.trim();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => _CourtDeleteDialog(
        courtName: name,
        onConfirm: () async {
          final int? courtId = court.remoteId ?? int.tryParse(court.id);
          if (courtId == null) {
            bloc.add(
              RemoveVenueCourtLocallyEvent(venueId: venueId, court: court),
            );
            return null;
          }
          final Either<AppException, Unit> result = await GetVenueCourtUseCase(
            VenueCourtRepositoryImpl(),
          ).deleteCourt(courtId);
          return result.fold((AppException failure) => failure.errorMessage, (
            _,
          ) {
            bloc.add(
              RemoveVenueCourtLocallyEvent(venueId: venueId, court: court),
            );
            return null;
          });
        },
      ),
    );
  }

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

    return Container(
      padding: appUtils.getPadding(
        symmetricHorizontal: AppDimens.paddingX10,
        symmetricVertical: AppDimens.paddingX10,
      ),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
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
                                color: LightColor.secondaryTextColor.withValues(
                                  alpha: 0.82,
                                ),
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
                        } else if (action == _VenueMenuAction.deleteCourt) {
                          unawaited(_confirmDeleteCourt(context));
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
                          value: _VenueMenuAction.deleteCourt,
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
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.dashboard_customize_outlined,
                size: 32,
                color: LightColor.secondaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              isSearching ? 'No matching venues' : 'No futsal venues yet',
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              isSearching
                  ? 'Try a different search or filter.'
                  : 'Create your first venue and add courts for online booking.',
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            if (!isSearching) ...<Widget>[
              const SizedBox(height: AppDimens.paddingX20),
              _AddFutsalButton(onTap: onManageVenue),
            ],
          ],
        ),
      ),
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

/// Delete-confirmation dialog whose action button shows a loading state while
/// the court is being deleted, and only closes once the backend confirms.
class _CourtDeleteDialog extends StatefulWidget {
  const _CourtDeleteDialog({required this.courtName, required this.onConfirm});

  final String courtName;
  final Future<String?> Function() onConfirm;

  @override
  State<_CourtDeleteDialog> createState() => _CourtDeleteDialogState();
}

class _CourtDeleteDialogState extends State<_CourtDeleteDialog> {
  bool _isDeleting = false;
  String? _error;

  Future<void> _delete() async {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
      _error = null;
    });
    final String? error = await widget.onConfirm();
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isDeleting = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return AlertDialog(
      backgroundColor: LightColor.cardColor,
      surfaceTintColor: LightColor.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      ),
      title: Text(
        'Delete Court',
        style: textTheme.bodyTextLarge?.copyWith(
          color: LightColor.primaryTextColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Are you sure you want to delete "${widget.courtName}"? '
            'This action cannot be undone.',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            Text(
              _error!,
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                isOutlined: true,
                foregroundColor: LightColor.secondaryColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX42,
                onPressed: _isDeleting
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: CustomButton(
                text: 'Delete',
                icon: Icons.delete_outline_rounded,
                isLoading: _isDeleting,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.redColor,
                foregroundColor: LightColor.whiteColor,
                onPressed: _isDeleting ? null : _delete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
