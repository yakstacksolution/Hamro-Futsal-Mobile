import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/features/courts_details/presentation/model/time_slot_model.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_amenities.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_booking_policies_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_hosted_by_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_intro_widget.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_reviews_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_rules_section.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/court_time_slot.dart';
import 'package:hamro_footsall/features/courts_details/presentation/widget/details_image_gallery.dart';
import 'package:hamro_footsall/features/vendor/presentation/pages/vendor_onboarding_page.dart';

class CourtDetailModel {
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
  late final PageController _imagePageController;
  late final AnimationController _bottomBarController;
  late final Animation<Offset> _bottomBarSlide;

 
  int _selectedDateIndex = 0;
  int _selectedSlotIndex = -1;
  bool _showAllDescription = false;

  // ── Sample Data ──
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

    _imagePageController = PageController();

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
    _imagePageController.dispose();
    _bottomBarController.dispose();
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

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
 
  Widget _buildDescription() {
    const maxChars = 180;
    final isLong = _court.description.length > maxChars;
    final shortDescription = isLong
        ? '${_court.description.substring(0, maxChars)}...'
        : _court.description;

    return _sectionWrapper(
      title: 'About This Court',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            firstChild: Text(
              shortDescription,
              style: const TextStyle(
                color: DS.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.65,
              ),
            ),
            secondChild: Text(
              _court.description,
              style: const TextStyle(
                color: DS.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.65,
              ),
            ),
            crossFadeState: _showAllDescription
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          if (isLong) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () =>
                  setState(() => _showAllDescription = !_showAllDescription),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _showAllDescription ? 'Show less' : 'Read more',
                    style: const TextStyle(
                      color: DS.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showAllDescription
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: DS.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DS.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          border: Border.all(color: DS.border.withOpacity(0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _court.price,
                              style: const TextStyle(
                                color: DS.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 3),
                              child: Text(
                                '/ hour',
                                style: TextStyle(
                                  color: DS.textTertiary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: hasSelection
                              ? DS.primaryLight
                              : DS.borderLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasSelection
                                  ? Icons.check_circle_rounded
                                  : Icons.schedule_rounded,
                              size: 12,
                              color: hasSelection
                                  ? DS.primary
                                  : DS.textTertiary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                selectedLabel,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: hasSelection
                                      ? DS.primary
                                      : DS.textTertiary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: hasSelection
                        ? () {
                            HapticFeedback.mediumImpact();
                            // context.goNamed(
                            //   AppRouterParams.vendorOnboarding.name,
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VendorOnboardingPage(),
                              ),
                            );

                            // Handle booking
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: hasSelection ? DS.primaryGradient : null,
                        color: hasSelection ? null : DS.border,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: hasSelection ? DS.shadowPrimary : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hasSelection ? 'Book Now' : 'Select Slot',
                            style: TextStyle(
                              color: hasSelection
                                  ? Colors.white
                                  : DS.textTertiary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
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

  Widget _actionNavButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 52,
        decoration: BoxDecoration(
          color: DS.borderLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DS.border.withOpacity(0.8)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // SECTION WRAPPER
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _sectionWrapper({
    required String title,
    required Widget child,
    Widget? trailing,
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (iconColor ?? DS.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: iconColor ?? DS.primary),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: DS.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
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
        backgroundColor: DS.background,
        body: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: DetailsImageGallery()),

                  SliverToBoxAdapter(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: DS.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      transform: Matrix4.translationValues(0, -24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 4),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: DS.border,
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),

                          CourtIntroWidget(court: _court),

                          // _buildHeaderInfo(),
                          CourtAmenitiesSection(features: _court.features),

                          // _buildDescription(),

                          // // Divider
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   child: Divider(color: DS.divider, height: 40),
                          // ),
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

                          // Bottom spacing for the bar
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 100,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Bottom booking bar ──
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

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DESIGN TOKENS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class DS {
  DS._();

  static const Color primary = Color(0xFF0D9E5C);
  static const Color primaryDark = Color(0xFF087A45);
  static const Color primaryLight = Color(0xFFE8F8F0);
  static const Color primarySurface = Color(0xFFF0FDF4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F9FC);
  static const Color textPrimary = Color(0xFF0F1923);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color divider = Color(0xFFF0F2F5);
  static const Color orange = Color(0xFFF59E0B);
  static const Color orangeLight = Color(0xFFFFF7ED);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color purple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFFAF5FF);
  static const Color yellow = Color(0xFFFBBF24);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D9E5C), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF111827), Color(0xFF1F2937)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: primary.withOpacity(0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
