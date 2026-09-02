import 'dart:async';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/image_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/loading_widget.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_futsal/features/courts/data/repositories/venue_court_repository_impl.dart';
import 'package:hamro_futsal/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_futsal/features/courts/presentation/bloc/venue_court/venue_court_bloc.dart';
import 'package:hamro_futsal/features/courts/presentation/widgets/loadings/venue_list_loading.dart';
import 'package:hamro_futsal/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_public_templates_use_case.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_futsal/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_futsal/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_futsal/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_court_manager.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      LightColor.background,
                      LightColor.cardColor,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
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
                          ? const VenueListLoading()
                          : _VenueListSection(
                              state: state,
                              entries: filtered,
                              isSearching:
                                  query.isNotEmpty ||
                                  _selectedFilter != _VenueFilter.all,
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

/// Courts whose editor is currently opening, keyed by venue + court, so a
/// second tap while the route is being pushed is ignored instead of stacking
/// another editor on top.
final Set<String> _openingCourtEditors = <String>{};

Future<void> _launchCourtEditor(
  BuildContext context, {
  required int? venueId,
  CourtDraft? court,
}) async {
  final String guardKey = '${venueId ?? 0}:${court?.id ?? 'new'}';
  if (!_openingCourtEditors.add(guardKey)) return;
  try {
    await _launchCourtEditorInternal(context, venueId: venueId, court: court);
  } finally {
    _openingCourtEditors.remove(guardKey);
  }
}

Future<void> _launchCourtEditorInternal(
  BuildContext context, {
  required int? venueId,
  CourtDraft? court,
}) async {
  final VenueCourtBloc venueCourtBloc = context.read<VenueCourtBloc>();
  final VendorOnboardingCubit cubit = VendorOnboardingCubit(
    const EphemeralVendorDraftRepository(),
    onboardingUseCase: VendorOnboardingUseCase(
      VendorOnboardingRepositoryImpl(),
    ),
  );
  if (venueId != null) {
    cubit.setRemoteFutsalId(venueId);
  }
  if (court != null) {
    cubit.prepareCourtForEditing(court);
  } else {
    cubit.addCourt();
  }

  final String? courtId = court?.id ?? cubit.state.activeCourtId;
  if (courtId == null) {
    await cubit.close();
    return;
  }

  await Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<VendorOnboardingCubit>(create: (_) => cubit),
          BlocProvider<PublicTemplatesBloc>(
            create: (_) => PublicTemplatesBloc(
              GetPublicTemplatesUseCase(PublicRepositoryImpl()),
            )..add(FetchPublicTemplatesEvent()),
          ),
        ],
        child: CourtOnboardingPage(courtId: courtId),
      ),
    ),
  );

  final CourtDraft? updated = cubit.state.courts.firstOrNull;
  if (updated != null && venueId != null) {
    venueCourtBloc.add(
      UpsertVenueCourtLocallyEvent(venueId: venueId, court: updated),
    );
  }
}

class _VenueListSection extends StatelessWidget {
  const _VenueListSection({
    required this.state,
    required this.entries,
    required this.isSearching,
  });

  final VenueCourtState state;
  final List<_FutsalEntry> entries;
  final bool isSearching;

  void _openVendorStepper(BuildContext context) {
    context.pushNamed(AppRouterParams.vendorStepper.name);
  }

  @override
  Widget build(BuildContext context) {
    if (state.status == VenueCourtStatus.loading) {
      return const VenueListLoading();
    }

    final EdgeInsets listPadding = AppUtils().getPadding(
      left: AppDimens.paddingX16,
      top: AppDimens.paddingX6,
      right: AppDimens.paddingX16,
      bottom: AppDimens.paddingX24,
    );

    if (entries.isEmpty) {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: listPadding,
        children: <Widget>[
          _EmptyStateV2(
            isSearching: isSearching,
            onManageVenue: () => _openVendorStepper(context),
            onAddCourt: () => _openVendorStepper(context),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification.metrics.extentAfter < 300 &&
            state.hasMorePages &&
            !state.isLoadingMore &&
            state.loadMoreError == null) {
          context.read<VenueCourtBloc>().add(
            const FetchVenueCourtEvent(silent: true, loadMore: true),
          );
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          final VenueCourtBloc bloc = context.read<VenueCourtBloc>();
          final int startTick = bloc.state.refreshTick;
          bloc.add(const FetchVenueCourtEvent(silent: true));
          await bloc.stream
              .firstWhere((next) => next.refreshTick != startTick)
              .timeout(
                const Duration(seconds: 15),
                onTimeout: () => bloc.state,
              );
        },
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: listPadding,
          itemCount:
              entries.length +
              (state.isLoadingMore || state.loadMoreError != null ? 1 : 0),
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimens.sizeX10),
          itemBuilder: (BuildContext context, int index) {
            if (index == entries.length) {
              return _VenuePaginationFooter(
                loading: state.isLoadingMore,
                error: state.loadMoreError,
                onRetry: () => context.read<VenueCourtBloc>().add(
                  const FetchVenueCourtEvent(silent: true, loadMore: true),
                ),
              );
            }
            final _FutsalEntry entry = entries[index];
            return _VenueCardV2(
              entry: entry,
              onAddCourt: () => _launchCourtEditor(context, venueId: entry.id),
              onEditVenue: () => context.pushNamed(
                AppRouterParams.vendorStepper.name,
                queryParameters: <String, String>{
                  if (entry.id != null) 'futsalId': entry.id.toString(),
                  'mainStep': '0',
                  'subStep': '1',
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _VenuePaginationFooter extends StatelessWidget {
  const _VenuePaginationFooter({
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(AppDimens.paddingX16),
        child: Center(
          child: CustomLoading(
            color: LightColor.secondaryColor,
            size: 24,
            strokeWidth: 3,
            secondCircleColor: LightColor.secondaryLight,
            thirdCircleColor: LightColor.secondaryLight,
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          error ?? 'Could not load more venues.',
          textAlign: TextAlign.center,
          style: FutsalTheme.getTextTheme(
            context,
          ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(StringConstants.retry),
        ),
      ],
    );
  }
}

enum _VenueFilter { all, liveOnly, needsSetup }

enum _VenueMenuAction {
  manageFutsal,
  addCourt,
  toggleCourtStatus,
  deleteFutsal,
  deleteCourt,
}

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
        ? 'Start by adding your first venue'
        : '${stats.futsalCount} ${stats.futsalCount == 1 ? 'venue' : 'venues'}'
              ' · ${stats.courtCount} ${stats.courtCount == 1 ? 'court' : 'courts'}'
              '${needsSetup > 0 ? ' · $needsSetup pending setup' : ''}';

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
                  StringConstants.futsalPortfolio,
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
              Icon(
                Icons.add_rounded,
                size: AppDimens.sizeX16,
                color: LightColor.inverseTextColor,
              ),
              const SizedBox(width: AppDimens.paddingX4),
              Text(
                StringConstants.newFutsal,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.inverseTextColor,
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
      child: Container(
        height: AppDimens.sizeX52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusX6),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: LightColor.secondaryColor.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
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
            hintText: StringConstants.searchVenuesCourtsOrLocation,
            hintStyle: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
            prefixIcon: Container(
              margin: AppUtils().getMargin(
                left: AppDimens.marginX14,
                right: AppDimens.marginX6,
              ),

              child: const Icon(
                Icons.search_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX18,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: !hasText
                ? null
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.controller.clear(),
                    child: Container(
                      margin: AppUtils().getMargin(right: AppDimens.marginX12),
                      width: AppDimens.sizeX26,
                      height: AppDimens.sizeX26,
                      decoration: BoxDecoration(
                        color: LightColor.iconGrey.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: LightColor.iconGrey,
                        size: AppDimens.sizeX16,
                      ),
                    ),
                  ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            contentPadding: AppUtils().getPadding(
              vertical: AppDimens.paddingX14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX6),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX6),
              borderSide: BorderSide(
                color: LightColor.dividerColor,
                width: 0.8,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusX6),
              borderSide: const BorderSide(
                color: LightColor.secondaryColor,
                width: 1.4,
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
                      ? LightColor.inverseTextColor
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
                        ? LightColor.inverseTextColor.withValues(alpha: 0.7)
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
      case _VenueMenuAction.toggleCourtStatus:
        break;
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
        boxShadow: <BoxShadow>[
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
                            url: widget.entry.imageUrl,
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
                                          fit: BoxFit.contain,
                                          color: LightColor.secondaryTextColor,
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
                                tooltip: StringConstants.venueActions,
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
                                        Icon(
                                          Icons.edit_outlined,
                                          size: AppDimens.sizeX18,
                                          color: LightColor.primaryTextColor,
                                        ),
                                        const SizedBox(
                                          width: AppDimens.sizeX10,
                                        ),
                                        Text(
                                          StringConstants.manageFutsal,
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
                                        Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: AppDimens.sizeX18,
                                          color: LightColor.primaryTextColor,
                                        ),
                                        const SizedBox(
                                          width: AppDimens.sizeX10,
                                        ),
                                        Text(
                                          StringConstants.addCourt,
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

                                child: Icon(
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
                            color: LightColor.brandTextColor,
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
              Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
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
                      Icon(
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
                              onManageCourt: () => _launchCourtEditor(
                                context,
                                venueId: widget.entry.id,
                                court: widget.entry.courts[index],
                              ),
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
            label: StringConstants.approved,
            background: LightColor.secondaryColor,
            foreground: LightColor.inverseTextColor,
          ),
          _VenueApprovalStatus.pending => (
            label: StringConstants.pending,
            background: LightColor.ratingColor.withValues(alpha: 0.20),
            foreground: LightColor.onWarningLightColor,
          ),
          _VenueApprovalStatus.active => (
            label: StringConstants.active,
            background: LightColor.secondaryColor,
            foreground: LightColor.inverseTextColor,
          ),
          _VenueApprovalStatus.inactive => (
            label: StringConstants.inactive,
            background: LightColor.redColor,
            foreground: LightColor.inverseTextColor,
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
            StringConstants.noCourtsAddedYet,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            StringConstants.addYourFirstCourtAndStartAcceptingBookings,
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

  Future<void> _toggleCourtStatus(BuildContext context) async {
    final int? courtId = court.remoteId ?? int.tryParse(court.id);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    if (courtId == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(StringConstants.couldNotIdentifyThisCourt),
        ),
      );
      return;
    }

    final bool currentlyActive = _isCourtActive(court);
    final String nextStatus = currentlyActive ? 'inactive' : 'active';
    final VenueCourtBloc bloc = context.read<VenueCourtBloc>();
    final Either<AppException, Unit> result =
        await GetVenueCourtUseCase(
          VenueCourtRepositoryImpl(),
          // Submit as main step 0 / sub step 0 with that step's required fields;
          // sending the court's own saved step would trigger validation for that
          // step's payload (e.g. `slot_schedules` on step 3).
        ).updateCourtStatus(<String, dynamic>{
          'court_id': courtId,
          'status': nextStatus,
          'main_step': 0,
          'sub_step': 0,
          'court_name': court.name.trim(),
          'base_price': court.basePrice,
          'court_type': court.courtTypeId,
          'match_format': court.matchFormatId,
          'max_player': court.maxPlayers,
        });

    if (!context.mounted) return;
    result.fold(
      (AppException failure) {
        messenger.showSnackBar(SnackBar(content: Text(failure.errorMessage)));
      },
      (_) {
        final int? resolvedVenueId = venueId ?? court.venueId;
        if (resolvedVenueId == null) {
          bloc.add(const FetchVenueCourtEvent());
        } else {
          bloc.add(
            UpsertVenueCourtLocallyEvent(
              venueId: resolvedVenueId,
              court: court.copyWith(
                status: nextStatus,
                enableOnlineBooking: !currentlyActive,
              ),
            ),
          );
        }
        AppUtils().showSnackBar(
          context,
          MsgType.success,
          currentlyActive ? 'Court is now inactive.' : 'Court is now active.',
        );
      },
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
    final String matchFormat = (court.matchFormat ?? '').trim();
    final List<String> courtDetails = <String>[
      type,
      matchFormat,
    ].where((String detail) => detail.isNotEmpty).toList(growable: false);
    final String basePriceLabel = court.basePrice == null
        ? ''
        : 'Base Price: Rs ${court.basePrice!.toStringAsFixed(0)}';
    final String courtDetailsLabel = <String>[
      courtDetails.join(' • '),
      basePriceLabel,
    ].where((String detail) => detail.isNotEmpty).join(' || ');
    final bool isLive = _isCourtActive(court);
    final String photoUrl = court.photos
        .map((UploadRef photo) => (photo.remoteUrl ?? '').trim())
        .firstWhere((String url) => url.isNotEmpty, orElse: () => '');

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
                url: photoUrl.isEmpty ? null : photoUrl,
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
                          if (courtDetailsLabel.isNotEmpty) ...<Widget>[
                            const SizedBox(height: AppDimens.sizeX4),
                            Text(
                              courtDetailsLabel,
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
                      tooltip: StringConstants.courtActions,
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
                        } else if (action ==
                            _VenueMenuAction.toggleCourtStatus) {
                          unawaited(_toggleCourtStatus(context));
                        } else if (action == _VenueMenuAction.deleteCourt) {
                          unawaited(_confirmDeleteCourt(context));
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<_VenueMenuAction>(
                          value: _VenueMenuAction.manageFutsal,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.edit_outlined,
                                size: AppDimens.sizeX18,
                                color: LightColor.primaryTextColor,
                              ),
                              const SizedBox(width: AppDimens.sizeX10),
                              Text(
                                StringConstants.manageCourt,
                                style: textTheme.bodyTextSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: LightColor.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<_VenueMenuAction>(
                          value: _VenueMenuAction.toggleCourtStatus,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                isLive
                                    ? Icons.toggle_off_outlined
                                    : Icons.toggle_on_outlined,
                                size: AppDimens.sizeX18,
                                color: isLive
                                    ? LightColor.redColor
                                    : LightColor.secondaryColor,
                              ),
                              const SizedBox(width: AppDimens.sizeX10),
                              Text(
                                isLive ? 'Make Inactive' : 'Make Active',
                                style: textTheme.bodyTextSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isLive
                                      ? LightColor.redColor
                                      : LightColor.secondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem<_VenueMenuAction>(
                          value: _VenueMenuAction.deleteCourt,
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.delete,
                                size: AppDimens.sizeX18,
                                color: LightColor.primaryTextColor,
                              ),
                              const SizedBox(width: AppDimens.sizeX10),
                              Text(
                                StringConstants.deleteCourt,
                                style: textTheme.bodyTextSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: LightColor.primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      child: Icon(
                        Icons.more_vert_rounded,
                        size: AppDimens.sizeX22,
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
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
                        label: isLive ? 'Active' : 'Inactive',
                        color: isLive
                            ? LightColor.secondaryColor
                            : LightColor.redColor,
                      ),
                      if (court.advancePaymentRequired) ...<Widget>[
                        const SizedBox(width: AppDimens.sizeX6),
                        const _CourtStatusChip(
                          icon: Icons.account_balance_wallet_outlined,
                          label: StringConstants.advance,
                          color: LightColor.secondaryColor,
                        ),
                      ],
                      if (court.isPaymentRequired == true) ...<Widget>[
                        const SizedBox(width: AppDimens.sizeX6),
                        _CourtStatusChip(
                          icon: Icons.payment_rounded,
                          label: 'Online payment',
                          color: LightColor.warningColor,
                        ),
                      ],
                      if (matchFormat.isNotEmpty) ...<Widget>[
                        const SizedBox(width: AppDimens.sizeX6),
                        _CourtStatusChip(
                          icon: Icons.sports_soccer_rounded,
                          label: matchFormat,
                          color: LightColor.brandTextColor,
                        ),
                      ],
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
        if (_isCourtActive(court)) liveCourtCount += 1;
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

bool _isCourtActive(CourtDraft court) {
  return switch (court.status?.trim().toLowerCase()) {
    'active' => true,
    'inactive' => false,
    _ => court.enableOnlineBooking,
  };
}

class _FutsalEntry {
  const _FutsalEntry({
    required this.id,
    required this.title,
    required this.address,
    required this.phone,
    required this.courts,
    this.imageUrl,
    this.approvalStatus = _VenueApprovalStatus.approved,
  });

  final int? id;
  final String title;
  final String address;
  final String phone;
  final List<CourtDraft> courts;
  final String? imageUrl;
  final _VenueApprovalStatus approvalStatus;

  factory _FutsalEntry.fromModel(VenueCourtModel model) {
    return _FutsalEntry(
      id: model.id,
      title: model.title.isEmpty ? 'My Futsal' : model.title,
      address: model.address,
      phone: model.phone,
      courts: model.courts,
      imageUrl: model.imageUrl,
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

  int get liveCourts => courts.where(_isCourtActive).length;

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
        StringConstants.deleteCourt,
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
                text: StringConstants.cancel,
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
                text: StringConstants.delete,
                icon: Icons.delete_outline_rounded,
                isLoading: _isDeleting,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.redColor,
                foregroundColor: LightColor.inverseTextColor,
                onPressed: _isDeleting ? null : _delete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
