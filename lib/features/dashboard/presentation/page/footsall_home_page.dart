import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';

class FootsallHomePage extends StatelessWidget {
  const FootsallHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CourtsListScreen();
  }
}

class CourtsListScreen extends StatefulWidget {
  const CourtsListScreen({super.key});

  @override
  State<CourtsListScreen> createState() => _CourtsListScreenState();
}

class _CourtsListScreenState extends State<CourtsListScreen>
    with SingleTickerProviderStateMixin {
  int _selectedFilter = 0;
  int _selectedNav = 0;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  final List<String> _filters = [
    'All',
    'Nearby',
    'Indoor',
    'Outdoor',
    'Open Now',
    'Top Rated',
  ];

  final List<CourtModel> courts = [
    CourtModel(
      name: 'Goal Arena Futsal',
      location: 'Baneshwor, Kathmandu',
      price: 'Rs. 1,800',
      rating: 4.8,
      reviewCount: 128,
      image:
          'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
      isOpen: true,
      distance: '1.2 km',
      features: ['Indoor', 'Parking', 'Lights'],
    ),
    CourtModel(
      name: 'Urban Kick Center',
      location: 'Lalitpur, Jawalakhel',
      price: 'Rs. 2,000',
      rating: 4.6,
      reviewCount: 94,
      image:
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80',
      isOpen: true,
      distance: '2.8 km',
      features: ['Turf', 'Shower', 'Cafe'],
    ),
    CourtModel(
      name: 'Champion 5A Side',
      location: 'Koteshwor, Kathmandu',
      price: 'Rs. 1,500',
      rating: 4.5,
      reviewCount: 76,
      image:
          'https://images.unsplash.com/photo-1486286701208-1d58e9338013?auto=format&fit=crop&w=1200&q=80',
      isOpen: false,
      distance: '3.5 km',
      features: ['Outdoor', 'Training', 'Parking'],
    ),
    CourtModel(
      name: 'Royal Futsal Hub',
      location: 'Bhaktapur',
      price: 'Rs. 1,700',
      rating: 4.7,
      reviewCount: 111,
      image:
          'https://images.unsplash.com/photo-1552667466-07770ae110d0?auto=format&fit=crop&w=1200&q=80',
      isOpen: true,
      distance: '5.1 km',
      features: ['Indoor', 'Cafe', 'Events'],
    ),
  ];

  static const _green = Color(0xFF0D9E5C);
  static const _greenLight = Color(0xFFE8F7EF);
  static const _bg = Color(0xFFF5F7FA);
  static const _textPrimary = Color(0xFF0F1923);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE8ECF0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return FadeTransition(
      opacity: _fadeIn,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // SliverToBoxAdapter(
          //   child: Padding(
          //     padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          //     child: Row(
          //       children: [
          //         const Text(
          //           'Available Courts',
          //           style: TextStyle(
          //             color: _textPrimary,
          //             fontSize: 20,
          //             fontWeight: FontWeight.w800,
          //             letterSpacing: -0.3,
          //           ),
          //         ),
          //         const Spacer(),
          //         Text(
          //           '${courts.length} found',
          //           style: const TextStyle(
          //             color: _textSecondary,
          //             fontSize: 13,
          //             fontWeight: FontWeight.w500,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SliverToBoxAdapter(child: SizedBox(height: 6)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList.builder(
              itemCount: courts.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + index * 120),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Transform.translate(
                    offset: Offset(0, 30 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CourtCard(court: courts[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    // bottomNavigationBar: _buildBottomNav(),
  }

  Widget _buildHeader() {
    return Container(
      height: 230,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D9E5C), Color(0xFF0B7A47)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            right: -50,
            top: -30,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: Container(
              height: 160,
              width: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'R',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good evening 👋',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            'Rahul Shrestha',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Find Your\nPerfect Court',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white70,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Kathmandu Valley',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white.withOpacity(0.6),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      Icons.home_rounded,
      Icons.explore_rounded,
      Icons.calendar_today_rounded,
      Icons.person_outline_rounded,
    ];
    final labels = ['Home', 'Explore', 'Bookings', 'Profile'];

    return Container(
      padding: const EdgeInsets.only(bottom: 12, top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (i) => GestureDetector(
            onTap: () => setState(() => _selectedNav = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedNav == i ? _greenLight : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    items[i],
                    color: _selectedNav == i ? _green : _textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: _selectedNav == i ? _green : _textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CourtCard extends StatefulWidget {
  final CourtModel court;
  const CourtCard({super.key, required this.court});

  @override
  State<CourtCard> createState() => _CourtCardState();
}

class _CourtCardState extends State<CourtCard> {
  bool _saved = false;

  static const _green = Color(0xFF0D9E5C);
  static const _greenLight = Color(0xFFE8F7EF);
  static const _textPrimary = Color(0xFF0F1923);
  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE8ECF0);
  static const _chipBg = Color(0xFFF3F5F7);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // context.goNamed(AppRouterParams.courtDetails.name);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CourtDetailPage()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ────────────────────────────────────────────────
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(26),
              ),
              child: SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(widget.court.image, fit: BoxFit.cover),

                    // Bookmark — top right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _saved = !_saved),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              height: 36,
                              width: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.85),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              child: Icon(
                                _saved
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: _saved ? _green : _textSecondary,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Details ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Open/Closed row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.court.name,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ratingWidget(),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Location + distance
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: _textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.court.location,
                        style: const TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: _textSecondary.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.court.distance,
                        style: TextStyle(
                          color: _textSecondary.withOpacity(0.8),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Feature chips
                  // Wrap(
                  //   spacing: 6,
                  //   runSpacing: 6,
                  //   children: widget.court.features
                  //       .map(
                  //         (f) => Container(
                  //           padding: const EdgeInsets.symmetric(
                  //             horizontal: 10,
                  //             vertical: 5,
                  //           ),
                  //           decoration: BoxDecoration(
                  //             color: _chipBg,
                  //             borderRadius: BorderRadius.circular(9),
                  //             border: Border.all(color: _border, width: 1),
                  //           ),
                  //           child: Text(
                  //             f,
                  //             style: const TextStyle(
                  //               color: _textSecondary,
                  //               fontSize: 11.5,
                  //               fontWeight: FontWeight.w600,
                  //             ),
                  //           ),
                  //         ),
                  //       )
                  //       .toList(),
                  // ),
                  // const SizedBox(height: 14),
                  // const Divider(color: _border, thickness: 1, height: 1),
                  // const SizedBox(height: 12),

                  // Price only
                  Row(
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.court.price,
                            style: const TextStyle(
                              color: _green,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '/ hour',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      _StatusPill(isOpen: widget.court.isOpen),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ratingWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: _green, size: 15),
              const SizedBox(width: 4),
              Text(
                widget.court.rating.toString(),
                style: const TextStyle(
                  color: _green,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${widget.court.reviewCount})',
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Pill
// ─────────────────────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final bool isOpen;
  const _StatusPill({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isOpen
                  ? const Color(0xFF0D9E5C).withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 7,
                width: 7,
                decoration: BoxDecoration(
                  color: isOpen ? const Color(0xFF0D9E5C) : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOpen ? 'Open Now' : 'Closed',
                style: TextStyle(
                  color: isOpen ? const Color(0xFF0D9E5C) : Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Court Model
// ─────────────────────────────────────────────────────────────────────────────
class CourtModel {
  final String name;
  final String location;
  final String price;
  final double rating;
  final int reviewCount;
  final String image;
  final bool isOpen;
  final String distance;
  final List<String> features;

  CourtModel({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.image,
    required this.isOpen,
    required this.distance,
    required this.features,
  });
}
