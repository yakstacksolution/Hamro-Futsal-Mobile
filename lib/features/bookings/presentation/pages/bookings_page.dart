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
import 'package:hamro_footsall/features/bookings/presentation/utils/booking_search.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/futsal_bookings_tab.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/my_bookings_tab.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String role =
        profileState.profile?.data.role.trim().toLowerCase() ?? '';
    if (role.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: LightColor.secondaryColor),
      );
    }
    final bool isCandidate = role == 'candidate';

    return BlocProvider<BookingBloc>(
      create: (_) =>
          BookingBloc(GetBookingsUseCase(BookingRepositoryImpl()))..add(
            isCandidate
                ? const FetchMyBookingsEvent()
                : const FetchFutsalBookingsEvent(),
          ),
      child: _BookingsView(isCandidate: isCandidate),
    );
  }
}

class _BookingsView extends StatefulWidget {
  const _BookingsView({required this.isCandidate});

  final bool isCandidate;

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView> {
  BookingStatus? _selectedFilter;
  BookingDateOrder _dateOrder = BookingDateOrder.ascending;
  DateTime? _fromDate;
  DateTime? _toDate;
  late DateTime _futsalDate;
  // The futsal date navigator only filters once the user interacts with it;
  // tapping "All" deactivates it again so All truly shows everything.
  bool _futsalDateActive = false;
  final TextEditingController _searchController = TextEditingController();

  static const List<_Filter> _myBookingFilters = [
    _Filter(label: StringConstants.all, status: null),
    _Filter(label: StringConstants.pending, status: BookingStatus.pending),
    _Filter(label: StringConstants.confirmed, status: BookingStatus.confirmed),
    _Filter(label: StringConstants.completed, status: BookingStatus.completed),
    _Filter(label: StringConstants.cancelled, status: BookingStatus.cancelled),
    _Filter(label: StringConstants.rejected, status: BookingStatus.rejected),
  ];

  static const List<_Filter> _futsalBookingFilters = [
    _Filter(label: StringConstants.all, status: null),
    _Filter(label: StringConstants.pending, status: BookingStatus.pending),
    _Filter(label: StringConstants.confirmed, status: BookingStatus.confirmed),
    _Filter(label: StringConstants.completed, status: BookingStatus.completed),
    _Filter(label: StringConstants.cancelled, status: BookingStatus.cancelled),
    _Filter(label: StringConstants.rejected, status: BookingStatus.rejected),
  ];

  List<_Filter> get _activeFilters =>
      widget.isCandidate ? _myBookingFilters : _futsalBookingFilters;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _futsalDate = DateTime(now.year, now.month, now.day);

    // Tabs stay alive inside the dashboard's IndexedStack, so re-fetch the
    // latest bookings automatically whenever this tab becomes visible again
    // (also recovers from a fetch that failed while offline).
    DashboardScreen.selectedNavIndex.addListener(_refreshOnTabVisible);
  }

  @override
  void dispose() {
    DashboardScreen.selectedNavIndex.removeListener(_refreshOnTabVisible);
    _searchController.dispose();
    super.dispose();
  }

  void _refreshOnTabVisible() {
    if (!mounted || DashboardScreen.selectedNavIndex.value != 1) return;
    _refreshCurrentTab();
  }

  /// Pulls the latest data for the active tab from the API. Shows the skeleton
  /// loader on the first load and refreshes silently thereafter.
  void _refreshCurrentTab() {
    if (!mounted) return;
    final BookingBloc bloc = context.read<BookingBloc>();
    if (widget.isCandidate) {
      final BookingLoadStatus status = bloc.state.myBookingsStatus;
      if (status == BookingLoadStatus.loading) return;
      bloc.add(
        FetchMyBookingsEvent(silent: status == BookingLoadStatus.success),
      );
    } else {
      final BookingLoadStatus status = bloc.state.futsalBookingsStatus;
      if (status == BookingLoadStatus.loading) return;
      bloc.add(
        FetchFutsalBookingsEvent(silent: status == BookingLoadStatus.success),
      );
    }
  }

  void _onFilterSelected(BookingStatus? status) {
    final bool isAll = status == null;
    if (_selectedFilter == status && !isAll) return;

    setState(() {
      _selectedFilter = status;
      if (isAll) {
        _searchController.clear();
        if (widget.isCandidate) {
          _fromDate = null;
          _toDate = null;
        } else {
          final DateTime now = DateTime.now();
          _futsalDate = DateTime(now.year, now.month, now.day);
          _futsalDateActive = false;
        }
      }
    });
  }

  Future<void> _openDateFilter() async {
    final _BookingDateFilterValue? value =
        await showModalBottomSheet<_BookingDateFilterValue>(
          context: context,
          isScrollControlled: true,
          backgroundColor: LightColor.cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusX20),
            ),
          ),
          builder: (BuildContext context) => _BookingDateFilterSheet(
            initialFromDate: _fromDate,
            initialToDate: _toDate,
            initialOrder: _dateOrder,
          ),
        );
    if (value == null || !mounted) return;
    setState(() {
      _fromDate = value.fromDate;
      _toDate = value.toDate;
      _dateOrder = value.order;
    });
  }

  Future<void> _pickFutsalDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _futsalDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100, 12, 31),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: LightColor.secondaryColor,
              surface: LightColor.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (selected == null || !mounted) return;
    setState(() {
      _futsalDate = DateTime(selected.year, selected.month, selected.day);
      _futsalDateActive = true;
    });
  }

  void _shiftFutsalDate(int days) {
    setState(() {
      _futsalDate = _futsalDate.add(Duration(days: days));
      _futsalDateActive = true;
    });
  }

  void _clearSearch() {
    if (_searchController.text.isEmpty) return;
    _searchController.clear();
    setState(() {});
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
        _searchAndFilterSection(context),
        const SizedBox(height: AppDimens.paddingX8),
        Expanded(
          child: widget.isCandidate
              ? MyBookingsTab(
                  filter: _selectedFilter,
                  searchQuery: _searchController.text,
                  dateOrder: _dateOrder,
                  fromDate: _fromDate,
                  toDate: _toDate,
                )
              : FutsalBookingsTab(
                  filter: _selectedFilter,
                  searchQuery: _searchController.text,
                  dateOrder: _dateOrder,
                  fromDate: _futsalDateActive ? _futsalDate : null,
                  toDate: _futsalDateActive ? _futsalDate : null,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringConstants.bookings,
            style: textTheme.bodyTextLarge?.copyWith(
              fontSize: AppDimens.fontHeadingSmall,
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
        ],
      ),
    );
  }

  Widget _tabBar(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX20),
      child: Row(
        children: [
          _TabItem(
            label: widget.isCandidate
                ? StringConstants.myBookings
                : StringConstants.futsalBookings,
            isActive: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _searchAndFilterSection(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool hasQuery = _searchController.text.trim().isNotEmpty;
    final String hint = widget.isCandidate
        ? 'Search venue, court or booking ID'
        : 'Search court or booking ID';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: AppDimens.sizeX44,
                  decoration: BoxDecoration(
                    color: LightColor.cardColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    border: Border.all(color: LightColor.dividerColor),
                  ),
                  child: TextField(
                    key: const Key('booking-search-field'),
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: AppDimens.sizeX20,
                        color: LightColor.secondaryTextColor,
                      ),
                      suffixIcon: hasQuery
                          ? IconButton(
                              key: const Key('clear-booking-search'),
                              tooltip: StringConstants.clearSearch,
                              onPressed: _clearSearch,
                              icon: const Icon(
                                Icons.close_rounded,
                                size: AppDimens.sizeX18,
                                color: LightColor.secondaryTextColor,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              if (widget.isCandidate) ...[
                const SizedBox(width: AppDimens.paddingX8),
                _DateFilterButton(
                  fromDate: _fromDate,
                  toDate: _toDate,
                  selectedOrder: _dateOrder,
                  onTap: _openDateFilter,
                ),
              ] else ...[
                const SizedBox(width: AppDimens.paddingX8),
                _FutsalDateNavigator(
                  date: _futsalDate,
                  onPrevious: () => _shiftFutsalDate(-1),
                  onNext: () => _shiftFutsalDate(1),
                  onDateTap: _pickFutsalDate,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingX20),

        _filterRow(context),
      ],
    );
  }

  Widget _filterRow(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
        ),
        itemCount: _activeFilters.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: AppDimens.paddingX8);
        },
        itemBuilder: (context, index) {
          final filter = _activeFilters[index];
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
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
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
            color: isSelected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
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

class _FutsalDateNavigator extends StatelessWidget {
  const _FutsalDateNavigator({
    required this.date,
    required this.onPrevious,
    required this.onNext,
    required this.onDateTap,
  });

  final DateTime date;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      height: AppDimens.sizeX44,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            key: const Key('previous-futsal-booking-date'),
            onTap: onPrevious,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_left_rounded),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const Key('select-futsal-booking-date'),
              onTap: onDateTap,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _formatNavigatorDate(date),
                  maxLines: 1,
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          InkWell(
            key: const Key('next-futsal-booking-date'),
            onTap: onNext,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(Icons.chevron_right_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateFilterButton extends StatelessWidget {
  const _DateFilterButton({
    required this.fromDate,
    required this.toDate,
    required this.selectedOrder,
    required this.onTap,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final BookingDateOrder selectedOrder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasRange = fromDate != null || toDate != null;
    return Tooltip(
      message: hasRange ? 'Edit date range' : 'Filter by date',
      child: Material(
        color: hasRange
            ? LightColor.secondaryColor.withValues(alpha: 0.10)
            : LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: InkWell(
          key: const Key('booking-date-filter'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          child: Container(
            width: AppDimens.sizeX44,
            height: AppDimens.sizeX44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              border: Border.all(
                color: hasRange
                    ? LightColor.secondaryColor.withValues(alpha: 0.45)
                    : LightColor.dividerColor,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: AppDimens.sizeX20,
                  color: LightColor.secondaryColor,
                ),
                Positioned(
                  right: AppDimens.paddingX4,
                  bottom: AppDimens.paddingX4,
                  child: Icon(
                    selectedOrder == BookingDateOrder.ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: AppDimens.sizeX10,
                    color: LightColor.secondaryColor,
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

class _BookingDateFilterValue {
  const _BookingDateFilterValue({
    required this.fromDate,
    required this.toDate,
    required this.order,
  });

  final DateTime? fromDate;
  final DateTime? toDate;
  final BookingDateOrder order;
}

class _BookingDateFilterSheet extends StatefulWidget {
  const _BookingDateFilterSheet({
    required this.initialFromDate,
    required this.initialToDate,
    required this.initialOrder,
  });

  final DateTime? initialFromDate;
  final DateTime? initialToDate;
  final BookingDateOrder initialOrder;

  @override
  State<_BookingDateFilterSheet> createState() =>
      _BookingDateFilterSheetState();
}

class _BookingDateFilterSheetState extends State<_BookingDateFilterSheet> {
  DateTime? _fromDate;
  DateTime? _toDate;
  late BookingDateOrder _order;

  @override
  void initState() {
    super.initState();
    _fromDate = widget.initialFromDate;
    _toDate = widget.initialToDate;
    _order = widget.initialOrder;
  }

  Future<void> _selectFromDate() async {
    final DateTime? selected = await _showPicker(
      initialDate: _fromDate ?? _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _fromDate = selected;
      if (_toDate != null && _toDate!.isBefore(selected)) {
        _toDate = null;
      }
    });
  }

  Future<void> _selectToDate() async {
    final DateTime firstDate = _fromDate ?? DateTime(2020);
    final DateTime? selected = await _showPicker(
      initialDate: _toDate ?? _fromDate ?? DateTime.now(),
      firstDate: firstDate,
    );
    if (selected == null || !mounted) return;
    setState(() => _toDate = selected);
  }

  Future<DateTime?> _showPicker({
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    final DateTime safeInitial = initialDate.isBefore(firstDate)
        ? firstDate
        : initialDate;
    return showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate,
      lastDate: DateTime(2100, 12, 31),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: LightColor.secondaryColor,
              surface: LightColor.cardColor,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  void _clear() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      _BookingDateFilterValue(
        fromDate: _fromDate,
        toDate: _toDate,
        order: _order,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: AppUtils().getPadding(
          left: AppDimens.paddingX20,
          right: AppDimens.paddingX20,
          top: AppDimens.paddingX10,
          bottom: AppDimens.paddingX20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: AppDimens.sizeX40,
                height: AppDimens.sizeX4,
                decoration: BoxDecoration(
                  color: LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    StringConstants.filterByDate,
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: StringConstants.close,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: StringConstants.fromDate,
                    value: _fromDate,
                    onTap: _selectFromDate,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX10),
                Expanded(
                  child: _DateField(
                    label: StringConstants.toDate,
                    value: _toDate,
                    onTap: _selectToDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX18),
            Text(
              StringConstants.dateOrder,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX8),
            Row(
              children: [
                Expanded(
                  child: _SheetOrderButton(
                    label: StringConstants.ascending,
                    icon: Icons.arrow_upward_rounded,
                    isSelected: _order == BookingDateOrder.ascending,
                    onTap: () =>
                        setState(() => _order = BookingDateOrder.ascending),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX10),
                Expanded(
                  child: _SheetOrderButton(
                    label: StringConstants.descending,
                    icon: Icons.arrow_downward_rounded,
                    isSelected: _order == BookingDateOrder.descending,
                    onTap: () =>
                        setState(() => _order = BookingDateOrder.descending),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX20),
            Row(
              children: [
                TextButton(
                  onPressed: _clear,
                  child: const Text(
                    StringConstants.clear,
                    style: TextStyle(color: LightColor.secondaryTextColor),
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX12),
                Expanded(
                  child: SizedBox(
                    height: AppDimens.sizeX42,
                    child: FilledButton(
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        backgroundColor: LightColor.secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX8,
                          ),
                        ),
                      ),
                      child: const Text(StringConstants.applyFilter),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: LightColor.background,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Container(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySubTitle?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: AppDimens.sizeX16,
                    color: LightColor.secondaryColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX6),
                  Expanded(
                    child: Text(
                      value == null ? 'Select date' : _formatFilterDate(value!),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: value == null
                            ? LightColor.hintTextColor
                            : LightColor.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOrderButton extends StatelessWidget {
  const _SheetOrderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: isSelected
          ? LightColor.secondaryColor.withValues(alpha: 0.10)
          : LightColor.background,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Container(
          height: AppDimens.sizeX42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: AppDimens.sizeX18,
                color: isSelected
                    ? LightColor.secondaryColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isSelected
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
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

String _formatFilterDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _formatNavigatorDate(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day} ${date.year}';
}

class _Filter {
  const _Filter({required this.label, required this.status});

  final String label;
  final BookingStatus? status;
}
