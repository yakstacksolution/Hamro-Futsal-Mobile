import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/footsall_court_details_page.dart';

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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:ui';

// class FootsallHomePage extends StatelessWidget {
//   const FootsallHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const CourtsListScreen();
//   }
// }

// class CourtsListScreen extends StatefulWidget {
//   const CourtsListScreen({super.key});

//   @override
//   State<CourtsListScreen> createState() => _CourtsListScreenState();
// }

// class _CourtsListScreenState extends State<CourtsListScreen>
//     with SingleTickerProviderStateMixin {
//   int _selectedFilter = 0;
//   int _selectedNav = 0;
//   late AnimationController _animController;
//   late Animation<double> _fadeIn;

//   final List<String> _filters = [
//     'All',
//     'Nearby',
//     'Indoor',
//     'Outdoor',
//     'Open Now',
//     'Top Rated',
//   ];

//   final List<CourtModel> courts = [
//     CourtModel(
//       name: 'Goal Arena Futsal',
//       location: 'Baneshwor, Kathmandu',
//       price: 'Rs. 1,800',
//       rating: 4.8,
//       reviewCount: 128,
//       image:
//           'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
//       isOpen: true,
//       distance: '1.2 km',
//       features: ['Indoor', 'Parking', 'Lights'],
//     ),
//     CourtModel(
//       name: 'Urban Kick Center',
//       location: 'Lalitpur, Jawalakhel',
//       price: 'Rs. 2,000',
//       rating: 4.6,
//       reviewCount: 94,
//       image:
//           'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80',
//       isOpen: true,
//       distance: '2.8 km',
//       features: ['Turf', 'Shower', 'Cafe'],
//     ),
//     CourtModel(
//       name: 'Champion 5A Side',
//       location: 'Koteshwor, Kathmandu',
//       price: 'Rs. 1,500',
//       rating: 4.5,
//       reviewCount: 76,
//       image:
//           'https://images.unsplash.com/photo-1486286701208-1d58e9338013?auto=format&fit=crop&w=1200&q=80',
//       isOpen: false,
//       distance: '3.5 km',
//       features: ['Outdoor', 'Training', 'Parking'],
//     ),
//     CourtModel(
//       name: 'Royal Futsal Hub',
//       location: 'Bhaktapur',
//       price: 'Rs. 1,700',
//       rating: 4.7,
//       reviewCount: 111,
//       image:
//           'https://images.unsplash.com/photo-1552667466-07770ae110d0?auto=format&fit=crop&w=1200&q=80',
//       isOpen: true,
//       distance: '5.1 km',
//       features: ['Indoor', 'Cafe', 'Events'],
//     ),
//   ];

//   static const _green = Color(0xFF0D9E5C);
//   static const _greenLight = Color(0xFFE8F7EF);
//   static const _bg = Color(0xFFF5F7FA);
//   static const _textPrimary = Color(0xFF0F1923);
//   static const _textSecondary = Color(0xFF6B7280);
//   static const _border = Color(0xFFE8ECF0);

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
//     return Scaffold(
//       backgroundColor: _bg,
//       extendBody: true,
//       body: FadeTransition(
//         opacity: _fadeIn,
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             // SliverToBoxAdapter(child: _buildHeader()),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
//                 child: Column(
//                   children: [
//                     _buildSearchBar(),
//                     const SizedBox(height: 14),
//                     _buildFilterRow(),
//                   ],
//                 ),
//               ),
//             ),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
//                 child: Row(
//                   children: [
//                     const Text(
//                       'Available Courts',
//                       style: TextStyle(
//                         color: _textPrimary,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       '${courts.length} found',
//                       style: const TextStyle(
//                         color: _textSecondary,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
//               sliver: SliverList.builder(
//                 itemCount: courts.length,
//                 itemBuilder: (context, index) {
//                   return TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0, end: 1),
//                     duration: Duration(milliseconds: 500 + index * 120),
//                     curve: Curves.easeOutCubic,
//                     builder: (context, value, child) => Transform.translate(
//                       offset: Offset(0, 30 * (1 - value)),
//                       child: Opacity(opacity: value, child: child),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 20),
//                       child: CourtCard(court: courts[index]),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       height: 230,
//       child: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF0D9E5C), Color(0xFF0B7A47)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Positioned(
//             right: -50,
//             top: -30,
//             child: Container(
//               height: 200,
//               width: 200,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.08),
//               ),
//             ),
//           ),
//           Positioned(
//             left: -30,
//             bottom: -40,
//             child: Container(
//               height: 160,
//               width: 160,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white.withOpacity(0.06),
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         height: 44,
//                         width: 44,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.3),
//                           ),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             'R',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 18,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Good evening 👋',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.7),
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const Text(
//                             'Rahul Shrestha',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       Container(
//                         height: 44,
//                         width: 44,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.18),
//                           borderRadius: BorderRadius.circular(14),
//                           border: Border.all(
//                             color: Colors.white.withOpacity(0.25),
//                           ),
//                         ),
//                         child: const Icon(
//                           Icons.notifications_outlined,
//                           color: Colors.white,
//                           size: 22,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Find Your\nPerfect Court',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.w900,
//                       height: 1.1,
//                       letterSpacing: -0.8,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.location_on_rounded,
//                         color: Colors.white70,
//                         size: 15,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Kathmandu Valley',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.75),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         color: Colors.white.withOpacity(0.6),
//                         size: 18,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       height: 54,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: _border, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: TextField(
//         style: const TextStyle(color: _textPrimary, fontSize: 14),
//         decoration: InputDecoration(
//           hintText: 'Search courts, areas...',
//           hintStyle: TextStyle(
//             color: _textSecondary.withOpacity(0.6),
//             fontSize: 14,
//           ),
//           prefixIcon: const Icon(
//             Icons.search_rounded,
//             color: _textSecondary,
//             size: 22,
//           ),
//           suffixIcon: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF0D9E5C), Color(0xFF0B7A47)],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.tune_rounded,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(vertical: 18),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterRow() {
//     return SizedBox(
//       height: 40,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: _filters.length,
//         itemBuilder: (context, i) {
//           final selected = _selectedFilter == i;
//           return GestureDetector(
//             onTap: () => setState(() => _selectedFilter = i),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 220),
//               margin: const EdgeInsets.only(right: 10),
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
//               decoration: BoxDecoration(
//                 gradient: selected
//                     ? const LinearGradient(
//                         colors: [Color(0xFF0D9E5C), Color(0xFF0B7A47)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                     : null,
//                 color: selected ? null : Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: selected ? Colors.transparent : _border,
//                   width: 1.5,
//                 ),
//                 boxShadow: selected
//                     ? [
//                         BoxShadow(
//                           color: _green.withOpacity(0.3),
//                           blurRadius: 14,
//                           offset: const Offset(0, 5),
//                         ),
//                       ]
//                     : [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.04),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//               ),
//               child: Text(
//                 _filters[i],
//                 style: TextStyle(
//                   color: selected ? Colors.white : _textSecondary,
//                   fontWeight: FontWeight.w700,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomNav() {
//     final items = [
//       Icons.home_rounded,
//       Icons.explore_rounded,
//       Icons.calendar_today_rounded,
//       Icons.person_outline_rounded,
//     ];
//     final labels = ['Home', 'Explore', 'Bookings', 'Profile'];

//     return Container(
//       padding: const EdgeInsets.only(bottom: 12, top: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: _border, width: 1)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 20,
//             offset: const Offset(0, -6),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(
//           items.length,
//           (i) => GestureDetector(
//             onTap: () => setState(() => _selectedNav = i),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 220),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               decoration: BoxDecoration(
//                 color: _selectedNav == i ? _greenLight : Colors.transparent,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     items[i],
//                     color: _selectedNav == i ? _green : _textSecondary,
//                     size: 24,
//                   ),
//                   const SizedBox(height: 3),
//                   Text(
//                     labels[i],
//                     style: TextStyle(
//                       color: _selectedNav == i ? _green : _textSecondary,
//                       fontSize: 10.5,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Court Card
// // ─────────────────────────────────────────────────────────────────────────────
// class CourtCard extends StatefulWidget {
//   final CourtModel court;
//   const CourtCard({super.key, required this.court});

//   @override
//   State<CourtCard> createState() => _CourtCardState();
// }

// class _CourtCardState extends State<CourtCard> {
//   bool _saved = false;

//   static const _green = Color(0xFF0D9E5C);
//   static const _greenLight = Color(0xFFE8F7EF);
//   static const _textPrimary = Color(0xFF0F1923);
//   static const _textSecondary = Color(0xFF6B7280);
//   static const _border = Color(0xFFE8ECF0);
//   static const _chipBg = Color(0xFFF3F5F7);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(28),
//         border: Border.all(color: _border, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 24,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Image ────────────────────────────────────────────────
//           ClipRRect(
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
//             child: SizedBox(
//               height: 200,
//               child: Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.network(widget.court.image, fit: BoxFit.cover),
//                   Positioned.fill(
//                     child: DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.65),
//                           ],
//                           stops: const [0.4, 1.0],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     top: 14,
//                     left: 14,
//                     child: _StatusPill(isOpen: widget.court.isOpen),
//                   ),
//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: GestureDetector(
//                       onTap: () => setState(() => _saved = !_saved),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: BackdropFilter(
//                           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                           child: Container(
//                             height: 40,
//                             width: 40,
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.85),
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.6),
//                               ),
//                             ),
//                             child: Icon(
//                               _saved
//                                   ? Icons.bookmark_rounded
//                                   : Icons.bookmark_outline_rounded,
//                               color: _saved ? _green : _textSecondary,
//                               size: 20,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 14,
//                     left: 16,
//                     right: 16,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.court.name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w900,
//                             letterSpacing: -0.4,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_rounded,
//                               size: 13,
//                               color: Colors.white.withOpacity(0.7),
//                             ),
//                             const SizedBox(width: 3),
//                             Text(
//                               widget.court.location,
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.75),
//                                 fontSize: 12.5,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Container(
//                               width: 3,
//                               height: 3,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withOpacity(0.5),
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               widget.court.distance,
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.6),
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           // ── Details ──────────────────────────────────────────────
//           Padding(
//             padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 5,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _greenLight,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(
//                             Icons.star_rounded,
//                             color: _green,
//                             size: 15,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             widget.court.rating.toString(),
//                             style: const TextStyle(
//                               color: _green,
//                               fontSize: 13,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '(${widget.court.reviewCount})',
//                             style: const TextStyle(
//                               color: _textSecondary,
//                               fontSize: 11.5,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: SingleChildScrollView(
//                         scrollDirection: Axis.horizontal,
//                         physics: const BouncingScrollPhysics(),
//                         child: Row(
//                           children: widget.court.features
//                               .map(
//                                 (f) => Container(
//                                   margin: const EdgeInsets.only(right: 6),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 5,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: _chipBg,
//                                     borderRadius: BorderRadius.circular(9),
//                                     border: Border.all(
//                                       color: _border,
//                                       width: 1,
//                                     ),
//                                   ),
//                                   child: Text(
//                                     f,
//                                     style: const TextStyle(
//                                       color: _textSecondary,
//                                       fontSize: 11.5,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                               .toList(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 14),
//                 const Divider(color: _border, thickness: 1, height: 1),
//                 const SizedBox(height: 14),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.court.price,
//                           style: const TextStyle(
//                             color: _green,
//                             fontSize: 22,
//                             fontWeight: FontWeight.w900,
//                             letterSpacing: -0.5,
//                           ),
//                         ),
//                         const Text(
//                           'per hour',
//                           style: TextStyle(
//                             color: _textSecondary,
//                             fontSize: 11.5,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     GestureDetector(
//                       onTap: () {},
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 24,
//                           vertical: 13,
//                         ),
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFF0D9E5C), Color(0xFF0B7A47)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(16),
//                           boxShadow: [
//                             BoxShadow(
//                               color: _green.withOpacity(0.3),
//                               blurRadius: 16,
//                               offset: const Offset(0, 6),
//                             ),
//                           ],
//                         ),
//                         child: const Text(
//                           'Book Now',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14.5,
//                             letterSpacing: 0.2,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Status Pill
// // ─────────────────────────────────────────────────────────────────────────────
// class _StatusPill extends StatelessWidget {
//   final bool isOpen;
//   const _StatusPill({required this.isOpen});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(30),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.85),
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(
//               color: isOpen
//                   ? const Color(0xFF0D9E5C).withOpacity(0.3)
//                   : Colors.red.withOpacity(0.3),
//               width: 1,
//             ),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 height: 7,
//                 width: 7,
//                 decoration: BoxDecoration(
//                   color: isOpen ? const Color(0xFF0D9E5C) : Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 isOpen ? 'Open Now' : 'Closed',
//                 style: TextStyle(
//                   color: isOpen ? const Color(0xFF0D9E5C) : Colors.red,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Court Model
// // ─────────────────────────────────────────────────────────────────────────────
// class CourtModel {
//   final String name;
//   final String location;
//   final String price;
//   final double rating;
//   final int reviewCount;
//   final String image;
//   final bool isOpen;
//   final String distance;
//   final List<String> features;

//   CourtModel({
//     required this.name,
//     required this.location,
//     required this.price,
//     required this.rating,
//     required this.reviewCount,
//     required this.image,
//     required this.isOpen,
//     required this.distance,
//     required this.features,
//   });
// }
// import 'package:flutter/material.dart';
// import 'dart:ui';

// class FootsallHomePage extends StatelessWidget {
//   const FootsallHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const CourtsListScreen();
//   }
// }

// class CourtsListScreen extends StatefulWidget {
//   const CourtsListScreen({super.key});

//   @override
//   State<CourtsListScreen> createState() => _CourtsListScreenState();
// }

// class _CourtsListScreenState extends State<CourtsListScreen>
//     with SingleTickerProviderStateMixin {
//   int _selectedFilter = 0;
//   int _selectedNav = 0;
//   late AnimationController _animController;
//   late Animation<double> _fadeIn;

//   final List<String> _filters = [
//     'All',
//     'Nearby',
//     'Indoor',
//     'Outdoor',
//     'Open Now',
//     'Top Rated',
//   ];

//   final List<CourtModel> courts = [
//     CourtModel(
//       name: 'Goal Arena Futsal',
//       location: 'Baneshwor, Kathmandu',
//       price: 'Rs. 1,800',
//       rating: 4.8,
//       reviewCount: 128,
//       image:
//           'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
//       isOpen: true,
//       distance: '1.2 km',
//       features: ['Indoor', 'Parking', 'Lights'],
//       accentColor: const Color(0xFF00E676),
//     ),
//     CourtModel(
//       name: 'Urban Kick Center',
//       location: 'Lalitpur, Jawalakhel',
//       price: 'Rs. 2,000',
//       rating: 4.6,
//       reviewCount: 94,
//       image:
//           'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80',
//       isOpen: true,
//       distance: '2.8 km',
//       features: ['Turf', 'Shower', 'Cafe'],
//       accentColor: const Color(0xFF69F0AE),
//     ),
//     CourtModel(
//       name: 'Champion 5A Side',
//       location: 'Koteshwor, Kathmandu',
//       price: 'Rs. 1,500',
//       rating: 4.5,
//       reviewCount: 76,
//       image:
//           'https://images.unsplash.com/photo-1486286701208-1d58e9338013?auto=format&fit=crop&w=1200&q=80',
//       isOpen: false,
//       distance: '3.5 km',
//       features: ['Outdoor', 'Training', 'Parking'],
//       accentColor: const Color(0xFF00BFA5),
//     ),
//     CourtModel(
//       name: 'Royal Futsal Hub',
//       location: 'Bhaktapur',
//       price: 'Rs. 1,700',
//       rating: 4.7,
//       reviewCount: 111,
//       image:
//           'https://images.unsplash.com/photo-1552667466-07770ae110d0?auto=format&fit=crop&w=1200&q=80',
//       isOpen: true,
//       distance: '5.1 km',
//       features: ['Indoor', 'Cafe', 'Events'],
//       accentColor: const Color(0xFF00E676),
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _animController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//     _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
//     _animController.forward();
//   }

//   @override
//   void dispose() {
//     _animController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0D15),
//       extendBody: true,
//       body: FadeTransition(
//         opacity: _fadeIn,
//         child: CustomScrollView(
//           physics: const BouncingScrollPhysics(),
//           slivers: [
//             // ── Hero Header ──────────────────────────────────────────
//             SliverToBoxAdapter(child: _buildHeader()),

//             // ── Search + Filters ─────────────────────────────────────
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
//                 child: Column(
//                   children: [
//                     _buildSearchBar(),
//                     const SizedBox(height: 16),
//                     _buildFilterRow(),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Section Title ─────────────────────────────────────────
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
//                 child: Row(
//                   children: [
//                     const Text(
//                       'Available Courts',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: -0.3,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       '${courts.length} found',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.4),
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Court Cards ───────────────────────────────────────────
//             SliverPadding(
//               padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
//               sliver: SliverList.builder(
//                 itemCount: courts.length,
//                 itemBuilder: (context, index) {
//                   return TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0, end: 1),
//                     duration: Duration(milliseconds: 500 + index * 120),
//                     curve: Curves.easeOutCubic,
//                     builder: (context, value, child) => Transform.translate(
//                       offset: Offset(0, 30 * (1 - value)),
//                       child: Opacity(opacity: value, child: child),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.only(bottom: 20),
//                       child: CourtCard(court: courts[index]),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),

//       // ── Bottom Navigation ─────────────────────────────────────────
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       height: 240,
//       child: Stack(
//         children: [
//           // Background gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF0D2118), Color(0xFF0A0D15)],
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//               ),
//             ),
//           ),

//           // Decorative glow orbs
//           Positioned(
//             right: -60,
//             top: -20,
//             child: Container(
//               height: 220,
//               width: 220,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   colors: [
//                     const Color(0xFF00E676).withOpacity(0.15),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: -40,
//             bottom: 10,
//             child: Container(
//               height: 160,
//               width: 160,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: RadialGradient(
//                   colors: [
//                     const Color(0xFF00BFA5).withOpacity(0.10),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Top bar
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       // Avatar
//                       Container(
//                         height: 44,
//                         width: 44,
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: [Color(0xFF00E676), Color(0xFF00897B)],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                           borderRadius: BorderRadius.circular(14),
//                         ),
//                         child: const Center(
//                           child: Text(
//                             'R',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 18,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Good evening 👋',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.5),
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                           const Text(
//                             'Rahul Shrestha',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       _GlassIconButton(icon: Icons.notifications_outlined),
//                     ],
//                   ),

//                   const SizedBox(height: 28),

//                   // Headline
//                   const Text(
//                     'Find Your\nPerfect Court',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 34,
//                       fontWeight: FontWeight.w900,
//                       height: 1.1,
//                       letterSpacing: -1.0,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.location_on_rounded,
//                         color: Color(0xFF00E676),
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Kathmandu Valley',
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.55),
//                           fontSize: 13.5,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(
//                         Icons.keyboard_arrow_down_rounded,
//                         color: Colors.white.withOpacity(0.4),
//                         size: 18,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       height: 56,
//       decoration: BoxDecoration(
//         color: const Color(0xFF141924),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: Colors.white.withOpacity(0.07), width: 1.5),
//       ),
//       child: TextField(
//         style: const TextStyle(color: Colors.white, fontSize: 14),
//         decoration: InputDecoration(
//           hintText: 'Search courts, areas...',
//           hintStyle: TextStyle(
//             color: Colors.white.withOpacity(0.3),
//             fontSize: 14,
//           ),
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             color: Colors.white.withOpacity(0.4),
//             size: 22,
//           ),
//           suffixIcon: Container(
//             margin: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF00E676), Color(0xFF00897B)],
//               ),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(
//               Icons.tune_rounded,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//           border: InputBorder.none,
//           contentPadding: const EdgeInsets.symmetric(vertical: 18),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterRow() {
//     return SizedBox(
//       height: 40,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         itemCount: _filters.length,
//         itemBuilder: (context, i) {
//           final selected = _selectedFilter == i;
//           return GestureDetector(
//             onTap: () => setState(() => _selectedFilter = i),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 220),
//               margin: const EdgeInsets.only(right: 10),
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
//               decoration: BoxDecoration(
//                 gradient: selected
//                     ? const LinearGradient(
//                         colors: [Color(0xFF00E676), Color(0xFF00897B)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       )
//                     : null,
//                 color: selected ? null : const Color(0xFF141924),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: selected
//                       ? Colors.transparent
//                       : Colors.white.withOpacity(0.07),
//                   width: 1.5,
//                 ),
//                 boxShadow: selected
//                     ? [
//                         BoxShadow(
//                           color: const Color(0xFF00E676).withOpacity(0.35),
//                           blurRadius: 16,
//                           offset: const Offset(0, 5),
//                         ),
//                       ]
//                     : [],
//               ),
//               child: Text(
//                 _filters[i],
//                 style: TextStyle(
//                   color: selected
//                       ? Colors.white
//                       : Colors.white.withOpacity(0.45),
//                   fontWeight: FontWeight.w700,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildBottomNav() {
//     final items = [
//       Icons.home_rounded,
//       Icons.explore_rounded,
//       Icons.calendar_today_rounded,
//       Icons.person_outline_rounded,
//     ];
//     final labels = ['Home', 'Explore', 'Bookings', 'Profile'];

//     return ClipRRect(
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
//         child: Container(
//           padding: const EdgeInsets.only(bottom: 12, top: 10),
//           decoration: BoxDecoration(
//             color: const Color(0xFF0D1017).withOpacity(0.88),
//             border: Border(
//               top: BorderSide(color: Colors.white.withOpacity(0.07), width: 1),
//             ),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: List.generate(
//               items.length,
//               (i) => GestureDetector(
//                 onTap: () => setState(() => _selectedNav = i),
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 220),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _selectedNav == i
//                         ? const Color(0xFF00E676).withOpacity(0.12)
//                         : Colors.transparent,
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         items[i],
//                         color: _selectedNav == i
//                             ? const Color(0xFF00E676)
//                             : Colors.white.withOpacity(0.3),
//                         size: 24,
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         labels[i],
//                         style: TextStyle(
//                           color: _selectedNav == i
//                               ? const Color(0xFF00E676)
//                               : Colors.white.withOpacity(0.3),
//                           fontSize: 10.5,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Glass Icon Button
// // ─────────────────────────────────────────────────────────────────────────────
// class _GlassIconButton extends StatelessWidget {
//   final IconData icon;
//   const _GlassIconButton({required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(14),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           height: 44,
//           width: 44,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.08),
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.white.withOpacity(0.1)),
//           ),
//           child: Icon(icon, color: Colors.white, size: 22),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Court Card
// // ─────────────────────────────────────────────────────────────────────────────
// class CourtCard extends StatefulWidget {
//   final CourtModel court;
//   const CourtCard({super.key, required this.court});

//   @override
//   State<CourtCard> createState() => _CourtCardState();
// }

// class _CourtCardState extends State<CourtCard> {
//   bool _saved = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF131720),
//           borderRadius: BorderRadius.circular(28),
//           border: Border.all(color: Colors.white.withOpacity(0.06), width: 1.5),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.4),
//               blurRadius: 24,
//               offset: const Offset(0, 10),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Image Section ───────────────────────────────────────
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(28),
//               ),
//               child: SizedBox(
//                 height: 200,
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     // Court image
//                     Image.network(widget.court.image, fit: BoxFit.cover),

//                     // Dark gradient overlay (bottom)
//                     Positioned.fill(
//                       child: DecoratedBox(
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Colors.transparent,
//                               Colors.black.withOpacity(0.72),
//                             ],
//                             stops: const [0.45, 1.0],
//                           ),
//                         ),
//                       ),
//                     ),

//                     // Top-left: Open/Closed pill
//                     Positioned(
//                       top: 14,
//                       left: 14,
//                       child: _StatusPill(isOpen: widget.court.isOpen),
//                     ),

//                     // Top-right: Save button
//                     Positioned(
//                       top: 12,
//                       right: 12,
//                       child: GestureDetector(
//                         onTap: () => setState(() => _saved = !_saved),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: BackdropFilter(
//                             filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                             child: Container(
//                               height: 40,
//                               width: 40,
//                               decoration: BoxDecoration(
//                                 color: Colors.black.withOpacity(0.3),
//                                 borderRadius: BorderRadius.circular(12),
//                                 border: Border.all(
//                                   color: Colors.white.withOpacity(0.15),
//                                 ),
//                               ),
//                               child: Icon(
//                                 _saved
//                                     ? Icons.bookmark_rounded
//                                     : Icons.bookmark_outline_rounded,
//                                 color: _saved
//                                     ? const Color(0xFF00E676)
//                                     : Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),

//                     // Bottom: name & location overlaid on image
//                     Positioned(
//                       bottom: 14,
//                       left: 16,
//                       right: 16,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.court.name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: -0.4,
//                               height: 1.1,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.location_on_rounded,
//                                 size: 13,
//                                 color: Colors.white.withOpacity(0.6),
//                               ),
//                               const SizedBox(width: 3),
//                               Text(
//                                 widget.court.location,
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.65),
//                                   fontSize: 12.5,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Container(
//                                 width: 3,
//                                 height: 3,
//                                 decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.4),
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 widget.court.distance,
//                                 style: TextStyle(
//                                   color: Colors.white.withOpacity(0.5),
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // ── Details Section ─────────────────────────────────────
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Rating + features row
//                   Row(
//                     children: [
//                       // Rating pill
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 5,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF00E676).withOpacity(0.12),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.star_rounded,
//                               color: Color(0xFF00E676),
//                               size: 15,
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               widget.court.rating.toString(),
//                               style: const TextStyle(
//                                 color: Color(0xFF00E676),
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w800,
//                               ),
//                             ),
//                             const SizedBox(width: 4),
//                             Text(
//                               '(${widget.court.reviewCount})',
//                               style: TextStyle(
//                                 color: Colors.white.withOpacity(0.4),
//                                 fontSize: 11.5,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       // Feature chips
//                       Expanded(
//                         child: SingleChildScrollView(
//                           scrollDirection: Axis.horizontal,
//                           physics: const BouncingScrollPhysics(),
//                           child: Row(
//                             children: widget.court.features
//                                 .map(
//                                   (f) => Container(
//                                     margin: const EdgeInsets.only(right: 6),
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 10,
//                                       vertical: 5,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(0.06),
//                                       borderRadius: BorderRadius.circular(9),
//                                       border: Border.all(
//                                         color: Colors.white.withOpacity(0.08),
//                                         width: 1,
//                                       ),
//                                     ),
//                                     child: Text(
//                                       f,
//                                       style: TextStyle(
//                                         color: Colors.white.withOpacity(0.55),
//                                         fontSize: 11.5,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                                 .toList(),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 16),

//                   // Divider
//                   Container(height: 1, color: Colors.white.withOpacity(0.06)),

//                   const SizedBox(height: 16),

//                   // Price + Book button
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.court.price,
//                             style: const TextStyle(
//                               color: Color(0xFF00E676),
//                               fontSize: 22,
//                               fontWeight: FontWeight.w900,
//                               letterSpacing: -0.5,
//                             ),
//                           ),
//                           Text(
//                             'per hour',
//                             style: TextStyle(
//                               color: Colors.white.withOpacity(0.35),
//                               fontSize: 11.5,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       GestureDetector(
//                         onTap: () {},
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 24,
//                             vertical: 13,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: const LinearGradient(
//                               colors: [Color(0xFF00E676), Color(0xFF00897B)],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                             borderRadius: BorderRadius.circular(16),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: const Color(
//                                   0xFF00E676,
//                                 ).withOpacity(0.35),
//                                 blurRadius: 18,
//                                 offset: const Offset(0, 6),
//                               ),
//                             ],
//                           ),
//                           child: const Text(
//                             'Book Now',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 14.5,
//                               letterSpacing: 0.2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Status Pill
// // ─────────────────────────────────────────────────────────────────────────────
// class _StatusPill extends StatelessWidget {
//   final bool isOpen;
//   const _StatusPill({required this.isOpen});

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(30),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
//           decoration: BoxDecoration(
//             color: isOpen
//                 ? const Color(0xFF00E676).withOpacity(0.2)
//                 : Colors.red.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(
//               color: isOpen
//                   ? const Color(0xFF00E676).withOpacity(0.5)
//                   : Colors.red.withOpacity(0.5),
//               width: 1,
//             ),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 height: 7,
//                 width: 7,
//                 decoration: BoxDecoration(
//                   color: isOpen ? const Color(0xFF00E676) : Colors.red,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 isOpen ? 'Open Now' : 'Closed',
//                 style: TextStyle(
//                   color: isOpen ? const Color(0xFF00E676) : Colors.red,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Court Model
// // ─────────────────────────────────────────────────────────────────────────────
// class CourtModel {
//   final String name;
//   final String location;
//   final String price;
//   final double rating;
//   final int reviewCount;
//   final String image;
//   final bool isOpen;
//   final String distance;
//   final List<String> features;
//   final Color accentColor;

//   CourtModel({
//     required this.name,
//     required this.location,
//     required this.price,
//     required this.rating,
//     required this.reviewCount,
//     required this.image,
//     required this.isOpen,
//     required this.distance,
//     required this.features,
//     required this.accentColor,
//   });
// }

// // import 'package:flutter/material.dart';

// // class FootsallHomePage extends StatelessWidget {
// //   const FootsallHomePage({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return const CourtsListScreen();
// //   }
// // }

// // class CourtsListScreen extends StatelessWidget {
// //   const CourtsListScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     final courts = <CourtModel>[
// //       CourtModel(
// //         name: 'Goal Arena Futsal',
// //         location: 'Baneshwor, Kathmandu',
// //         price: 'Rs. 1,800/hr',
// //         rating: 4.8,
// //         image:
// //             'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
// //         isOpen: true,
// //         features: ['Indoor', 'Parking', 'Lights'],
// //       ),
// //       CourtModel(
// //         name: 'Urban Kick Center',
// //         location: 'Lalitpur, Jawalakhel',
// //         price: 'Rs. 2,000/hr',
// //         rating: 4.6,
// //         image:
// //             'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80',
// //         isOpen: true,
// //         features: ['Turf', 'Shower', 'Cafe'],
// //       ),
// //       CourtModel(
// //         name: 'Champion 5A Side',
// //         location: 'Koteshwor, Kathmandu',
// //         price: 'Rs. 1,500/hr',
// //         rating: 4.5,
// //         image:
// //             'https://images.unsplash.com/photo-1486286701208-1d58e9338013?auto=format&fit=crop&w=1200&q=80',
// //         isOpen: false,
// //         features: ['Outdoor', 'Training', 'Parking'],
// //       ),
// //       CourtModel(
// //         name: 'Royal Futsal Hub',
// //         location: 'Bhaktapur',
// //         price: 'Rs. 1,700/hr',
// //         rating: 4.7,
// //         image:
// //             'https://images.unsplash.com/photo-1552667466-07770ae110d0?auto=format&fit=crop&w=1200&q=80',
// //         isOpen: true,
// //         features: ['Indoor', 'Cafe', 'Events'],
// //       ),
// //     ];

// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F7FB),
// //       body: CustomScrollView(
// //         physics: const BouncingScrollPhysics(),
// //         slivers: [
// //           SliverAppBar(
// //             expandedHeight: 180,
// //             pinned: true,
// //             elevation: 0,
// //             backgroundColor: const Color(0xFF0E7A4B),
// //             flexibleSpace: FlexibleSpaceBar(
// //               titlePadding: const EdgeInsetsDirectional.only(
// //                 start: 20,
// //                 bottom: 16,
// //               ),
// //               title: const Text(
// //                 'Futsal Courts',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.w700,
// //                   fontSize: 20,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //               background: Container(
// //                 decoration: const BoxDecoration(
// //                   gradient: LinearGradient(
// //                     colors: [Color(0xFF12A05C), Color(0xFF0B6B40)],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                 ),
// //                 child: Stack(
// //                   children: [
// //                     Positioned(
// //                       right: -30,
// //                       top: 20,
// //                       child: Container(
// //                         height: 140,
// //                         width: 140,
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.08),
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                     ),
// //                     Positioned(
// //                       left: -40,
// //                       bottom: -20,
// //                       child: Container(
// //                         height: 120,
// //                         width: 120,
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.06),
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                     ),
// //                     const Positioned(
// //                       left: 20,
// //                       right: 20,
// //                       bottom: 60,
// //                       child: Text(
// //                         'Find the best court near you',
// //                         style: TextStyle(
// //                           color: Colors.white70,
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w400,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),

// //           SliverToBoxAdapter(
// //             child: Padding(
// //               padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
// //               child: Column(
// //                 children: [
// //                   _SearchField(),
// //                   const SizedBox(height: 14),
// //                   SizedBox(
// //                     height: 42,
// //                     child: ListView(
// //                       scrollDirection: Axis.horizontal,
// //                       physics: const BouncingScrollPhysics(),
// //                       children: const [
// //                         _FilterChipWidget(label: 'All', selected: true),
// //                         _FilterChipWidget(label: 'Nearby'),
// //                         _FilterChipWidget(label: 'Indoor'),
// //                         _FilterChipWidget(label: 'Outdoor'),
// //                         _FilterChipWidget(label: 'Open Now'),
// //                         _FilterChipWidget(label: 'Top Rated'),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           SliverPadding(
// //             padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
// //             sliver: SliverList.builder(
// //               itemCount: courts.length,
// //               itemBuilder: (context, index) {
// //                 final court = courts[index];
// //                 return Padding(
// //                   padding: const EdgeInsets.only(bottom: 16),
// //                   child: CourtCard(court: court),
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class _SearchField extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 54,
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(18),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.04),
// //             blurRadius: 16,
// //             offset: const Offset(0, 6),
// //           ),
// //         ],
// //       ),
// //       child: TextField(
// //         decoration: InputDecoration(
// //           hintText: 'Search courts, area, features...',
// //           hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
// //           prefixIcon: const Icon(Icons.search_rounded),
// //           suffixIcon: Container(
// //             margin: const EdgeInsets.all(8),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFF0E7A4B),
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: const Icon(
// //               Icons.tune_rounded,
// //               color: Colors.white,
// //               size: 20,
// //             ),
// //           ),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(18),
// //             borderSide: BorderSide.none,
// //           ),
// //           filled: true,
// //           fillColor: Colors.white,
// //           contentPadding: const EdgeInsets.symmetric(vertical: 16),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class _FilterChipWidget extends StatelessWidget {
// //   final String label;
// //   final bool selected;

// //   const _FilterChipWidget({required this.label, this.selected = false});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       margin: const EdgeInsets.only(right: 10),
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 250),
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
// //         decoration: BoxDecoration(
// //           color: selected ? const Color(0xFF0E7A4B) : Colors.white,
// //           borderRadius: BorderRadius.circular(14),
// //           border: Border.all(
// //             color: selected ? const Color(0xFF0E7A4B) : Colors.grey.shade300,
// //           ),
// //           boxShadow: selected
// //               ? [
// //                   BoxShadow(
// //                     color: const Color(0xFF0E7A4B).withOpacity(0.22),
// //                     blurRadius: 12,
// //                     offset: const Offset(0, 6),
// //                   ),
// //                 ]
// //               : [],
// //         ),
// //         child: Center(
// //           child: Text(
// //             label,
// //             style: TextStyle(
// //               color: selected ? Colors.white : const Color(0xFF2B2B2B),
// //               fontWeight: FontWeight.w600,
// //               fontSize: 13,
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class CourtCard extends StatelessWidget {
// //   final CourtModel court;

// //   const CourtCard({super.key, required this.court});

// //   @override
// //   Widget build(BuildContext context) {
// //     return InkWell(
// //       borderRadius: BorderRadius.circular(24),
// //       onTap: () {},
// //       child: Ink(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(24),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.06),
// //               blurRadius: 18,
// //               offset: const Offset(0, 8),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Hero(
// //               tag: court.name,
// //               child: ClipRRect(
// //                 borderRadius: const BorderRadius.vertical(
// //                   top: Radius.circular(24),
// //                 ),
// //                 child: Stack(
// //                   children: [
// //                     Image.network(
// //                       court.image,
// //                       height: 190,
// //                       width: double.infinity,
// //                       fit: BoxFit.cover,
// //                     ),
// //                     Positioned(
// //                       top: 14,
// //                       right: 14,
// //                       child: Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 7,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: Colors.black.withOpacity(0.35),
// //                           borderRadius: BorderRadius.circular(30),
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             const Icon(
// //                               Icons.star_rounded,
// //                               color: Colors.amber,
// //                               size: 18,
// //                             ),
// //                             const SizedBox(width: 4),
// //                             Text(
// //                               court.rating.toString(),
// //                               style: const TextStyle(
// //                                 color: Colors.white,
// //                                 fontWeight: FontWeight.w700,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                     Positioned(
// //                       left: 14,
// //                       top: 14,
// //                       child: Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 7,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: court.isOpen
// //                               ? const Color(0xFF16A34A)
// //                               : const Color(0xFFDC2626),
// //                           borderRadius: BorderRadius.circular(30),
// //                         ),
// //                         child: Text(
// //                           court.isOpen ? 'Open Now' : 'Closed',
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 12,
// //                             fontWeight: FontWeight.w700,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     court.name,
// //                     style: const TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.w800,
// //                       color: Color(0xFF1D2433),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Row(
// //                     children: [
// //                       Icon(
// //                         Icons.location_on_rounded,
// //                         size: 18,
// //                         color: Colors.grey.shade600,
// //                       ),
// //                       const SizedBox(width: 6),
// //                       Expanded(
// //                         child: Text(
// //                           court.location,
// //                           style: TextStyle(
// //                             fontSize: 13.5,
// //                             color: Colors.grey.shade700,
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 14),
// //                   Wrap(
// //                     spacing: 8,
// //                     runSpacing: 8,
// //                     children: court.features
// //                         .map(
// //                           (feature) => Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 12,
// //                               vertical: 7,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFFF2F6F8),
// //                               borderRadius: BorderRadius.circular(20),
// //                             ),
// //                             child: Text(
// //                               feature,
// //                               style: const TextStyle(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: Color(0xFF52606D),
// //                               ),
// //                             ),
// //                           ),
// //                         )
// //                         .toList(),
// //                   ),
// //                   const SizedBox(height: 18),
// //                   Row(
// //                     children: [
// //                       Text(
// //                         court.price,
// //                         style: const TextStyle(
// //                           color: Color(0xFF0E7A4B),
// //                           fontWeight: FontWeight.w800,
// //                           fontSize: 17,
// //                         ),
// //                       ),
// //                       const Spacer(),
// //                       ElevatedButton(
// //                         onPressed: () {},
// //                         style: ElevatedButton.styleFrom(
// //                           elevation: 0,
// //                           backgroundColor: const Color(0xFF0E7A4B),
// //                           foregroundColor: Colors.white,
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 18,
// //                             vertical: 12,
// //                           ),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(14),
// //                           ),
// //                         ),
// //                         child: const Text(
// //                           'Book Now',
// //                           style: TextStyle(fontWeight: FontWeight.w700),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class CourtModel {
// //   final String name;
// //   final String location;
// //   final String price;
// //   final double rating;
// //   final String image;
// //   final bool isOpen;
// //   final List<String> features;

// //   CourtModel({
// //     required this.name,
// //     required this.location,
// //     required this.price,
// //     required this.rating,
// //     required this.image,
// //     required this.isOpen,
// //     required this.features,
// //   });
// // }
