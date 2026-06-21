import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/scroll_behavior.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_recurrence.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_court_item_model.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/bloc/slots_selection/slots_selection_bloc.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/booking_options.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/compact_date_time_selector.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/court_slot_card.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/loading/available_courts_loading.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/loading/selection_time_loading.dart';

class SlotsSelectionPage extends StatefulWidget {
  const SlotsSelectionPage({super.key, required this.court});

  final CourtDetailModel court;

  @override
  State<SlotsSelectionPage> createState() => _SlotsSelectionPageState();
}

class _SlotsSelectionPageState extends State<SlotsSelectionPage>
    with TickerProviderStateMixin {
  late final AnimationController _bottomBarController;
  late final Animation<Offset> _bottomBarSlide;

  @override
  void initState() {
    super.initState();

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
  void dispose() {
    _bottomBarController.dispose();
    super.dispose();
  }

  Widget _buildBookingTypeSection() {
    return BlocBuilder<SlotsSelectionBloc, SlotsSelectionState>(
      builder: (BuildContext context, SlotsSelectionState state) {
        final VenueCourtItemModel? selectedCourt = state.selectedCourt;
        if (selectedCourt == null) return const SizedBox.shrink();

        return Padding(
          padding: AppUtils().getPadding(
            top: AppDimens.paddingX12,
            left: AppDimens.paddingX20,
            right: AppDimens.paddingX20,
          ),
          child: BookingTypeCard(
            mode: state.bookingMode,
            startDate: state.selectedDate,
            recurrence: state.recurrence,
            selectedTime: state.selectedTime,
            selectedCourt: selectedCourt,
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
          ),
        );
      },
    );
  }

  Widget _buildDateTimeSection() {
    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX12,
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
      ),
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX12),
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
                    title: 'Slots unavailable',
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
                    title: 'No slots found',
                    message: 'No time slots are available for this date.',
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
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX20,
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
      ),
      child: BlocBuilder<SlotsSelectionBloc, SlotsSelectionState>(
        builder: (BuildContext context, SlotsSelectionState state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Available Courts',
                      style: FutsalTheme.getTextTheme(context).bodyTextMedium
                          ?.copyWith(color: LightColor.primaryTextColor),
                    ),
                  ),
                  Container(
                    padding: AppUtils().getPadding(
                      horizontal: AppDimens.paddingX8,
                      vertical: AppDimens.paddingX2,
                    ),
                    decoration: BoxDecoration(
                      color: LightColor.secondarySoft,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    ),
                    child: Text(
                      state.courts.isEmpty
                          ? '0 courts'
                          : '${state.availableCourtCount}/${state.courts.length} available',
                      style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                          ?.copyWith(color: LightColor.secondaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX12),
              if (state.isLoading && state.courts.isEmpty)
                const AvailableCourtsLoading()
              else if (state.courts.isEmpty)
                _AvailabilityMessage(
                  title: 'No courts available',
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.courts.length,
                  itemBuilder: (BuildContext context, int i) {
                    return CourtSlotCard(
                      court: state.courts[i],
                      selectedDate: state.selectedDate,
                      selectedTime: state.selectedTime,
                      slotLabel: state.slotLabel,
                      recurringDates: state.isRecurring
                          ? state.sessionDates
                          : null,
                      selected: state.selectedCourtIndex == i,
                      onTap: state.courts[i].isAvailable
                          ? () {
                              HapticFeedback.selectionClick();
                              context.read<SlotsSelectionBloc>().add(
                                SelectSlotsCourtEvent(i),
                              );
                            }
                          : null,
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return SizedBox(
      height: 122,
      child: SlideTransition(
        position: _bottomBarSlide,
        child: BlocBuilder<SlotsSelectionBloc, SlotsSelectionState>(
          builder: (BuildContext context, SlotsSelectionState state) {
            final bool canBook =
                state.hasSlotSelection &&
                (state.selectedCourt?.isAvailable ?? false);

            return Container(
              padding: AppUtils().getPadding(all: AppDimens.paddingX12),
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
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: AppUtils().getPadding(
                              left: AppDimens.paddingX6,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  state.priceText,
                                  style: FutsalTheme.getTextTheme(context)
                                      .bodyTextLarge
                                      ?.copyWith(
                                        color: LightColor.primaryTextColor,
                                      ),
                                ),
                                SizedBox(width: AppDimens.sizeX4),
                                Flexible(
                                  child: Padding(
                                    padding: AppUtils().getPadding(
                                      bottom: AppDimens.paddingX2,
                                    ),
                                    child: Text(
                                      state.priceUnit,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: FutsalTheme.getTextTheme(context)
                                          .bodyTextSmall
                                          ?.copyWith(
                                            color: LightColor.hintTextColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppDimens.sizeX4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: AppUtils().getPadding(
                              horizontal: AppDimens.paddingX10,
                              vertical: AppDimens.paddingX2,
                            ),
                            decoration: BoxDecoration(
                              color: canBook
                                  ? LightColor.secondarySoft
                                  : LightColor.inputFillColor,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusX50,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  canBook
                                      ? Icons.check_circle_rounded
                                      : Icons.schedule_rounded,
                                  size: AppDimens.sizeX12,
                                  color: canBook
                                      ? LightColor.secondaryColor
                                      : LightColor.hintTextColor,
                                ),
                                SizedBox(width: AppDimens.sizeX4 + 1),
                                Flexible(
                                  child: Text(
                                    state.selectedLabel,
                                    overflow: TextOverflow.ellipsis,
                                    style: FutsalTheme.getTextTheme(context)
                                        .bodyMiniSubTitle
                                        ?.copyWith(
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
                          SizedBox(height: AppDimens.sizeX2),
                        ],
                      ),
                    ),
                    SizedBox(width: AppDimens.sizeX12),
                    SizedBox(
                      width: AppDimens.sizeX116,
                      height: AppDimens.sizeX42,
                      child: CustomButton(
                        text: state.buttonText,
                        onPressed: canBook
                            ? () => HapticFeedback.mediumImpact()
                            : null,
                        backgroundColor: canBook
                            ? LightColor.secondaryColor
                            : LightColor.dividerColor,
                        foregroundColor: canBook
                            ? LightColor.inverseTextColor
                            : LightColor.hintTextColor,
                        minWidth: AppDimens.sizeX120,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: AppDimens.sizeX18,
              color: LightColor.primaryTextColor,
            ),
          ),
          title: Text(
            'Select Date & Time',
            style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildDateTimeSection(),
              _buildBookingTypeSection(),
              _buildCourtsSection(),
              const SizedBox(height: AppDimens.sizeX20),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
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
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.greyBorderColor.withValues(alpha: 1.2),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
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
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
