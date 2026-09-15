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
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
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
import 'package:hamro_futsal/features/courts/domain/model/venue_court_purpose.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_court_manager.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class VenueCourtsListPage extends StatefulWidget {
  const VenueCourtsListPage({super.key, this.bloc});

  /// Bloc to render from. Only for tests — in the app the page owns its own,
  /// built on the real repository, and closes it again on the way out.
  final VenueCourtBloc? bloc;

  @override
  State<VenueCourtsListPage> createState() => _VenueCourtsListPageState();
}

class _VenueCourtsListPageState extends State<VenueCourtsListPage> {
  final TextEditingController _searchController = TextEditingController();
  late final VenueCourtBloc _venueCourtBloc;
  late final bool _ownsBloc;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _venueCourtBloc =
        widget.bloc ??
        (VenueCourtBloc(
          GetVenueCourtUseCase(VenueCourtRepositoryImpl()),
          // This page is the vendor's own portfolio, so it asks for everything
          // they own — inactive and half-onboarded courts included.
          purpose: VenueCourtPurpose.myVenues,
        )..add(const FetchVenueCourtEvent()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsBloc) _venueCourtBloc.close();
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

              final List<_FutsalEntry> filtered = query.isEmpty
                  ? source
                  : source
                        .where((_FutsalEntry item) => item.matchesQuery(query))
                        .toList();

              return ColoredBox(
                color: LightColor.background,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _TopDashboardHeader(
                      stats: stats,
                      onAddFutsal: () {
                        context.pushNamed(AppRouterParams.vendorStepper.name);
                      },
                    ),
                    const SizedBox(height: AppDimens.paddingX10),
                    _VenueSearchField(controller: _searchController),
                    const SizedBox(height: AppDimens.paddingX6),
                    Expanded(
                      child: state.status == VenueCourtStatus.loading
                          ? const VenueListLoading()
                          : _VenueListSection(
                              state: state,
                              entries: filtered,
                              isSearching: query.isNotEmpty,
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

  // Only a court the API actually persisted belongs in the list. Backing out
  // of the editor leaves the seeded draft unsaved (no remote id), so the list
  // is re-read from the server rather than merging that draft in locally.
  final bool savedRemotely = cubit.state.courts.any(
    (CourtDraft court) => court.remoteId != null,
  );
  // The editor is a whole screen: the list underneath can be disposed while it
  // is open — a deep link, a session ending, the tab being rebuilt — and its
  // bloc closed with it. Asking a closed bloc to refresh throws "Cannot add
  // new events after calling close", which crashed the app on the way back.
  if (savedRemotely && !venueCourtBloc.isClosed) {
    venueCourtBloc.add(const FetchVenueCourtEvent(silent: true));
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
                  // The slug is what loads the venue; the id only rides along
                  // so the update payload has it before the fetch lands.
                  if (entry.slug != null && entry.slug!.isNotEmpty)
                    'futsalSlug': entry.slug!,
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

enum _VenueMenuAction {
  manageFutsal,
  addCourt,
  toggleCourtStatus,
  deleteFutsal,
  deleteCourt,
}

/// The venue status badge, resolved from the API's own `status` string.
enum _VenueApprovalStatus {
  pending,
  approved,
  active,
  inactive,
  rejected;

  /// Maps `status` from `/auth/get-venue-courts` onto a badge.
  ///
  /// Anything unrecognised — and the empty string a half-finished venue can
  /// come back with — reads as [inactive], never as [approved]: claiming a
  /// venue is approved is the one wrong answer here.
  static _VenueApprovalStatus fromStatus(String? status) {
    return switch (status?.trim().toLowerCase()) {
      'active' => active,
      'approved' => approved,
      'pending' ||
      'pending_approval' ||
      'under_review' ||
      'in_review' => pending,
      'rejected' || 'declined' => rejected,
      _ => inactive,
    };
  }
}

class _TopDashboardHeader extends StatelessWidget {
  const _TopDashboardHeader({required this.stats, required this.onAddFutsal});

  final _PortfolioStats stats;
  final VoidCallback onAddFutsal;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final int pending = stats.courtCount - stats.liveCourtCount;

    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX16,
        right: AppDimens.paddingX16,
        top: AppDimens.paddingX14,
      ),
      child: Column(
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
                      StringConstants.futsalPortfolio,
                      style: textTheme.bodyTextLarge?.copyWith(
                        fontSize: AppDimens.fontHeadingSmall - 2,
                        fontWeight: FontWeight.w800,
                        color: LightColor.primaryTextColor,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingX4),
                    Text(
                      stats.futsalCount == 0
                          ? 'Start by adding your first venue'
                          : 'Everything you own, at a glance',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: AppDimens.paddingX14),
          // The four numbers a vendor actually manages this screen by. Read as
          // one strip so they can be compared at a glance rather than hunted
          // for in each card.
          DataCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _PortfolioMetric(
                  label: 'Venues',
                  value: stats.futsalCount,
                  color: LightColor.brandTextColor,
                ),
                const _MetricSeparator(),
                _PortfolioMetric(
                  label: 'Courts',
                  value: stats.courtCount,
                  color: LightColor.primaryTextColor,
                ),
                const _MetricSeparator(),
                _PortfolioMetric(
                  label: 'Live',
                  value: stats.liveCourtCount,
                  color: LightColor.secondaryColor,
                ),
                const _MetricSeparator(),
                _PortfolioMetric(
                  label: 'Pending',
                  value: pending,
                  color: pending > 0
                      ? LightColor.warningColor
                      : LightColor.secondaryTextColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One figure in the portfolio strip: the number first, its name beneath.
class _PortfolioMetric extends StatelessWidget {
  const _PortfolioMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '$value',
            maxLines: 1,
            style: textTheme.bodyTextLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: LightColor.secondaryTextColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricSeparator extends StatelessWidget {
  const _MetricSeparator();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: AppDimens.sizeX32,
    margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX6),
    color: LightColor.dividerColor,
  );
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
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX16),
      child: Container(
        height: AppDimens.sizeX44,
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
  /// Starts open only when there is something to show — a venue with no courts
  /// would otherwise open onto nothing but the empty hint.
  late bool _expandedCourts = widget.entry.courts.isNotEmpty;

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
    final textTheme = FutsalTheme.getTextTheme(context);
    final double? startPrice = widget.entry.startingPrice;
    final int liveCourts = widget.entry.liveCourts;
    final int totalCourts = widget.entry.courts.length;
    final int pendingCourts = totalCourts - liveCourts;
    final String address = widget.entry.address.trim();
    final String phone = widget.entry.phone.trim();

    return Container(
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingX12,
                AppDimens.paddingX12,
                AppDimens.paddingX8,
                AppDimens.paddingX12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _VenueCover(url: widget.entry.imageUrl ?? ''),
                      const SizedBox(width: AppDimens.paddingX12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              widget.entry.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                                color: LightColor.primaryTextColor,
                              ),
                            ),
                            if (address.isNotEmpty) ...<Widget>[
                              const SizedBox(height: AppDimens.sizeX4),
                              Text(
                                address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyTextSmall?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                ),
                              ),
                            ],
                            if (phone.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                phone,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyTextSmall?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
                                  fontFeatures: const <FontFeature>[
                                    FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX6),
                      _VenueMenu(onSelected: _handleMenuAction),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingX12),
                  // Three figures on one rule beneath the header block.
                  Padding(
                    padding: const EdgeInsets.only(
                      right: AppDimens.paddingX8,
                      left: 2,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        _VenueStat(
                          label: 'Courts',
                          value: '$totalCourts',
                          color: LightColor.primaryTextColor,
                        ),
                        const _MetricSeparator(),
                        _VenueStat(
                          label: 'Live',
                          value: '$liveCourts',
                          color: liveCourts > 0
                              ? LightColor.secondaryColor
                              : LightColor.secondaryTextColor,
                        ),
                        const _MetricSeparator(),
                        _VenueStat(
                          label: pendingCourts > 0 ? 'Pending' : 'From',
                          value: pendingCourts > 0
                              ? '$pendingCourts'
                              : startPrice == null
                              ? '—'
                              : Money.npr(startPrice),
                          color: pendingCourts > 0
                              ? LightColor.warningColor
                              : LightColor.primaryTextColor,
                        ),
                        const _MetricSeparator(),
                        // The status closes the figures row: it belongs with
                        // the facts about the venue, not over its name.
                        _VenueApprovalBadge(
                          status: widget.entry.approvalStatus,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: LightColor.dividerColor),
            InkWell(
              onTap: () => setState(() => _expandedCourts = !_expandedCourts),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingX12,
                  AppDimens.paddingX10,
                  AppDimens.paddingX12,
                  AppDimens.paddingX10,
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.sports_soccer_rounded,
                      size: AppDimens.sizeX16,
                      color: LightColor.secondaryTextColor,
                    ),
                    const SizedBox(width: AppDimens.sizeX6),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              'Courts',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: LightColor.primaryTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sizeX6),
                          CountBadge(
                            count: '$totalCourts',
                            background: LightColor.secondaryColor.withValues(
                              alpha: 0.12,
                            ),
                            foreground: LightColor.secondaryColor,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX8),
                    Text(
                      _expandedCourts ? 'Hide' : 'Show',
                      maxLines: 1,
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LightColor.secondaryColor,
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 180),
                      turns: _expandedCourts ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: AppDimens.sizeX18,
                        color: LightColor.secondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_expandedCourts)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingX12,
                  0,
                  AppDimens.paddingX12,
                  AppDimens.paddingX12,
                ),
                child: widget.entry.courts.isEmpty
                    ? _CourtEmptyHintV2(onTap: widget.onAddCourt)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (
                            int index = 0;
                            index < widget.entry.courts.length;
                            index++
                          )
                            Padding(
                              padding: EdgeInsets.only(
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
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The venue's photo at the head of the card, or a neutral placeholder glyph
/// when it has none.
class _VenueCover extends StatelessWidget {
  const _VenueCover({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusX10);
    return Container(
      width: AppDimens.sizeX60,
      height: AppDimens.sizeX60,
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.08),
        borderRadius: radius,
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: url.trim().isEmpty
          ? Icon(
              Icons.stadium_outlined,
              size: AppDimens.sizeX26,
              color: LightColor.secondaryColor.withValues(alpha: 0.5),
            )
          : ClipRRect(
              borderRadius: radius,
              child: CustomImageView(fit: BoxFit.cover, url: url),
            ),
    );
  }
}

/// One figure on a venue card: value above, its name beneath, so the three
/// read as a single measured row.
class _VenueStat extends StatelessWidget {
  const _VenueStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              height: 1.2,
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: color,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// The venue card's overflow menu — manage the venue, or add a court to it.
class _VenueMenu extends StatelessWidget {
  const _VenueMenu({required this.onSelected});

  final ValueChanged<_VenueMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    PopupMenuItem<_VenueMenuAction> item(
      _VenueMenuAction value,
      IconData icon,
      String label,
    ) => PopupMenuItem<_VenueMenuAction>(
      value: value,
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: AppDimens.sizeX18,
            color: LightColor.primaryTextColor,
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColor.primaryTextColor,
            ),
          ),
        ],
      ),
    );

    return PopupMenuButton<_VenueMenuAction>(
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: StringConstants.venueActions,
      color: LightColor.whiteColor,
      surfaceTintColor: LightColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      onSelected: onSelected,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_VenueMenuAction>>[
        item(
          _VenueMenuAction.manageFutsal,
          Icons.edit_outlined,
          StringConstants.manageFutsal,
        ),
        item(
          _VenueMenuAction.addCourt,
          Icons.add_circle_outline_rounded,
          StringConstants.addCourt,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 2, top: 1),
        child: Icon(
          Icons.more_vert_rounded,
          size: AppDimens.sizeX20,
          color: LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}

class _VenueApprovalBadge extends StatelessWidget {
  const _VenueApprovalBadge({required this.status});

  final _VenueApprovalStatus status;

  @override
  Widget build(BuildContext context) {
    // Tinted, not solid: the status is a label on the card, not a banner
    // competing with the venue's own name for attention.
    final ({String label, IconData icon, Color color}) config =
        switch (status) {
          _VenueApprovalStatus.approved => (
            label: StringConstants.approved,
            icon: Icons.verified_rounded,
            color: LightColor.secondaryColor,
          ),
          _VenueApprovalStatus.active => (
            label: StringConstants.active,
            icon: Icons.check_circle_rounded,
            color: LightColor.secondaryColor,
          ),
          _VenueApprovalStatus.pending => (
            label: StringConstants.pending,
            icon: Icons.schedule_rounded,
            color: LightColor.warningColor,
          ),
          _VenueApprovalStatus.inactive => (
            label: StringConstants.inactive,
            icon: Icons.pause_circle_outline_rounded,
            color: LightColor.secondaryTextColor,
          ),
          _VenueApprovalStatus.rejected => (
            label: StringConstants.rejected,
            icon: Icons.cancel_rounded,
            color: LightColor.redColor,
          ),
        };

    return _StatusChip(
      icon: config.icon,
      label: config.label,
      color: config.color,
    );
  }
}

class _CourtEmptyHintV2 extends StatelessWidget {
  const _CourtEmptyHintV2({required this.onTap});

  /// The hint is the only thing in an empty venue card's court list, so the
  /// whole row doubles as the add-court button rather than making the user
  /// hunt for the action in the card's overflow menu.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusX8);

    // One row, the same height as a court row: an empty venue should not open
    // onto a panel three times taller than a venue with courts in it.
    return Material(
      color: LightColor.secondaryColor.withValues(alpha: 0.06),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX14,
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.add_circle_outline_rounded,
                size: AppDimens.sizeX20,
                color: LightColor.secondaryColor,
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Expanded(
                child: Text(
                  StringConstants.noCourtsAddedYet,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Text(
                StringConstants.addCourt,
                maxLines: 1,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.secondaryColor,
                ),
              ),
            ],
          ),
        ),
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
            if (!bloc.isClosed) {
              bloc.add(const FetchVenueCourtEvent(silent: true));
            }
            return null;
          }
          final Either<AppException, Unit> result = await GetVenueCourtUseCase(
            VenueCourtRepositoryImpl(),
          ).deleteCourt(courtId);
          return result.fold((AppException failure) => failure.errorMessage, (
            _,
          ) {
            // The delete round-trip outlives the dialog if the list is torn
            // down mid-flight.
            if (!bloc.isClosed) {
              bloc.add(const FetchVenueCourtEvent(silent: true));
            }
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
        if (!bloc.isClosed) {
          bloc.add(const FetchVenueCourtEvent(silent: true));
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
    final textTheme = FutsalTheme.getTextTheme(context);
    final String name = court.name.trim().isEmpty
        ? 'Court $index'
        : court.name.trim();
    final String type = (court.courtType ?? '').trim();
    final String matchFormat = (court.matchFormat ?? '').trim();
    final String photoUrl = court.photos
        .map((UploadRef photo) => (photo.remoteUrl ?? '').trim())
        .firstWhere((String url) => url.isNotEmpty, orElse: () => '');
    final bool isLive = _isCourtActive(court);

    final String meta = <String>[
      matchFormat,
      type,
      if (court.maxPlayers != null) '${court.maxPlayers} players',
    ].where((String detail) => detail.isNotEmpty).join('  ·  ');

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX10),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Row one: who the court is. The menu holds the card's top-right
          // corner rather than floating beside the name.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CourtThumb(url: photoUrl, isLive: isLive),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontSize: kDataCardListTitleSize,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    if (meta.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySubTitle?.copyWith(
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX6),
              _CourtMenu(
                isLive: isLive,
                onManage: onManageCourt,
                onToggleStatus: () => unawaited(_toggleCourtStatus(context)),
                onDelete: () => unawaited(_confirmDeleteCourt(context)),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX10),
          // Row two: the price anchors the left, the two standings close the
          // right — one line, read left to right.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: court.basePrice == null
                            ? '—'
                            : Money.npr(court.basePrice!),
                        style: textTheme.bodyTextMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: LightColor.primaryTextColor,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                      TextSpan(
                        text: ' /hr',
                        style: textTheme.bodyTextSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              _StatusChip(
                icon: isLive
                    ? Icons.check_circle_rounded
                    : Icons.pause_circle_outline_rounded,
                label: isLive ? 'Active' : 'Inactive',
                color: isLive
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX6),
              _StatusChip(
                icon: court.advancePaymentRequired
                    ? Icons.account_balance_wallet_outlined
                    : Icons.money_off_csred_outlined,
                label: court.advancePaymentRequired
                    ? StringConstants.advance
                    : 'No advance',
                color: court.advancePaymentRequired
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The one status chip this screen has: a tinted pill with a leading glyph.
/// Venues and courts both wear it, so a standing reads the same wherever it
/// appears.
class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppDimens.sizeX12, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySubTitle?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A court's photo, ringed in its own status colour so an inactive court is
/// readable from the thumbnail alone.
class _CourtThumb extends StatelessWidget {
  const _CourtThumb({required this.url, required this.isLive});

  final String url;
  final bool isLive;

  @override
  Widget build(BuildContext context) {
    final Color tint = isLive
        ? LightColor.secondaryColor
        : LightColor.secondaryTextColor;
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusX8);
    return Container(
      width: AppDimens.sizeX52,
      height: AppDimens.sizeX52,
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: radius,
        border: Border.all(color: tint.withValues(alpha: 0.20)),
      ),
      child: url.isEmpty
          ? Icon(
              Icons.sports_soccer_rounded,
              size: AppDimens.sizeX22,
              color: tint.withValues(alpha: 0.55),
            )
          : ClipRRect(
              borderRadius: radius,
              child: CustomImageView(fit: BoxFit.cover, url: url),
            ),
    );
  }
}

class _CourtMenu extends StatelessWidget {
  const _CourtMenu({
    required this.isLive,
    required this.onManage,
    required this.onToggleStatus,
    required this.onDelete,
  });

  final bool isLive;
  final VoidCallback onManage;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    PopupMenuItem<_VenueMenuAction> item(
      _VenueMenuAction value,
      IconData icon,
      String label,
      Color color,
    ) => PopupMenuItem<_VenueMenuAction>(
      value: value,
      child: Row(
        children: <Widget>[
          Icon(icon, size: AppDimens.sizeX18, color: color),
          const SizedBox(width: AppDimens.sizeX10),
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );

    return PopupMenuButton<_VenueMenuAction>(
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      tooltip: StringConstants.courtActions,
      color: LightColor.whiteColor,
      surfaceTintColor: LightColor.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      onSelected: (_VenueMenuAction action) {
        switch (action) {
          case _VenueMenuAction.manageFutsal:
            onManage();
          case _VenueMenuAction.toggleCourtStatus:
            onToggleStatus();
          case _VenueMenuAction.deleteCourt:
            onDelete();
          case _VenueMenuAction.addCourt:
          case _VenueMenuAction.deleteFutsal:
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_VenueMenuAction>>[
        item(
          _VenueMenuAction.manageFutsal,
          Icons.edit_outlined,
          StringConstants.manageCourt,
          LightColor.primaryTextColor,
        ),
        item(
          _VenueMenuAction.toggleCourtStatus,
          isLive ? Icons.toggle_off_outlined : Icons.toggle_on_outlined,
          isLive ? 'Make Inactive' : 'Make Active',
          isLive ? LightColor.redColor : LightColor.secondaryColor,
        ),
        item(
          _VenueMenuAction.deleteCourt,
          Icons.delete_outline_rounded,
          StringConstants.deleteCourt,
          LightColor.redColor,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 2, top: 1),
        child: Icon(
          Icons.more_vert_rounded,
          size: AppDimens.sizeX20,
          color: LightColor.secondaryTextColor,
        ),
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
    required this.slug,
    required this.title,
    required this.address,
    required this.phone,
    required this.courts,
    this.imageUrl,
    this.approvalStatus = _VenueApprovalStatus.inactive,
  });

  final int? id;

  /// How the venue is addressed on the wire: `/auth/get-venue/{slug}` takes
  /// the slug, never the numeric id.
  final String? slug;
  final String title;
  final String address;
  final String phone;
  final List<CourtDraft> courts;
  final String? imageUrl;
  final _VenueApprovalStatus approvalStatus;

  factory _FutsalEntry.fromModel(VenueCourtModel model) {
    return _FutsalEntry(
      id: model.id,
      slug: model.slug,
      title: model.title.isEmpty ? 'My Futsal' : model.title,
      address: model.address,
      phone: model.phone,
      courts: model.courts,
      imageUrl: model.imageUrl,
      // The venue's own status, not a guess from it: this read
      // `isActive ? active : approved`, so every inactive venue — including a
      // half-finished draft with no address, image or courts — was badged
      // "Approved".
      approvalStatus: _VenueApprovalStatus.fromStatus(model.status),
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
