import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/core/utils/scroll_behavior.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/bookings/data/model/manual_booking_details.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_recurrence.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/create_booking_request.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/recurring_availability_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_court_item_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/slots_selection/slots_selection_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/booking_options.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/compact_date_time_selector.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/court_slot_card.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/loading/available_courts_loading.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/loading/selection_time_loading.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class SlotsSelectionPage extends StatefulWidget {
  const SlotsSelectionPage({
    super.key,
    required this.court,
    this.manualBooking,
  });

  final CourtDetailModel court;
  final ManualBookingDetails? manualBooking;

  @override
  State<SlotsSelectionPage> createState() => _SlotsSelectionPageState();
}

class _SlotsSelectionPageState extends State<SlotsSelectionPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _bottomBarController;
  late final Animation<Offset> _bottomBarSlide;
  bool _isConfirmingManualBooking = false;

  String _apiDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  Future<void> _confirmManualBooking(BookingDraft draft) async {
    final ManualBookingDetails? manual = draft.manualBooking;
    if (manual == null || _isConfirmingManualBooking) return;

    setState(() => _isConfirmingManualBooking = true);
    final result = await FutsalDetailsRepositoryImpl().createBooking(
      CreateBookingRequest(
        venueId: draft.venueId,
        courtId: draft.courtId,
        bookingDate: _apiDate(draft.selectedDate),
        startTime: draft.apiTime ?? '',
        endTime: draft.apiEndTime,
        paymentMethod: manual.paymentMethod,
        repeatWeeks: draft.repeatWeeksPayload,
        bookingDates: draft.apiSessionDates,
        paymentNote: manual.paymentNote,
        bookingType: 'manual',
        customerName: manual.customerName,
        customerPhone: manual.customerPhone,
        customerEmail: manual.customerEmail,
        paymentType: manual.paymentType,
        paymentStatus: manual.paymentStatus,
        bookingStatus: manual.bookingStatus,
      ),
    );
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() => _isConfirmingManualBooking = false);
        AppUtils().showSnackBar(
          context,
          MsgType.error,
          failure.errorMessage,
          key: 'manual_booking_failed',
        );
      },
      (_) {
        AppUtils().showSnackBar(
          context,
          MsgType.success,
          'Booking confirmed successfully.',
          key: 'manual_booking_success',
        );
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

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

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bottomBarController.forward();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !mounted) return;
    context.read<SlotsSelectionBloc>().add(
      const SlotsRealtimeRefreshRequested(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bottomBarController.dispose();
    super.dispose();
  }

  Widget _buildBookingTypeSection() {
    return BlocBuilder<SlotsSelectionBloc, SlotsSelectionState>(
      builder: (BuildContext context, SlotsSelectionState state) {
        final VenueCourtItemModel? selectedCourt = state.selectedCourt;
        if (selectedCourt == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.paddingX20,
            top: AppDimens.paddingX12,
            right: AppDimens.paddingX20,
          ),
          child: BookingTypeCard(
            mode: state.bookingMode,
            startDate: state.selectedDate,
            recurrence: state.recurrence,
            selectedTime: state.selectedTime,
            selectedCourt: selectedCourt,
            isCheckingAvailability:
                state.recurringCheckStatus == RecurringCheckStatus.loading,
            availability:
                state.recurringCheckStatus == RecurringCheckStatus.success
                ? state.recurringAvailability
                : null,
            onModeChanged: (BookingMode value) {
              context.read<SlotsSelectionBloc>().add(
                ChangeSlotsBookingModeEvent(value),
              );
            },
            onRecurrenceChanged: (BookingRecurrence value) {
              context.read<SlotsSelectionBloc>().add(
                ChangeSlotsRecurrenceEvent(value),
              );
            },
            weekdays: state.effectiveWeekdays,
            onWeekdayToggled: (int weekday) {
              context.read<SlotsSelectionBloc>().add(
                ToggleSlotsRecurringDayEvent(weekday),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRecurringAvailabilitySection() {
    return BlocBuilder<SlotsSelectionBloc, SlotsSelectionState>(
      builder: (BuildContext context, SlotsSelectionState state) {
        if (!state.isRecurring ||
            state.selectedCourt == null ||
            state.recurringCheckStatus == RecurringCheckStatus.idle) {
          return const SizedBox.shrink();
        }

        Widget child;
        switch (state.recurringCheckStatus) {
          case RecurringCheckStatus.idle:
          case RecurringCheckStatus.loading:
            // Loading is shown inline on the duration boxes, not here.
            child = const SizedBox.shrink();
          case RecurringCheckStatus.failure:
            child = _AvailabilityMessage(
              title: StringConstants.availabilityCheckFailed,
              message:
                  state.recurringAvailabilityError ??
                  'Could not check availability for the selected dates.',
              onRetry: () {
                context.read<SlotsSelectionBloc>().add(
                  const CheckRecurringAvailabilityRequested(),
                );
              },
            );
          case RecurringCheckStatus.success:
            final RecurringAvailabilityModel? model =
                state.recurringAvailability;
            // The card lists both the available and the unavailable dates, so
            // it stays useful even when everything is free.
            if (model != null && model.hasSessions) {
              child = _RecurringAvailabilityResult(model: model);
            } else {
              child = const SizedBox.shrink();
            }
        }

        return Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.paddingX20,
            top: AppDimens.paddingX12,
            right: AppDimens.paddingX20,
          ),
          child: child,
        );
      },
    );
  }

  Widget _buildDateTimeSection() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX20,
        top: AppDimens.paddingX12,
        right: AppDimens.paddingX20,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingX12),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.05),
              blurRadius: AppDimens.sizeX14,
              offset: const Offset(0, AppDimens.sizeX4),
            ),
          ],
        ),
        child: BlocBuilder<SlotsSelectionBloc, SlotsSelectionState>(
          builder: (BuildContext context, SlotsSelectionState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (state.otherViewers > 0) ...<Widget>[
                  _LiveViewersBadge(count: state.otherViewers),
                  const SizedBox(height: AppDimens.sizeX10),
                ],
                CompactDateTimeSelector(
                  dates: state.dates,
                  timeSlots: state.timeSlots,
                  selectedDateIndex: state.safeSelectedDateIndex,
                  selectedSlotIndex: state.selectedSlotIndex,
                  onDateSelected: (int index) {
                    context.read<SlotsSelectionBloc>().add(
                      SelectSlotsDateEvent(index),
                    );
                  },
                  onSlotSelected: (int index) {
                    context.read<SlotsSelectionBloc>().add(
                      SelectSlotsTimeEvent(index),
                    );
                  },
                ),
                if (state.isLoading && state.timeSlots.isEmpty)
                  const SelectionTimeLoading()
                else if (state.status == SlotsSelectionStatus.failure &&
                    state.timeSlots.isEmpty) ...<Widget>[
                  const SizedBox(height: AppDimens.sizeX12),
                  _AvailabilityMessage(
                    title: StringConstants.slotsUnavailable,
                    message:
                        state.errorMessage ??
                        'Could not load slots for this date.',
                    onRetry: () {
                      context.read<SlotsSelectionBloc>().add(
                        const RefreshSlotsAvailabilityEvent(),
                      );
                    },
                  ),
                ] else if (!state.isLoading &&
                    state.timeSlots.isEmpty) ...<Widget>[
                  const SizedBox(height: AppDimens.sizeX12),
                  const _AvailabilityMessage(
                    title: StringConstants.noSlotsFound,
                    message: StringConstants.noTimeSlotsAreAvailableForThisDate,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCourtsSection() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX20,
        top: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
      ),
      child: BlocBuilder<SlotsSelectionBloc, SlotsSelectionState>(
        builder: (BuildContext context, SlotsSelectionState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _CourtsSectionHeader(
                subtitle: state.hasSlotSelection
                    ? (state.slotLabel ?? 'For the selected time')
                    : 'All courts for this date',
                availableCount: state.availableCourtCount,
                totalCount: state.courts.length,
              ),
              const SizedBox(height: AppDimens.sizeX12),
              if (state.isLoading && state.courts.isEmpty)
                const AvailableCourtsLoading()
              else if (state.courts.isEmpty)
                _AvailabilityMessage(
                  title: StringConstants.noCourtsAvailable,
                  message: state.hasSlotSelection
                      ? 'No courts are available for this date and time.'
                      : 'No courts are available for this date.',
                  onRetry: state.status == SlotsSelectionStatus.failure
                      ? () {
                          context.read<SlotsSelectionBloc>().add(
                            const RefreshSlotsAvailabilityEvent(),
                          );
                        }
                      : null,
                )
              else
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    // Wrap, not GridView: card height varies with the slot
                    // content, and a fixed mainAxisExtent would clip the tall
                    // ones. A Wrap row is as tall as its tallest card.
                    final int columns = columnsFor(
                      availableWidth: constraints.maxWidth,
                      minItemWidth: AppDimens.courtSlotCardMinWidth,
                      spacing: AppDimens.sizeX12,
                      maxColumns: 2,
                    );
                    if (columns == 1) {
                      return Column(
                        children: <Widget>[
                          for (int i = 0; i < state.courts.length; i++)
                            _courtCard(context, state, i),
                        ],
                      );
                    }
                    final double tile =
                        (constraints.maxWidth -
                            AppDimens.sizeX12 * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: AppDimens.sizeX12,
                      runSpacing: AppDimens.sizeX12,
                      children: <Widget>[
                        for (int i = 0; i < state.courts.length; i++)
                          SizedBox(
                            width: tile,
                            child: _courtCard(context, state, i),
                          ),
                      ],
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _courtCard(BuildContext context, SlotsSelectionState state, int i) {
    return CourtSlotCard(
      court: state.courts[i],
      selectedDate: state.selectedDate,
      selectedTime: state.selectedTime,
      slotLabel: state.slotLabel,
      recurringDates: state.isRecurring ? state.sessionDates : null,
      selected: state.selectedCourtIndex == i,
      onTap: state.courts[i].isAvailable
          ? () {
              HapticFeedback.selectionClick();
              context.read<SlotsSelectionBloc>().add(SelectSlotsCourtEvent(i));
            }
          : null,
    );
  }

  /// Keeps the bottom bar's summary and CTA together in the middle of a wide
  /// window instead of pinned to opposite edges.
  double _bottomBarInset(BuildContext context) {
    const double base = AppDimens.paddingX12;
    if (!context.isTabletOrWider) return base;
    final double slack =
        (context.screenWidth - AppDimens.slotsSelectionColumnMaxWidth) / 2;
    return slack > base ? slack : AppDimens.paddingX32;
  }

  /// When the server reported taken dates for a recurring booking, asks the
  /// user whether to book the remaining ones or go back and pick another
  /// date/slot. Returns the draft to book with, or null to stay on this page.
  Future<BookingDraft?> _resolveUnavailableDates(
    BuildContext context,
    SlotsSelectionState state,
    BookingDraft draft,
  ) async {
    final RecurringAvailabilityModel? model = state.recurringAvailability;
    if (!state.isRecurring ||
        model == null ||
        !model.hasUnavailableDates ||
        state.recurringCheckStatus != RecurringCheckStatus.success) {
      return draft;
    }

    final Set<String> unavailableKeys = model.unavailableDateKeys;
    final List<DateTime> keep = draft.sessionDates
        .where((DateTime d) => !unavailableKeys.contains(_apiDate(d)))
        .toList(growable: false);
    final List<DateTime> dropped = draft.sessionDates
        .where((DateTime d) => unavailableKeys.contains(_apiDate(d)))
        .toList(growable: false);

    if (keep.isEmpty) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'None of these dates are available. Please choose another date or time slot.',
        key: 'recurring_no_dates_available',
      );
      return null;
    }

    final bool? continueWithout = await showAppBottomSheet<bool>(
      context: context,
      child: _UnavailableDatesSheet(
        unavailableDates: dropped,
        availableCount: keep.length,
        selectedTime: state.selectedTime ?? '',
      ),
    );
    if (continueWithout != true) return null;

    final VenueCourtItemModel? court = state.selectedCourt;
    final double subtotal = court == null
        ? draft.subtotal
        : keep.fold<double>(
            0,
            (double sum, DateTime date) =>
                sum + court.priceFor(date, state.selectedTime),
          );

    return draft.withSessionDates(
      dates: keep,
      dropped: dropped,
      subtotal: subtotal,
    );
  }

  Widget _buildBottomBar() {
    return SlideTransition(
      position: _bottomBarSlide,
      child: BlocBuilder<SlotsSelectionBloc, SlotsSelectionState>(
        builder: (BuildContext context, SlotsSelectionState state) {
          final bool canBook =
              state.hasSlotSelection &&
              (state.selectedCourt?.isAvailable ?? false);
          final bool canPressAction =
              !_isConfirmingManualBooking &&
              (!state.hasSlotSelection || canBook);

          return Container(
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
                  color: LightColor.shadowOf(0.12),
                  blurRadius: AppDimens.radiusX28,
                  offset: const Offset(0, AppDimens.sizeX10),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              minimum: EdgeInsets.symmetric(
                horizontal: _bottomBarInset(context),
                vertical: AppDimens.paddingX12,
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double buttonWidth = (constraints.maxWidth * 0.42)
                      .clamp(AppDimens.sizeX148, AppDimens.sizeX210);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: _BookingBarSummary(
                          priceText: state.priceText,
                          priceUnit: state.priceUnit,
                          selectedLabel: state.selectedLabel,
                          canBook: canBook,
                        ),
                      ),
                      const SizedBox(width: AppDimens.sizeX12),
                      SizedBox(
                        width: buttonWidth,
                        height: AppDimens.sizeX52,
                        child: CustomButton(
                          text: canBook && widget.manualBooking != null
                              ? (_isConfirmingManualBooking
                                    ? 'Confirming…'
                                    : 'Confirm Booking')
                              : state.buttonText,
                          isLoading: _isConfirmingManualBooking,
                          onPressed: canPressAction
                              ? () async {
                                  if (!state.hasSlotSelection) {
                                    AppUtils().showSnackBar(
                                      context,
                                      MsgType.error,
                                      StringConstants.pleaseSelectTimeSlot,
                                      key: 'slot_selection_required',
                                    );
                                    return;
                                  }

                                  HapticFeedback.mediumImpact();
                                  BookingDraft? draft = state.bookingDraft
                                      ?.withManualBooking(widget.manualBooking);
                                  if (draft == null) return;

                                  final BookingDraft? resolved =
                                      await _resolveUnavailableDates(
                                        context,
                                        state,
                                        draft,
                                      );
                                  if (resolved == null || !context.mounted) {
                                    return;
                                  }
                                  draft = resolved;
                                  if (widget.manualBooking != null) {
                                    await _confirmManualBooking(draft);
                                    return;
                                  }
                                  final BookingDraft? booked = await context
                                      .pushNamed<BookingDraft>(
                                        AppRouterParams.bookingCheckout.name,
                                        extra: draft,
                                      );
                                  if (booked != null && context.mounted) {
                                    Navigator.of(context).pop(booked);
                                  }
                                }
                              : null,
                          backgroundColor: canPressAction
                              ? LightColor.secondaryColor
                              : LightColor.dividerColor,
                          foregroundColor: canPressAction
                              ? LightColor.inverseTextColor
                              : LightColor.hintTextColor,
                          minHeight: AppDimens.sizeX52,
                          minWidth: AppDimens.sizeX148,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: FutsalScrollBehavior(),
      child: Scaffold(
        backgroundColor: LightColor.background,
        appBar: AppBar(
          backgroundColor: LightColor.background,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: AppDimens.sizeX18,
              color: LightColor.primaryTextColor,
            ),
          ),
          title: Text(
            StringConstants.selectMatchDateTime,
            style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: context.isDesktop
              ? Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimens.slotsSelectionMaxWidth,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildDateTimeSection(),
                              _buildBookingTypeSection(),
                              _buildRecurringAvailabilitySection(),
                              const SizedBox(height: AppDimens.sizeX20),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _buildCourtsSection(),
                              const SizedBox(height: AppDimens.sizeX20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: context.isTablet
                          ? AppDimens.slotsSelectionColumnMaxWidth
                          : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildDateTimeSection(),
                        _buildBookingTypeSection(),
                        _buildRecurringAvailabilitySection(),
                        _buildCourtsSection(),
                        const SizedBox(height: AppDimens.sizeX20),
                      ],
                    ),
                  ),
                ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}

class _BookingBarSummary extends StatelessWidget {
  const _BookingBarSummary({
    required this.priceText,
    required this.priceUnit,
    required this.selectedLabel,
    required this.canBook,
  });

  final String priceText;
  final String priceUnit;
  final String selectedLabel;
  final bool canBook;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: AppDimens.paddingX6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child: Text(
                  priceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextLarge?.copyWith(
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ),
              SizedBox(width: AppDimens.sizeX4),
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimens.paddingX2),
                child: Text(
                  priceUnit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppDimens.sizeX6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimens.sizeX250),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX10,
              vertical: AppDimens.paddingX4,
            ),
            decoration: BoxDecoration(
              color: canBook
                  ? LightColor.secondarySoft
                  : LightColor.inputFillColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  canBook ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  size: AppDimens.sizeX12,
                  color: canBook
                      ? LightColor.secondaryColor
                      : LightColor.hintTextColor,
                ),
                SizedBox(width: AppDimens.sizeX4 + 1),
                Flexible(
                  child: Text(
                    selectedLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMiniSubTitle?.copyWith(
                      color: canBook
                          ? LightColor.secondaryColor
                          : LightColor.hintTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Section title for the courts list: accent bar + title, the current filter
/// context underneath, and an availability count pill that turns muted when
/// nothing is bookable.
class _CourtsSectionHeader extends StatelessWidget {
  const _CourtsSectionHeader({
    required this.subtitle,
    required this.availableCount,
    required this.totalCount,
  });

  final String subtitle;
  final int availableCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool hasAvailable = availableCount > 0;
    final Color accent = hasAvailable
        ? LightColor.secondaryColor
        : LightColor.hintTextColor;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: AppDimens.sizeX4,
          height: AppDimens.sizeX28,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX4),
          ),
        ),
        const SizedBox(width: AppDimens.sizeX10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                StringConstants.availableCourts,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: LightColor.hintTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.sizeX8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX4,
          ),
          decoration: BoxDecoration(
            color: hasAvailable
                ? LightColor.secondarySoft
                : LightColor.dividerColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(AppDimens.radiusX50),
          ),
          child: Text(
            totalCount == 0
                ? '0 courts'
                : '$availableCount of $totalCount available',
            style: textTheme.bodyMiniSubTitle?.copyWith(
              color: accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

/// "N others viewing" chip fed by the booking presence channel roster —
/// nudges the user that slots on this date may get taken in real time.
class _LiveViewersBadge extends StatelessWidget {
  const _LiveViewersBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: LightColor.secondarySoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusX50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: AppDimens.sizeX8,
            height: AppDimens.sizeX8,
            decoration: const BoxDecoration(
              color: LightColor.secondaryColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX6),
          Text(
            count == 1
                ? '1 other person viewing this date'
                : '$count others viewing this date',
            style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
              color: LightColor.secondaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityMessage extends StatelessWidget {
  const _AvailabilityMessage({
    required this.title,
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.greyBorderColor.withValues(alpha: 1.2),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info_outline_rounded,
            size: AppDimens.sizeX18,
            color: LightColor.primaryTextColor,
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  message,
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(width: AppDimens.sizeX8),
            TextButton(
              onPressed: onRetry,
              child: const Text(StringConstants.retry),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecurringAvailabilityResult extends StatelessWidget {
  const _RecurringAvailabilityResult({required this.model});

  final RecurringAvailabilityModel model;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool allOk = model.allAvailable;
    final bool single = model.totalCount == 1;
    final Color accent = allOk
        ? LightColor.secondaryColor
        : LightColor.redColor;

    final String summary = single
        ? (allOk ? 'Slot is available' : 'Slot is not available')
        : '${model.availableCount} of ${model.totalCount} dates available';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                allOk
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                color: accent,
                size: AppDimens.sizeX20,
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Expanded(
                child: Text(
                  summary,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (model.totalCount > 1) ...<Widget>[
            if (model.unavailableSessions.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDimens.sizeX10),
              _AvailabilityGroupLabel(
                label: 'Unavailable · ${model.unavailableCount}',
                color: LightColor.redColor,
              ),
              const SizedBox(height: AppDimens.sizeX8),
              ...model.unavailableSessions.map(
                (AvailabilitySession s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingX8),
                  child: _RecurringAvailabilityRow(session: s),
                ),
              ),
            ],
            if (model.availableSessions.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppDimens.sizeX4),
              _AvailabilityGroupLabel(
                label: 'Available · ${model.availableCount}',
                color: LightColor.secondaryColor,
              ),
              const SizedBox(height: AppDimens.sizeX8),
              ...model.availableSessions.map(
                (AvailabilitySession s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingX8),
                  child: _RecurringAvailabilityRow(session: s),
                ),
              ),
            ],
          ],
          if (!allOk) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX2),
            Text(
              single
                  ? 'Please pick another date or time.'
                  : 'Some dates are taken. You can book the rest or pick another date and slot.',
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: LightColor.hintTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecurringAvailabilityRow extends StatelessWidget {
  const _RecurringAvailabilityRow({required this.session});

  final AvailabilitySession session;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool ok = session.isAvailable;
    final Color color = ok ? LightColor.secondaryColor : LightColor.redColor;
    final String label = session.dateTime != null
        ? _dateLabel(session.dateTime!)
        : session.date;

    return Row(
      children: <Widget>[
        Icon(
          ok ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
          size: AppDimens.sizeX16,
          color: color,
        ),
        const SizedBox(width: AppDimens.sizeX8),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
              decoration: ok ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
        Text(
          session.status.label,
          style: textTheme.bodyMiniSubTitle?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

String _dateLabel(DateTime date) {
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
  const List<String> days = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
}

/// Small caption separating the available and unavailable date groups.
class _AvailabilityGroupLabel extends StatelessWidget {
  const _AvailabilityGroupLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Asks whether to book the remaining dates of a recurring schedule after the
/// server reported some of them taken. Pops `true` to continue without them.
class _UnavailableDatesSheet extends StatelessWidget {
  const _UnavailableDatesSheet({
    required this.unavailableDates,
    required this.availableCount,
    required this.selectedTime,
  });

  final List<DateTime> unavailableDates;
  final int availableCount;
  final String selectedTime;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX36,
                decoration: BoxDecoration(
                  color: LightColor.redColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: Icon(
                  Icons.event_busy_rounded,
                  size: AppDimens.sizeX18,
                  color: LightColor.redColor,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      unavailableDates.length == 1
                          ? '1 date is unavailable'
                          : '${unavailableDates.length} dates are unavailable',
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      'Continue without these dates, or choose another date and slot.',
                      style: textTheme.bodySubTitle?.copyWith(
                        color: LightColor.hintTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: unavailableDates.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppDimens.sizeX8),
              itemBuilder: (BuildContext context, int index) {
                final DateTime date = unavailableDates[index];
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingX12,
                    vertical: AppDimens.paddingX10,
                  ),
                  decoration: BoxDecoration(
                    color: LightColor.redColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    border: Border.all(
                      color: LightColor.redColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.cancel_rounded,
                        size: AppDimens.sizeX16,
                        color: LightColor.redColor,
                      ),
                      const SizedBox(width: AppDimens.sizeX8),
                      Expanded(
                        child: Text(
                          selectedTime.isEmpty
                              ? _dateLabel(date)
                              : '${_dateLabel(date)} · $selectedTime',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySubTitle?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      Text(
                        'Unavailable',
                        style: textTheme.bodyMiniSubTitle?.copyWith(
                          color: LightColor.redColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimens.sizeX14),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: availableCount == 1
                  ? 'Continue with 1 date'
                  : 'Continue with $availableCount dates',
              onPressed: () => Navigator.of(context).pop(true),
              backgroundColor: LightColor.secondaryColor,
              foregroundColor: LightColor.inverseTextColor,
              minHeight: AppDimens.sizeX52,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX10),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Choose another date & slot',
              onPressed: () => Navigator.of(context).pop(false),
              backgroundColor: LightColor.cardColor,
              foregroundColor: LightColor.primaryTextColor,
              minHeight: AppDimens.sizeX52,
            ),
          ),
        ],
      ),
    );
  }
}
