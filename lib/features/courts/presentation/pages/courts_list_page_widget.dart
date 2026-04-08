import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

class CourtsListPage extends StatefulWidget {
  const CourtsListPage({super.key});

  @override
  State<CourtsListPage> createState() => _CourtsListPageState();
}

class _CourtsListPageState extends State<CourtsListPage> {
  final TextEditingController _searchController = TextEditingController();
  _VenueFilter _selectedFilter = _VenueFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;

    final List<_FutsalEntry> source = List<_FutsalEntry>.from(
      _buildFutsalEntries(profileState),
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
            _VenueFilter.needsSetup => item.liveCourts < item.courts.length,
          };

          return matchesSearch && matchesFilter;
        }).toList();

        return DecoratedBox(
          decoration: const BoxDecoration(color: LightColor.surface),
          child: Column(
            children: <Widget>[
              _TopDashboardHeader(
                stats: stats,
                onAddFutsal: () {
                  context.pushNamed(AppRouterParams.vendorStepper.name);
                },
                onAddCourt: () {
                  context.pushNamed(AppRouterParams.createCourts.name);
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
                child: filtered.isEmpty
                    ? ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
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
                                AppRouterParams.createCourts.name,
                              );
                            },
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) => _VenueCardV2(
                          entry: filtered[index],
                          onAddCourt: () {
                            context.pushNamed(
                              AppRouterParams.createCourts.name,
                            );
                          },
                          onEditVenue: () {
                            context.pushNamed(
                              AppRouterParams.vendorStepper.name,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _compareFutsals(_FutsalEntry left, _FutsalEntry right) {
    final int courtCount = right.courts.length.compareTo(left.courts.length);
    if (courtCount != 0) return courtCount;
    return left.title.toLowerCase().compareTo(right.title.toLowerCase());
  }

  List<_FutsalEntry> _buildFutsalEntries(ProfileState state) {
    final Object? raw = state.profile?.data.vendorOnboardingData;
    if (raw is Map) {
      try {
        final VendorOnboardingState onboarding = VendorOnboardingState.fromJson(
          Map<String, dynamic>.from(raw),
        );
        if (onboarding.futsal.title.trim().isNotEmpty ||
            onboarding.courts.isNotEmpty) {
          return <_FutsalEntry>[
            _FutsalEntry(
              title: onboarding.futsal.title.trim().isNotEmpty
                  ? onboarding.futsal.title.trim()
                  : 'My Futsal',
              address: onboarding.futsal.location.fullAddress.trim(),
              phone: onboarding.futsal.phone.trim(),
              courts: onboarding.courts,
            ),
          ];
        }
      } catch (_) {
        return _dummyFutsalEntries;
      }
    }
    return _dummyFutsalEntries;
  }
}

enum _VenueFilter { all, liveOnly, needsSetup }

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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
      decoration: const BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Futsal Portfolio',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: LightColor.titleText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your futsal venues and court operations in one place.',
            style: TextStyle(
              fontSize: 12,
              color: LightColor.subtitleText.withValues(alpha: 0.85),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryStatCard(
                  icon: Icons.apartment_rounded,
                  title: 'Venues',
                  value: '${stats.futsalCount}',
                  color: LightColor.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryStatCard(
                  icon: Icons.grid_view_rounded,
                  title: 'Courts',
                  value: '${stats.courtCount}',
                  color: LightColor.primaryDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryStatCard(
                  icon: Icons.check_circle_rounded,
                  title: 'Live',
                  value: '${stats.liveCourtCount}',
                  color: LightColor.secondary,
                ),
              ),
            ],
          ),
          // const SizedBox(height: 14),
          // _SimpleSearchField(controller: TextEditingController()),
        ],
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  const _SummaryStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: LightColor.subtitleText,
                ),
              ),
            ],
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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? LightColor.secondary.withValues(alpha: 0.12)
                : LightColor.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? LightColor.secondary.withValues(alpha: 0.30)
                  : LightColor.border.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: 18,
                color: isActive
                    ? LightColor.secondary
                    : LightColor.subtitleText,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isActive
                      ? LightColor.secondary
                      : LightColor.subtitleText,
                ),
              ),
              if (badge != null) ...<Widget>[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? LightColor.secondary.withValues(alpha: 0.18)
                        : LightColor.border,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? LightColor.secondary
                          : LightColor.titleText,
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

  @override
  Widget build(BuildContext context) {
    final double? startPrice = widget.entry.startingPrice;
    final String address = widget.entry.address.isEmpty
        ? 'Address not available'
        : widget.entry.address;
    final int liveCourts = widget.entry.liveCourts;
    final int totalCourts = widget.entry.courts.length;

    return Container(
      decoration: BoxDecoration(
        color: LightColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.border.withValues(alpha: 0.45)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            LightColor.secondary,
                            LightColor.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.stadium_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  widget.entry.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: LightColor.titleText,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              _StatusBadgeV2(
                                live: liveCourts,
                                total: totalCourts,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: LightColor.subtitleText.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: LightColor.subtitleText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      _InfoTag(
                        icon: Icons.grid_view_rounded,
                        label: '$totalCourts Courts',
                        color: LightColor.primaryDark,
                      ),
                      const SizedBox(width: 8),
                      _InfoTag(
                        icon: Icons.check_circle_rounded,
                        label: '$liveCourts Live',
                        color: LightColor.secondary,
                      ),
                      const SizedBox(width: 8),
                      if (startPrice != null)
                        _InfoTag(
                          icon: Icons.sell_outlined,
                          label: 'From Rs ${startPrice.toStringAsFixed(0)}',
                          color: LightColor.amber,
                        ),
                      if (widget.entry.phone.isNotEmpty) ...<Widget>[
                        const SizedBox(width: 8),
                        _InfoTag(
                          icon: Icons.call_outlined,
                          label: widget.entry.phone,
                          color: LightColor.accent,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onEditVenue,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: LightColor.border.withValues(alpha: 0.8),
                          ),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: const Text(
                          'Manage Futsal',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onAddCourt,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: LightColor.secondary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_circle_outline_rounded,
                          size: 20,
                        ),
                        label: const Text(
                          'Add Court',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: LightColor.border.withValues(alpha: 0.30),
          ),
          GestureDetector(
            onTap: () {
              setState(() => _expandedCourts = !_expandedCourts);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.sports_soccer_rounded,
                    size: 24,
                    color: LightColor.subtitleText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Courts Inventory ($totalCourts)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: LightColor.titleText,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: LightColor.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      _expandedCourts
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 18,
                      color: LightColor.subtitleText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expandedCourts)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 1,
                    color: LightColor.border.withValues(alpha: 0.22),
                    margin: const EdgeInsets.only(bottom: 12),
                  ),
                  if (widget.entry.courts.isEmpty)
                    const _CourtEmptyHintV2()
                  else
                    ...List<Widget>.generate(
                      widget.entry.courts.length,
                      (int index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index == widget.entry.courts.length - 1
                              ? 0
                              : 10,
                        ),
                        child: _CourtRowV2(
                          court: widget.entry.courts[index],
                          index: index + 1,
                        ),
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

class _StatusBadgeV2 extends StatelessWidget {
  const _StatusBadgeV2({required this.live, required this.total});

  final int live;
  final int total;

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final Color bg;
    late final Color fg;

    if (total == 0) {
      text = 'No Courts';
      bg = LightColor.divider;
      fg = LightColor.subtitleText;
    } else if (live == total) {
      text = 'Fully Live';
      bg = LightColor.secondarySoft;
      fg = LightColor.secondaryDark;
    } else if (live == 0) {
      text = 'Setup Pending';
      bg = LightColor.warningLight;
      fg = const Color(0xFF92400E);
    } else {
      text = '$live/$total Live';
      bg = LightColor.primarySoft;
      fg = LightColor.primaryDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(60),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtEmptyHintV2 extends StatelessWidget {
  const _CourtEmptyHintV2();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LightColor.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LightColor.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: <Widget>[
          Icon(
            Icons.sports_soccer_outlined,
            size: 32,
            color: LightColor.subtitleText.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'No courts added yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: LightColor.subtitleText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            textAlign: TextAlign.center,
            'Add your first court and start accepting bookings.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: LightColor.subtitleText.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtRowV2 extends StatelessWidget {
  const _CourtRowV2({required this.court, required this.index});

  final CourtDraft court;
  final int index;

  @override
  Widget build(BuildContext context) {
    final String name = court.name.trim().isEmpty
        ? 'Court $index'
        : court.name.trim();
    final String type = (court.courtType ?? '').trim();
    final bool isLive = court.enableOnlineBooking;

    final Color iconBg = isLive
        ? LightColor.secondarySoft
        : LightColor.warningLight;

    final Color iconColor = isLive
        ? LightColor.secondary
        : const Color(0xFFD97706);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: LightColor.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: LightColor.border.withValues(alpha: 0.18)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isLive ? Icons.sports_soccer_rounded : Icons.lock_clock_rounded,
              size: 30,
              color: iconColor,
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
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: LightColor.titleText,
                        ),
                      ),
                    ),
                    if (court.basePrice != null) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: LightColor.secondarySoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Rs ${court.basePrice!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: LightColor.secondaryDark,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (type.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      color: LightColor.subtitleText.withValues(alpha: 0.82),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    _CourtStatusChip(
                      icon: isLive
                          ? Icons.check_circle_rounded
                          : Icons.pending_actions_rounded,
                      label: isLive ? 'Live' : 'Inactive',
                      color: isLive ? LightColor.secondary : LightColor.red,
                    ),
                    if (court.advancePaymentRequired)
                      const _CourtStatusChip(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Advance',
                        color: LightColor.accent,
                      ),
                  ],
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
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
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
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: LightColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightColor.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: LightColor.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.dashboard_customize_outlined,
              size: 40,
              color: LightColor.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isSearching ? 'No matching results' : 'No futsal venues yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: LightColor.titleText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try another search or switch your filter.'
                : 'Create your first futsal venue and then add courts for online booking.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: LightColor.subtitleText.withValues(alpha: 0.9),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          if (!isSearching) _addFutsalButtonWidget(),
        ],
      ),
    );
  }

  Widget _addFutsalButtonWidget() {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onManageVenue,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: LightColor.secondary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add_business_rounded),
            label: const Text('Add Futsal'),
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
    required this.title,
    required this.address,
    required this.phone,
    required this.courts,
  });

  final String title;
  final String address;
  final String phone;
  final List<CourtDraft> courts;

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

final List<_FutsalEntry> _dummyFutsalEntries = <_FutsalEntry>[
  _FutsalEntry(
    title: 'Hamro Futsal Arena',
    address: 'Baneshwor, Kathmandu',
    phone: '9812345678',
    courts: <CourtDraft>[
      const CourtDraft(
        id: 'dummy_court_1',
        name: 'Arena Court A',
        basePrice: 1800,
        courtType: '5v5 Indoor',
        enableOnlineBooking: true,
        advancePaymentRequired: true,
      ),
      const CourtDraft(
        id: 'dummy_court_2',
        name: 'Arena Court B',
        basePrice: 1600,
        courtType: '7v7 Turf',
        enableOnlineBooking: true,
      ),
      const CourtDraft(
        id: 'dummy_court_3',
        name: 'Training Court',
        basePrice: 1200,
        courtType: 'Practice Zone',
        enableOnlineBooking: false,
      ),
    ],
  ),
];
