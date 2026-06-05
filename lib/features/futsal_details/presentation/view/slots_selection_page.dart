import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/scroll_behavior.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_court_item_model.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/compact_date_time_selector.dart';
import 'package:hamro_footsall/features/futsal_details/presentation/widgets/court_slot_card.dart';

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
  final ValueNotifier<int> _selectedDateIndexNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> _selectedSlotIndexNotifier = ValueNotifier<int>(-1);

  late final List<DateTime> _dates;
  final List<List<TimeSlotModel>> _timeSlotsByDate = [];
  late final List<VenueCourtItemModel> _courts;

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

    _dates = List.generate(14, (i) => DateTime.now().add(Duration(days: i)));

    _timeSlotsByDate.addAll(
      List.generate(
        14,
        (d) => [
          TimeSlotModel(time: '6:00 AM', isAvailable: d != 0),
          const TimeSlotModel(time: '7:00 AM'),
          TimeSlotModel(time: '8:00 AM', isAvailable: d % 2 == 0),
          const TimeSlotModel(time: '9:00 AM'),
          TimeSlotModel(time: '10:00 AM', isAvailable: d % 3 != 0),
          const TimeSlotModel(time: '11:00 AM', isAvailable: false),
          const TimeSlotModel(time: '12:00 PM', isAvailable: false),
          const TimeSlotModel(time: '1:00 PM'),
          TimeSlotModel(time: '2:00 PM', isAvailable: d != 1),
          const TimeSlotModel(time: '3:00 PM'),
          const TimeSlotModel(time: '4:00 PM'),
          TimeSlotModel(time: '5:00 PM', isAvailable: d % 2 != 0),
          const TimeSlotModel(time: '6:00 PM'),
          TimeSlotModel(time: '7:00 PM', isAvailable: d != 2),
          const TimeSlotModel(time: '8:00 PM'),
          const TimeSlotModel(time: '9:00 PM'),
        ],
      ),
    );

    // TODO: Replace with courts fetched from the API for this venue.
    final String venueImage = widget.court.images.isNotEmpty
        ? widget.court.images.first
        : '';
    _courts = <VenueCourtItemModel>[
      VenueCourtItemModel(
        name: 'Court A',
        image: venueImage,
        maxPlayers: widget.court.maxPlayers > 0 ? widget.court.maxPlayers : 10,
        matchType: '5A Side',
        courtType: widget.court.courtType,
        weekendSurcharge: 200,
        priceList: const <CourtPriceRule>[
          CourtPriceRule(
            label: 'Morning',
            timeRange: '6 AM - 12 PM',
            startHour: 6,
            endHour: 12,
            price: 1000,
          ),
          CourtPriceRule(
            label: 'Day',
            timeRange: '12 PM - 5 PM',
            startHour: 12,
            endHour: 17,
            price: 1200,
          ),
          CourtPriceRule(
            label: 'Evening',
            timeRange: '5 PM - 10 PM',
            startHour: 17,
            endHour: 22,
            price: 1500,
          ),
        ],
      ),
      VenueCourtItemModel(
        name: 'Court B',
        image: widget.court.images.length > 1
            ? widget.court.images[1]
            : venueImage,
        maxPlayers: 14,
        matchType: '7A Side',
        courtType: widget.court.courtType,
        weekendSurcharge: 300,
        priceList: const <CourtPriceRule>[
          CourtPriceRule(
            label: 'Morning',
            timeRange: '6 AM - 12 PM',
            startHour: 6,
            endHour: 12,
            price: 1400,
          ),
          CourtPriceRule(
            label: 'Day',
            timeRange: '12 PM - 5 PM',
            startHour: 12,
            endHour: 17,
            price: 1600,
          ),
          CourtPriceRule(
            label: 'Evening',
            timeRange: '5 PM - 10 PM',
            startHour: 17,
            endHour: 22,
            price: 2000,
          ),
        ],
      ),
      VenueCourtItemModel(
        name: 'Court C',
        image: widget.court.images.length > 2
            ? widget.court.images[2]
            : venueImage,
        maxPlayers: 10,
        matchType: '5A Side',
        courtType: widget.court.courtType,
        weekendSurcharge: 200,
        priceList: const <CourtPriceRule>[
          CourtPriceRule(
            label: 'Morning',
            timeRange: '6 AM - 12 PM',
            startHour: 6,
            endHour: 12,
            price: 900,
          ),
          CourtPriceRule(
            label: 'Day',
            timeRange: '12 PM - 5 PM',
            startHour: 12,
            endHour: 17,
            price: 1100,
          ),
          CourtPriceRule(
            label: 'Evening',
            timeRange: '5 PM - 10 PM',
            startHour: 17,
            endHour: 22,
            price: 1400,
          ),
        ],
      ),
    ];

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _bottomBarController.forward();
    });
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    _selectedDateIndexNotifier.dispose();
    _selectedSlotIndexNotifier.dispose();
    super.dispose();
  }

  // ── Helpers ──
  String _dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _monthName(DateTime date) {
    const months = [
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
    return months[date.month - 1];
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
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.05),
              blurRadius: AppDimens.sizeX14,
              offset: const Offset(0, AppDimens.sizeX4),
            ),
          ],
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: _selectedDateIndexNotifier,
          builder: (BuildContext context, int dateIndex, _) {
            return ValueListenableBuilder<int>(
              valueListenable: _selectedSlotIndexNotifier,
              builder: (BuildContext context, int slotIndex, __) {
                return CompactDateTimeSelector(
                  dates: _dates,
                  timeSlots: _timeSlotsByDate[dateIndex],
                  selectedDateIndex: dateIndex,
                  selectedSlotIndex: slotIndex,
                  onDateSelected: (int index) {
                    _selectedDateIndexNotifier.value = index;
                    _selectedSlotIndexNotifier.value = -1;
                  },
                  onSlotSelected: (int index) {
                    _selectedSlotIndexNotifier.value = index;
                  },
                );
              },
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Available Courts',
                  style: FutsalTheme.getTextTheme(context).bodyTextLarge
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              Container(
                padding: AppUtils().getPadding(
                  horizontal: AppDimens.paddingX8,
                  vertical: AppDimens.paddingX2,
                ),
                decoration: BoxDecoration(
                  color: LightColor.secondarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX50),
                ),
                child: Text(
                  '${_courts.length} courts',
                  style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                      ?.copyWith(
                        color: LightColor.secondaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),
          ValueListenableBuilder<int>(
            valueListenable: _selectedDateIndexNotifier,
            builder: (BuildContext context, int dateIndex, _) {
              return ValueListenableBuilder<int>(
                valueListenable: _selectedSlotIndexNotifier,
                builder: (BuildContext context, int slotIndex, __) {
                  final DateTime selectedDate = _dates[dateIndex];
                  final bool hasSlot = slotIndex >= 0;
                  final String? selectedTime = hasSlot
                      ? _timeSlotsByDate[dateIndex][slotIndex].time
                      : null;
                  final String? slotLabel = hasSlot
                      ? '${_dayName(selectedDate)}, ${selectedDate.day} ${_monthName(selectedDate)} · $selectedTime'
                      : null;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _courts.length,
                    itemBuilder: (BuildContext context, int i) {
                      return CourtSlotCard(
                        court: _courts[i],
                        selectedDate: selectedDate,
                        selectedTime: selectedTime,
                        slotLabel: slotLabel,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SlideTransition(
      position: _bottomBarSlide,
      child: ValueListenableBuilder<int>(
        valueListenable: _selectedDateIndexNotifier,
        builder: (BuildContext context, int selectedDateIndex, _) {
          return ValueListenableBuilder<int>(
            valueListenable: _selectedSlotIndexNotifier,
            builder: (BuildContext context, int selectedSlotIndex, __) {
              final bool hasSelection = selectedSlotIndex >= 0;
              final String? selectedTime = hasSelection
                  ? _timeSlotsByDate[selectedDateIndex][selectedSlotIndex].time
                  : null;
              final DateTime selectedDate = _dates[selectedDateIndex];
              final String selectedLabel = hasSelection
                  ? '${_dayName(selectedDate)}, ${selectedDate.day} ${_monthName(selectedDate)} · $selectedTime'
                  : 'Select a time slot to continue';

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
                                    widget.court.price,
                                    style: FutsalTheme.getTextTheme(context)
                                        .headingSmall
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
                            SizedBox(height: AppDimens.sizeX4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: AppUtils().getPadding(
                                horizontal: AppDimens.paddingX10,
                                vertical: AppDimens.paddingX4,
                              ),
                              decoration: BoxDecoration(
                                color: hasSelection
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
                                    hasSelection
                                        ? Icons.check_circle_rounded
                                        : Icons.schedule_rounded,
                                    size: AppDimens.sizeX12,
                                    color: hasSelection
                                        ? LightColor.secondaryColor
                                        : LightColor.hintTextColor,
                                  ),
                                  SizedBox(width: AppDimens.sizeX4 + 1),
                                  Flexible(
                                    child: Text(
                                      selectedLabel,
                                      overflow: TextOverflow.ellipsis,
                                      style: FutsalTheme.getTextTheme(context)
                                          .bodyMiniSubTitle
                                          ?.copyWith(
                                            color: hasSelection
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
                      SizedBox(width: AppDimens.sizeX10),
                      Expanded(
                        child: GestureDetector(
                          onTap: hasSelection
                              ? () => HapticFeedback.mediumImpact()
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            height: AppDimens.sizeX46,
                            decoration: BoxDecoration(
                              gradient: hasSelection
                                  ? const LinearGradient(
                                      colors: <Color>[
                                        LightColor.secondaryColor,
                                        LightColor.secondaryDark,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: hasSelection
                                  ? null
                                  : LightColor.dividerColor,
                              borderRadius: BorderRadius.circular(
                                AppDimens.radiusX10,
                              ),
                              boxShadow: hasSelection
                                  ? <BoxShadow>[
                                      BoxShadow(
                                        color: LightColor.secondaryColor
                                            .withValues(alpha: 0.35),
                                        blurRadius: AppDimens.sizeX20,
                                        offset: const Offset(
                                          0,
                                          AppDimens.sizeX8,
                                        ),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                hasSelection ? 'Book Now' : 'Select Slot',
                                style: FutsalTheme.getTextTheme(context)
                                    .bodyTextLarge
                                    ?.copyWith(
                                      color: hasSelection
                                          ? LightColor.inverseTextColor
                                          : LightColor.hintTextColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
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
              _buildCourtsSection(),
              const SizedBox(height: AppDimens.sizeX20),
            ],
          ),
        ),

        bottomNavigationBar: SizedBox(height: 128, child: _buildBottomBar()),
      ),
    );
  }
}
