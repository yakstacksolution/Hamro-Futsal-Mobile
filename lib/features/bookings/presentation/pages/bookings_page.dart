import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:hamro_footsall/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_footsall/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/futsal_bookings_tab.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/my_bookings_tab.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookingBloc>(
      create: (_) => BookingBloc(GetBookingsUseCase(BookingRepositoryImpl()))
        ..add(const FetchMyBookingsEvent())
        ..add(const FetchFutsalBookingsEvent()),
      child: const _BookingsView(),
    );
  }
}

class _BookingsView extends StatefulWidget {
  const _BookingsView();

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  BookingStatus? _selectedFilter;

  late final AnimationController _tabAnimCtrl;
  late final Animation<double> _tabAnim;

  static const List<_Filter> _filters = [
    _Filter(label: 'All', status: null),
    _Filter(label: 'Confirmed', status: BookingStatus.confirmed),
    _Filter(label: 'Pending', status: BookingStatus.pending),
    _Filter(label: 'Completed', status: BookingStatus.completed),
    _Filter(label: 'Cancelled', status: BookingStatus.cancelled),
  ];

  @override
  void initState() {
    super.initState();

    _tabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _tabAnim = CurvedAnimation(parent: _tabAnimCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _tabAnimCtrl.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedTab == index) return;

    setState(() {
      _selectedTab = index;
      _selectedFilter = null;
    });

    if (index == 1) {
      _tabAnimCtrl.forward();
    } else {
      _tabAnimCtrl.reverse();
    }
  }

  void _onFilterSelected(BookingStatus? status) {
    if (_selectedFilter == status) return;

    setState(() {
      _selectedFilter = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageHeader(context),
        const SizedBox(height: AppDimens.paddingX20),
        _tabBar(context),
        const SizedBox(height: AppDimens.paddingX14),
        _filterRow(context),
        const SizedBox(height: AppDimens.paddingX6),
        Expanded(
          child: IndexedStack(
            index: _selectedTab,
            children: [
              MyBookingsTab(filter: _selectedFilter),
              FutsalBookingsTab(filter: _selectedFilter),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageHeader(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
        top: AppDimens.paddingX24,
      ),
      child: BlocBuilder<BookingBloc, BookingState>(
        buildWhen: (previous, current) {
          return previous.myBookings != current.myBookings ||
              previous.myBookingsStatus != current.myBookingsStatus ||
              previous.futsalBookings != current.futsalBookings ||
              previous.futsalBookingsStatus != current.futsalBookingsStatus;
        },
        builder: (context, state) {
          final List<BookingModel> bookings = _selectedTab == 0
              ? state.myBookings
              : state.futsalBookings;

          final bool isLoaded = _selectedTab == 0
              ? state.myBookingsStatus == BookingLoadStatus.success
              : state.futsalBookingsStatus == BookingLoadStatus.success;

          final now = DateTime.now();

          final int upcomingCount = bookings.where((booking) {
            return booking.status == BookingStatus.confirmed &&
                booking.date.isAfter(now);
          }).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bookings',
                style: textTheme.bodyTextLarge?.copyWith(
                  fontSize: AppDimens.fontHeadingSmall,
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              if (isLoaded && bookings.isNotEmpty) ...[
                const SizedBox(height: AppDimens.paddingX4),
                Text(
                  '${bookings.length} total'
                  '${upcomingCount > 0 ? ' · $upcomingCount upcoming' : ''}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _tabBar(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX20),
      child: AnimatedBuilder(
        animation: _tabAnim,
        builder: (context, _) {
          return Row(
            children: [
              _TabItem(
                label: 'My Bookings',
                isActive: _selectedTab == 0,
                onTap: () => _onTabSelected(0),
              ),
              const SizedBox(width: AppDimens.paddingX24),
              _TabItem(
                label: 'Futsal Bookings',
                isActive: _selectedTab == 1,
                onTap: () => _onTabSelected(1),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterRow(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX22,
        ),
        itemCount: _filters.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: AppDimens.paddingX8);
        },
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter.status;

          return _FilterChipItem(
            label: filter.label,
            isSelected: isSelected,
            onTap: () => _onFilterSelected(filter.status),
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? LightColor.primaryTextColor
                        : LightColor.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  height: 2,
                  decoration: BoxDecoration(
                    color: isActive
                        ? LightColor.secondaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
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
            color: isSelected
                ? LightColor.primaryTextColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: isSelected
                  ? LightColor.primaryTextColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: isSelected
                  ? LightColor.whiteColor
                  : LightColor.secondaryTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ),
      ),
    );
  }
}

class _Filter {
  const _Filter({required this.label, required this.status});

  final String label;
  final BookingStatus? status;
}
