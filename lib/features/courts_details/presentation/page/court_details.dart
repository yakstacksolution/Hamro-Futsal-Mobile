import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_amenities.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_booking_policies_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_hosted_by_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_intro_widget.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_reviews_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_rules_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_time_slot.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/details_image_gallery.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';

class CourtDetailModel {
  final int? venueId;
  final String name;
  final String location;
  final String address;
  final String price;
  final double rating;
  final int reviewCount;
  final List<String> images;
  final bool isOpen;
  final String distance;
  final List<String> features;
  final String description;
  final String hostedByName;
  final String hostedByAvatar;
  final String hostedSince;
  final int hostedCourts;
  final double responseRate;
  final List<String> policies;
  final List<String> rules;
  final List<ReviewModel> reviews;
  final String openTime;
  final String closeTime;
  final String courtType;
  final String surfaceType;
  final int maxPlayers;

  const CourtDetailModel({
    this.venueId,
    required this.name,
    required this.location,
    required this.address,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.images,
    required this.isOpen,
    required this.distance,
    required this.features,
    required this.description,
    required this.hostedByName,
    required this.hostedByAvatar,
    required this.hostedSince,
    required this.hostedCourts,
    required this.responseRate,
    required this.policies,
    required this.rules,
    required this.reviews,
    required this.openTime,
    required this.closeTime,
    required this.courtType,
    required this.surfaceType,
    required this.maxPlayers,
  });
}

class ReviewModel {
  final String name;
  final String avatar;
  final double rating;
  final String date;
  final String comment;

  const ReviewModel({
    required this.name,
    required this.avatar,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

class CourtDetailPage extends StatefulWidget {
  final CourtDetailModel? court;

  const CourtDetailPage({super.key, this.court});

  @override
  State<CourtDetailPage> createState() => _CourtDetailPageState();
}

class _CourtDetailPageState extends State<CourtDetailPage>
    with TickerProviderStateMixin {
  late final AnimationController _bottomBarController;
  late final Animation<Offset> _bottomBarSlide;

  int _selectedDateIndex = 0;
  int _selectedSlotIndex = -1;

  late final CourtDetailModel _court;

  late final List<DateTime> _dates;

  final List<List<TimeSlotModel>> _timeSlotsByDate = [];

  @override
  void initState() {
    super.initState();

    _court =
        widget.court ??
        CourtDetailModel(
          name: 'Galaxy Futsal Arena Galaxy Futsal  ',
          location: 'Baneshwor, Kathmandu',
          address: 'Galaxy Complex, New Baneshwor Road, Kathmandu 44600',
          price: 'Rs 1,200',
          rating: 4.8,
          reviewCount: 234,
          images: [
            'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
            'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800',
            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
            'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800',
          ],
          isOpen: true,
          distance: '1.2 km',
          features: [
            'Indoor',
            'Floodlight',
            'Parking',
            'Changing Room',
            'Cafeteria',
            'First Aid',
          ],
          description:
              'Galaxy Futsal Arena is a premium indoor futsal facility located in the heart of Kathmandu. Our state-of-the-art synthetic turf provides the perfect playing surface for both casual and competitive matches. The arena features professional-grade floodlighting, comfortable changing rooms, and a fully stocked cafeteria. Whether you\'re organizing a friendly match or a tournament, Galaxy Futsal Arena delivers an exceptional experience every time.',
          hostedByName: 'Rajesh Hamal',
          hostedByAvatar: '',
          hostedSince: 'Jan 2021',
          hostedCourts: 3,
          responseRate: 98,
          policies: [
            'Free cancellation up to 24 hours before the booking',
            'Full refund for weather-related cancellations',
            'Shoes must be non-marking indoor type',
            'Maximum 14 players per session',
            'Equipment rental available at the venue',
          ],
          rules: [
            'No metal studs or outdoor shoes allowed',
            'Players must wear shin guards',
            'No smoking inside the arena premises',
            'Respect other players and staff',
            'Report any damage to the facility immediately',
            'No food or drinks on the playing surface',
          ],
          reviews: const [
            ReviewModel(
              name: 'Suman Thapa',
              avatar: '',
              rating: 5.0,
              date: '2 days ago',
              comment:
                  'Amazing facility! The turf quality is top-notch and the lighting is perfect for evening games. Highly recommended!',
            ),
            ReviewModel(
              name: 'Anita Gurung',
              avatar: '',
              rating: 4.5,
              date: '1 week ago',
              comment:
                  'Great place to play. Clean changing rooms and friendly staff. Only wish they had more parking space.',
            ),
            ReviewModel(
              name: 'Bikram Shah',
              avatar: '',
              rating: 5.0,
              date: '2 weeks ago',
              comment:
                  'Best futsal in Kathmandu. Period. We play here every weekend and it never disappoints.',
            ),
          ],
          openTime: '6:00 AM',
          closeTime: '10:00 PM',
          courtType: 'Indoor',
          surfaceType: 'Synthetic Turf',
          maxPlayers: 14,
        );

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

    for (int d = 0; d < 14; d++) {
      _timeSlotsByDate.add([
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
      ]);
    }

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _bottomBarController.forward();
    });
  }

  @override
  void dispose() {
    _bottomBarController.dispose();
    super.dispose();
  }

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

  Widget _buildBottomBar() {
    final hasSelection = _selectedSlotIndex >= 0;
    final selectedTime = hasSelection
        ? _timeSlotsByDate[_selectedDateIndex][_selectedSlotIndex].time
        : null;
    final selectedDate = _dates[_selectedDateIndex];
    final selectedLabel = hasSelection
        ? '${_dayName(selectedDate)}, ${selectedDate.day} ${_monthName(selectedDate)} · $selectedTime'
        : 'Select a time slot to continue';

    return SlideTransition(
      position: _bottomBarSlide,
      child: Container(
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: AppDimens.sizeX28,
              offset: const Offset(0, AppDimens.sizeX10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: AppUtils().getPadding(
                          left: AppDimens.paddingX6,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                _court.price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FutsalTheme.getTextTheme(context)
                                    .headingSmall
                                    ?.copyWith(
                                      color: LightColor.primaryTextColor,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.sizeX4),
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
                      const SizedBox(height: AppDimens.sizeX4),

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
                          children: [
                            Icon(
                              hasSelection
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                              size: AppDimens.sizeX12,
                              color: hasSelection
                                  ? LightColor.secondaryColor
                                  : LightColor.hintTextColor,
                            ),
                            const SizedBox(width: AppDimens.sizeX4),
                            Flexible(
                              child: Text(
                                selectedLabel,
                                overflow: TextOverflow.ellipsis,
                                style: FutsalTheme.getTextTheme(context)
                                    .bodySubTitle
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
                      const SizedBox(height: AppDimens.sizeX2),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX10),
                Expanded(
                  child: GestureDetector(
                    onTap: hasSelection
                        ? () {
                            HapticFeedback.mediumImpact();
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      height: AppDimens.sizeX46,
                      decoration: BoxDecoration(
                        gradient: hasSelection
                            ? const LinearGradient(
                                colors: [
                                  LightColor.secondaryColor,
                                  LightColor.secondaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: hasSelection ? null : LightColor.dividerColor,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusX10,
                        ),
                        boxShadow: hasSelection
                            ? [
                                BoxShadow(
                                  color: LightColor.secondaryColor.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: AppDimens.sizeX20,
                                  offset: const Offset(0, AppDimens.sizeX8),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              hasSelection ? 'Book Now' : 'Select Slot',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FutsalTheme.getTextTheme(context)
                                  .bodyTextMedium
                                  ?.copyWith(
                                    color: hasSelection
                                        ? LightColor.inverseTextColor
                                        : LightColor.hintTextColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: LightColor.background,
        body: SafeArea(
          top: false,
          bottom: true,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: DetailsImageGallery(images: [_court.images.first]),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: LightColor.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppDimens.radiusX28),
                        ),
                      ),
                      transform: Matrix4.translationValues(
                        0,
                        -AppDimens.sizeX24,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              margin: AppUtils().getMargin(
                                top: AppDimens.marginX12,
                                bottom: AppDimens.marginX4,
                              ),
                              width: AppDimens.sizeX40,
                              height: AppDimens.sizeX4,
                              decoration: BoxDecoration(
                                color: LightColor.dividerColor,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                          CourtIntroWidget(court: _court),
                          CourtAmenitiesSection(features: _court.features),
                          CourtTimeSlotSection(
                            dates: _dates,
                            timeSlotsByDate: _timeSlotsByDate,
                            openTime: _court.openTime,
                            closeTime: _court.closeTime,
                            initialDateIndex: _selectedDateIndex,
                            initialSlotIndex: _selectedSlotIndex,
                            onSelectionChanged: (dateIndex, slotIndex) {
                              setState(() {
                                _selectedDateIndex = dateIndex;
                                _selectedSlotIndex = slotIndex;
                              });
                            },
                          ),
                          CourtHostedBySection(
                            hostName: _court.hostedByName,
                            hostSince: _court.hostedSince,
                            hostedCourts: _court.hostedCourts,
                            responseRate: _court.responseRate,
                            rating: _court.rating,
                          ),
                          CourtBookingPoliciesSection(
                            policies: _court.policies,
                          ),
                          CourtRulesSection(rules: _court.rules),
                          CourtReviewsSection(
                            rating: _court.rating,
                            reviewCount: _court.reviewCount,
                            reviews: _court.reviews
                                .map(
                                  (r) => CourtReviewItem(
                                    name: r.name,
                                    date: r.date,
                                    comment: r.comment,
                                    rating: r.rating,
                                  ),
                                )
                                .toList(),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomBar(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
