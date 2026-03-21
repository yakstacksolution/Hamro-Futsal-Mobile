// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
// import 'package:hamro_footsall/features/dashboard/presentation/widgets/app_drawer.dart';
// import 'package:hamro_footsall/core/routers/app_router_params.dart';

// // ─────────────────────────────────────────────
// // DESIGN TOKENS
// // ─────────────────────────────────────────────
// class _DS {
//   _DS._();

//   // Colors
//   static const Color primary = Color(0xFF0D9E5C);
//   static const Color primaryDark = Color(0xFF087A45);
//   static const Color primaryLight = Color(0xFFE8F8F0);
//   static const Color accent = Color(0xFF10B981);
//   static const Color surface = Color(0xFFFFFFFF);
//   static const Color background = Color(0xFFF7F9FC);
//   static const Color cardBg = Color(0xFFFFFFFF);
//   static const Color textPrimary = Color(0xFF111827);
//   static const Color textSecondary = Color(0xFF6B7280);
//   static const Color textTertiary = Color(0xFF9CA3AF);
//   static const Color border = Color(0xFFE5E7EB);
//   static const Color borderLight = Color(0xFFF3F4F6);
//   static const Color iconBg = Color(0xFFF0FDF4);
//   static const Color orangeLight = Color(0xFFFFF7ED);
//   static const Color orange = Color(0xFFF59E0B);
//   static const Color blueLight = Color(0xFFEFF6FF);
//   static const Color blue = Color(0xFF3B82F6);
//   static const Color purpleLight = Color(0xFFFAF5FF);
//   static const Color purple = Color(0xFF8B5CF6);
//   static const Color redLight = Color(0xFFFEF2F2);
//   static const Color red = Color(0xFFEF4444);
//   static const Color shimmer = Color(0xFFE5E7EB);

//   // Gradients
//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [Color(0xFF0D9E5C), Color(0xFF059669)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static const LinearGradient darkGradient = LinearGradient(
//     colors: [Color(0xFF111827), Color(0xFF1F2937)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static const LinearGradient cardGradient = LinearGradient(
//     colors: [Color(0xFF059669), Color(0xFF0D9E5C), Color(0xFF34D399)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   // Radii
//   static const double radiusXs = 8;
//   static const double radiusSm = 12;
//   static const double radiusMd = 16;
//   static const double radiusLg = 20;
//   static const double radiusXl = 24;
//   static const double radiusFull = 100;

//   // Spacing
//   static const double spaceXs = 4;
//   static const double spaceSm = 8;
//   static const double spaceMd = 12;
//   static const double spaceLg = 16;
//   static const double spaceXl = 20;
//   static const double space2xl = 24;
//   static const double space3xl = 32;

//   // Shadows
//   static List<BoxShadow> shadowSm = [
//     BoxShadow(
//       color: const Color(0xFF000000).withOpacity(0.04),
//       blurRadius: 8,
//       offset: const Offset(0, 2),
//     ),
//   ];

//   static List<BoxShadow> shadowMd = [
//     BoxShadow(
//       color: const Color(0xFF000000).withOpacity(0.06),
//       blurRadius: 16,
//       offset: const Offset(0, 4),
//     ),
//     BoxShadow(
//       color: const Color(0xFF000000).withOpacity(0.02),
//       blurRadius: 6,
//       offset: const Offset(0, 2),
//     ),
//   ];

//   static List<BoxShadow> shadowLg = [
//     BoxShadow(
//       color: const Color(0xFF000000).withOpacity(0.08),
//       blurRadius: 24,
//       offset: const Offset(0, 8),
//     ),
//   ];

//   static List<BoxShadow> shadowPrimary = [
//     BoxShadow(
//       color: primary.withOpacity(0.3),
//       blurRadius: 20,
//       offset: const Offset(0, 8),
//     ),
//   ];

//   // Text Styles
//   static const TextStyle heading1 = TextStyle(
//     fontSize: 26,
//     fontWeight: FontWeight.w800,
//     color: textPrimary,
//     letterSpacing: -0.5,
//     height: 1.2,
//   );

//   static const TextStyle heading2 = TextStyle(
//     fontSize: 20,
//     fontWeight: FontWeight.w700,
//     color: textPrimary,
//     letterSpacing: -0.3,
//   );

//   static const TextStyle heading3 = TextStyle(
//     fontSize: 17,
//     fontWeight: FontWeight.w700,
//     color: textPrimary,
//     letterSpacing: -0.2,
//   );

//   static const TextStyle bodyLarge = TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w500,
//     color: textPrimary,
//   );

//   static const TextStyle bodyMedium = TextStyle(
//     fontSize: 14,
//     fontWeight: FontWeight.w500,
//     color: textSecondary,
//   );

//   static const TextStyle bodySmall = TextStyle(
//     fontSize: 12.5,
//     fontWeight: FontWeight.w500,
//     color: textTertiary,
//   );

//   static const TextStyle label = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.w600,
//     color: textTertiary,
//     letterSpacing: 0.5,
//   );

//   static const TextStyle statValue = TextStyle(
//     fontSize: 22,
//     fontWeight: FontWeight.w800,
//     color: textPrimary,
//     letterSpacing: -0.5,
//   );
// }

// class _CourtData {
//   const _CourtData({
//     required this.name,
//     required this.location,
//     required this.rating,
//     required this.reviews,
//     required this.price,
//     required this.imageUrl,
//     required this.tags,
//     this.isOpen = true,
//     this.distance = '',
//   });
//   final String name;
//   final String location;
//   final double rating;
//   final int reviews;
//   final String price;
//   final String imageUrl;
//   final List<String> tags;
//   final bool isOpen;
//   final String distance;
// }

// class _BookingData {
//   const _BookingData({
//     required this.courtName,
//     required this.date,
//     required this.time,
//     required this.status,
//     required this.price,
//   });
//   final String courtName;
//   final String date;
//   final String time;
//   final String status;
//   final String price;
// }

// // ─────────────────────────────────────────────
// // MAIN DASHBOARD SCREEN
// // ─────────────────────────────────────────────
// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// class _DashboardScreenState extends State<DashboardScreen>
//     with TickerProviderStateMixin {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   static const DashboardUser _user = DashboardUser(
//     id: 'USR-1024',
//     name: 'Hamro Footsall',
//     email: 'merchant@hamrofootsall.com',
//   );

//   int _selectedNavIndex = 0;
//   int _selectedFilter = 0;
//   int _notificationCount = 3;

//   late final AnimationController _fabController;
//   late final Animation<double> _fabScale;

//   final List<String> _filters = [
//     '🔥 All',
//     '📍 Nearby',
//     '🏠 Indoor',
//     '🌿 Outdoor',
//     '🟢 Open Now',
//     '⭐ Top Rated',
//   ];

//   final List<_CourtData> _courts = const [
//     _CourtData(
//       name: 'Galaxy Futsal Arena',
//       location: 'Baneshwor, Kathmandu',
//       rating: 4.8,
//       reviews: 234,
//       price: 'Rs 1,200/hr',
//       imageUrl: 'https://images.unsplash.com/photo-1575361204480-aadea25e6e68',
//       tags: ['Indoor', 'Floodlight', 'Parking'],
//       distance: '1.2 km',
//     ),
//     _CourtData(
//       name: 'Kick Off Sports',
//       location: 'Lalitpur, Nepal',
//       rating: 4.6,
//       reviews: 189,
//       price: 'Rs 1,000/hr',
//       imageUrl: 'https://images.unsplash.com/photo-1551958219-acbc608c6377',
//       tags: ['Outdoor', 'Cafeteria'],
//       distance: '2.5 km',
//     ),
//     _CourtData(
//       name: 'Champions Ground',
//       location: 'Bhaktapur, Nepal',
//       rating: 4.9,
//       reviews: 312,
//       price: 'Rs 1,500/hr',
//       imageUrl: 'https://images.unsplash.com/photo-1574629810360-7efbbe195018',
//       tags: ['Indoor', 'AC', 'Premium'],
//       isOpen: false,
//       distance: '3.8 km',
//     ),
//     _CourtData(
//       name: 'United Futsal Hub',
//       location: 'Thamel, Kathmandu',
//       rating: 4.5,
//       reviews: 156,
//       price: 'Rs 900/hr',
//       imageUrl: 'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d',
//       tags: ['Outdoor', 'Night Play'],
//       distance: '0.8 km',
//     ),
//   ];

//   final List<_BookingData> _bookings = const [
//     _BookingData(
//       courtName: 'Galaxy Futsal Arena',
//       date: 'Today',
//       time: '6:00 PM - 7:00 PM',
//       status: 'Confirmed',
//       price: 'Rs 1,200',
//     ),
//     _BookingData(
//       courtName: 'Kick Off Sports',
//       date: 'Tomorrow',
//       time: '8:00 AM - 9:00 AM',
//       status: 'Pending',
//       price: 'Rs 1,000',
//     ),
//     _BookingData(
//       courtName: 'Champions Ground',
//       date: 'Dec 28',
//       time: '5:00 PM - 6:00 PM',
//       status: 'Completed',
//       price: 'Rs 1,500',
//     ),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fabController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _fabScale = CurvedAnimation(
//       parent: _fabController,
//       curve: Curves.elasticOut,
//     );
//     _fabController.forward();
//   }

//   @override
//   void dispose() {
//     _fabController.dispose();
//     super.dispose();
//   }

//   void _onBottomIconPressed(int index) {
//     HapticFeedback.lightImpact();
//     setState(() => _selectedNavIndex = index);
//     _fabController.reset();
//     _fabController.forward();
//   }

//   void _openCourtsPage() {
//     context.pushNamed(AppRouterParams.createCourts.name);
//   }

//   // ─────────────────────────────────────────
//   // APP BAR
//   // ─────────────────────────────────────────
//   Widget _buildAppBar() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
//       child: Row(
//         children: [
//           // Menu button
//           GestureDetector(
//             onTap: () => _scaffoldKey.currentState?.openDrawer(),
//             child: Container(
//               width: 46,
//               height: 46,
//               decoration: BoxDecoration(
//                 color: _DS.surface,
//                 borderRadius: BorderRadius.circular(_DS.radiusSm),
//                 boxShadow: _DS.shadowSm,
//               ),
//               child: const Icon(
//                 Icons.menu_rounded,
//                 color: _DS.textPrimary,
//                 size: 22,
//               ),
//             ),
//           ),
//           const SizedBox(width: 14),
//           // Greeting
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Good morning 👋',
//                   style: _DS.bodySmall.copyWith(
//                     color: _DS.textTertiary,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _user.name.split(' ').first,
//                   style: _DS.heading3.copyWith(fontSize: 18),
//                 ),
//               ],
//             ),
//           ),
//           // Notification
//           _buildNotificationBell(),
//           const SizedBox(width: 10),
//           // Avatar
//           _buildAvatar(),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotificationBell() {
//     return GestureDetector(
//       onTap: () {},
//       child: Container(
//         width: 46,
//         height: 46,
//         decoration: BoxDecoration(
//           color: _DS.surface,
//           borderRadius: BorderRadius.circular(_DS.radiusSm),
//           boxShadow: _DS.shadowSm,
//         ),
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             const Icon(
//               Icons.notifications_none_rounded,
//               color: _DS.textPrimary,
//               size: 23,
//             ),
//             if (_notificationCount > 0)
//               Positioned(
//                 top: 10,
//                 right: 11,
//                 child: Container(
//                   width: 18,
//                   height: 18,
//                   decoration: BoxDecoration(
//                     color: _DS.red,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: _DS.surface, width: 2),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '$_notificationCount',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 9,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAvatar() {
//     return Container(
//       width: 46,
//       height: 46,
//       decoration: BoxDecoration(
//         gradient: _DS.primaryGradient,
//         borderRadius: BorderRadius.circular(_DS.radiusSm),
//         boxShadow: [
//           BoxShadow(
//             color: _DS.primary.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: const Center(
//         child: Text(
//           'H',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w800,
//             fontSize: 18,
//           ),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // SEARCH BAR
//   // ─────────────────────────────────────────
//   Widget _buildSearchBar() {
//     return Container(
//       height: 52,
//       decoration: BoxDecoration(
//         color: _DS.surface,
//         borderRadius: BorderRadius.circular(_DS.radiusSm),
//         boxShadow: _DS.shadowSm,
//         border: Border.all(color: _DS.borderLight, width: 1),
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 16),
//           Icon(Icons.search_rounded, color: _DS.textTertiary, size: 22),
//           const SizedBox(width: 12),
//           Expanded(
//             child: TextField(
//               style: _DS.bodyLarge,
//               decoration: InputDecoration(
//                 hintText: 'Search courts, areas...',
//                 hintStyle: _DS.bodyMedium.copyWith(color: _DS.textTertiary),
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.zero,
//                 isDense: true,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Container(
//             width: 38,
//             height: 38,
//             margin: const EdgeInsets.only(right: 6),
//             decoration: BoxDecoration(
//               gradient: _DS.primaryGradient,
//               borderRadius: BorderRadius.circular(_DS.radiusXs),
//               boxShadow: [
//                 BoxShadow(
//                   color: _DS.primary.withOpacity(0.25),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.tune_rounded,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // FILTER CHIPS
//   // ─────────────────────────────────────────
//   Widget _buildFilterRow() {
//     return SizedBox(
//       height: 42,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         itemCount: _filters.length,
//         itemBuilder: (context, i) {
//           final selected = _selectedFilter == i;
//           return GestureDetector(
//             onTap: () {
//               HapticFeedback.selectionClick();
//               setState(() => _selectedFilter = i);
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               curve: Curves.easeOut,
//               margin: const EdgeInsets.only(right: 10),
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 gradient: selected ? _DS.primaryGradient : null,
//                 color: selected ? null : _DS.surface,
//                 borderRadius: BorderRadius.circular(_DS.radiusFull),
//                 border: Border.all(
//                   color: selected ? Colors.transparent : _DS.border,
//                   width: 1,
//                 ),
//                 boxShadow: selected ? _DS.shadowPrimary : _DS.shadowSm,
//               ),
//               child: Text(
//                 _filters[i],
//                 style: TextStyle(
//                   color: selected ? Colors.white : _DS.textSecondary,
//                   fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
//                   fontSize: 13,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // STATS ROW
//   // ─────────────────────────────────────────
//   Widget _buildStatsRow() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: [
//           _buildStatCard(
//             icon: Icons.sports_soccer_rounded,
//             iconBg: _DS.iconBg,
//             iconColor: _DS.primary,
//             value: '12',
//             label: 'COURTS',
//           ),
//           const SizedBox(width: 12),
//           _buildStatCard(
//             icon: Icons.calendar_today_rounded,
//             iconBg: _DS.blueLight,
//             iconColor: _DS.blue,
//             value: '48',
//             label: 'BOOKINGS',
//           ),
//           const SizedBox(width: 12),
//           _buildStatCard(
//             icon: Icons.star_rounded,
//             iconBg: _DS.orangeLight,
//             iconColor: _DS.orange,
//             value: '4.8',
//             label: 'RATING',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard({
//     required IconData icon,
//     required Color iconBg,
//     required Color iconColor,
//     required String value,
//     required String label,
//   }) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           color: _DS.surface,
//           borderRadius: BorderRadius.circular(_DS.radiusMd),
//           boxShadow: _DS.shadowSm,
//           border: Border.all(color: _DS.borderLight, width: 1),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: 36,
//               height: 36,
//               decoration: BoxDecoration(
//                 color: iconBg,
//                 borderRadius: BorderRadius.circular(_DS.radiusXs),
//               ),
//               child: Icon(icon, color: iconColor, size: 18),
//             ),
//             const SizedBox(height: 10),
//             Text(value, style: _DS.statValue),
//             const SizedBox(height: 2),
//             Text(label, style: _DS.label),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // PROMO BANNER
//   // ─────────────────────────────────────────
//   Widget _buildPromoBanner() {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: _DS.cardGradient,
//         borderRadius: BorderRadius.circular(_DS.radiusLg),
//         boxShadow: _DS.shadowPrimary,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(_DS.radiusFull),
//                   ),
//                   child: const Text(
//                     '🎉 Limited Offer',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   '20% OFF\nFirst Booking!',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 22,
//                     height: 1.2,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(_DS.radiusXs),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Text(
//                     'Book Now →',
//                     style: TextStyle(
//                       color: _DS.primaryDark,
//                       fontWeight: FontWeight.w800,
//                       fontSize: 13,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 10),
//           Container(
//             width: 90,
//             height: 90,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.15),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.sports_soccer_rounded,
//               color: Colors.white,
//               size: 50,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // SECTION HEADER
//   // ─────────────────────────────────────────
//   Widget _buildSectionHeader(String title, {String action = 'See All'}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(title, style: _DS.heading2),
//           GestureDetector(
//             onTap: () {},
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: _DS.primaryLight,
//                 borderRadius: BorderRadius.circular(_DS.radiusFull),
//               ),
//               child: Text(
//                 action,
//                 style: _DS.bodySmall.copyWith(
//                   color: _DS.primary,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // COURT CARDS
//   // ─────────────────────────────────────────
//   Widget _buildCourtsSection() {
//     return SizedBox(
//       height: 260,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         itemCount: _courts.length,
//         itemBuilder: (context, i) => _buildCourtCard(_courts[i]),
//       ),
//     );
//   }

//   Widget _buildCourtCard(_CourtData court) {
//     return Container(
//       width: 220,
//       margin: const EdgeInsets.only(right: 16),
//       decoration: BoxDecoration(
//         color: _DS.surface,
//         borderRadius: BorderRadius.circular(_DS.radiusMd),
//         boxShadow: _DS.shadowMd,
//         border: Border.all(color: _DS.borderLight, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image placeholder
//           Container(
//             height: 130,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadius.vertical(
//                 top: Radius.circular(_DS.radiusMd),
//               ),
//               gradient: LinearGradient(
//                 colors: [
//                   _DS.primary.withOpacity(0.1),
//                   _DS.accent.withOpacity(0.05),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Stack(
//               children: [
//                 // Placeholder icon
//                 Center(
//                   child: Icon(
//                     Icons.sports_soccer_rounded,
//                     color: _DS.primary.withOpacity(0.15),
//                     size: 60,
//                   ),
//                 ),
//                 // Status badge
//                 Positioned(
//                   top: 10,
//                   left: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: court.isOpen
//                           ? _DS.primary.withOpacity(0.9)
//                           : _DS.red.withOpacity(0.9),
//                       borderRadius: BorderRadius.circular(_DS.radiusFull),
//                     ),
//                     child: Text(
//                       court.isOpen ? '● Open' : '● Closed',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ),
//                 ),
//                 // Favorite
//                 Positioned(
//                   top: 10,
//                   right: 10,
//                   child: Container(
//                     width: 32,
//                     height: 32,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.9),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.favorite_border_rounded,
//                       color: _DS.red,
//                       size: 16,
//                     ),
//                   ),
//                 ),
//                 // Distance badge
//                 if (court.distance.isNotEmpty)
//                   Positioned(
//                     bottom: 10,
//                     right: 10,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 8,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.6),
//                         borderRadius: BorderRadius.circular(_DS.radiusFull),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.near_me_rounded,
//                             color: Colors.white,
//                             size: 10,
//                           ),
//                           const SizedBox(width: 3),
//                           Text(
//                             court.distance,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           // Details
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         court.name,
//                         style: _DS.bodyLarge.copyWith(
//                           fontWeight: FontWeight.w700,
//                           fontSize: 14,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       const SizedBox(height: 3),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_on_outlined,
//                             color: _DS.textTertiary,
//                             size: 13,
//                           ),
//                           const SizedBox(width: 3),
//                           Expanded(
//                             child: Text(
//                               court.location,
//                               style: _DS.bodySmall.copyWith(fontSize: 11.5),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Rating
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.star_rounded,
//                             color: _DS.orange,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 3),
//                           Text(
//                             '${court.rating}',
//                             style: _DS.bodyLarge.copyWith(
//                               fontWeight: FontWeight.w700,
//                               fontSize: 13,
//                             ),
//                           ),
//                           const SizedBox(width: 2),
//                           Text(
//                             '(${court.reviews})',
//                             style: _DS.bodySmall.copyWith(fontSize: 11),
//                           ),
//                         ],
//                       ),
//                       // Price
//                       Text(
//                         court.price,
//                         style: _DS.bodyLarge.copyWith(
//                           color: _DS.primary,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 12.5,
//                         ),
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

//   // ─────────────────────────────────────────
//   // RECENT BOOKINGS
//   // ─────────────────────────────────────────
//   Widget _buildRecentBookings() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Column(
//         children: _bookings
//             .map(
//               (b) => Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: _buildBookingTile(b),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildBookingTile(_BookingData booking) {
//     Color statusColor;
//     Color statusBg;
//     IconData statusIcon;

//     switch (booking.status) {
//       case 'Confirmed':
//         statusColor = _DS.primary;
//         statusBg = _DS.primaryLight;
//         statusIcon = Icons.check_circle_outline_rounded;
//         break;
//       case 'Pending':
//         statusColor = _DS.orange;
//         statusBg = _DS.orangeLight;
//         statusIcon = Icons.schedule_rounded;
//         break;
//       case 'Completed':
//         statusColor = _DS.blue;
//         statusBg = _DS.blueLight;
//         statusIcon = Icons.task_alt_rounded;
//         break;
//       default:
//         statusColor = _DS.textTertiary;
//         statusBg = _DS.borderLight;
//         statusIcon = Icons.info_outline_rounded;
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _DS.surface,
//         borderRadius: BorderRadius.circular(_DS.radiusMd),
//         boxShadow: _DS.shadowSm,
//         border: Border.all(color: _DS.borderLight, width: 1),
//       ),
//       child: Row(
//         children: [
//           // Icon
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: statusBg,
//               borderRadius: BorderRadius.circular(_DS.radiusSm),
//             ),
//             child: Icon(statusIcon, color: statusColor, size: 22),
//           ),
//           const SizedBox(width: 14),
//           // Details
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   booking.courtName,
//                   style: _DS.bodyLarge.copyWith(fontWeight: FontWeight.w700),
//                 ),
//                 const SizedBox(height: 4),
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.calendar_today_rounded,
//                       size: 12,
//                       color: _DS.textTertiary,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       '${booking.date} • ${booking.time}',
//                       style: _DS.bodySmall,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           // Price & Status
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 booking.price,
//                 style: _DS.bodyLarge.copyWith(
//                   fontWeight: FontWeight.w800,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: statusBg,
//                   borderRadius: BorderRadius.circular(_DS.radiusFull),
//                 ),
//                 child: Text(
//                   booking.status,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontSize: 10.5,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // QUICK ACTIONS
//   // ─────────────────────────────────────────
//   Widget _buildQuickActions() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         children: [
//           _buildQuickAction(
//             icon: Icons.add_circle_outline_rounded,
//             label: 'Book Court',
//             color: _DS.primary,
//             bg: _DS.primaryLight,
//             onTap: _openCourtsPage,
//           ),
//           const SizedBox(width: 12),
//           _buildQuickAction(
//             icon: Icons.history_rounded,
//             label: 'My Bookings',
//             color: _DS.blue,
//             bg: _DS.blueLight,
//           ),
//           const SizedBox(width: 12),
//           _buildQuickAction(
//             icon: Icons.group_outlined,
//             label: 'Find Team',
//             color: _DS.purple,
//             bg: _DS.purpleLight,
//           ),
//           const SizedBox(width: 12),
//           _buildQuickAction(
//             icon: Icons.emoji_events_outlined,
//             label: 'Leagues',
//             color: _DS.orange,
//             bg: _DS.orangeLight,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickAction({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required Color bg,
//     VoidCallback? onTap,
//   }) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap ?? () {},
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           decoration: BoxDecoration(
//             color: _DS.surface,
//             borderRadius: BorderRadius.circular(_DS.radiusMd),
//             boxShadow: _DS.shadowSm,
//             border: Border.all(color: _DS.borderLight, width: 1),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: 44,
//                 height: 44,
//                 decoration: BoxDecoration(
//                   color: bg,
//                   borderRadius: BorderRadius.circular(_DS.radiusSm),
//                 ),
//                 child: Icon(icon, color: color, size: 22),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 label,
//                 style: _DS.bodySmall.copyWith(
//                   fontWeight: FontWeight.w600,
//                   color: _DS.textSecondary,
//                   fontSize: 11,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // HOME TAB CONTENT
//   // ─────────────────────────────────────────
//   Widget _buildHomeContent() {
//     return ListView(
//       key: const ValueKey('home'),
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.only(bottom: 100),
//       children: [
//         const SizedBox(height: 8),
//         _buildPromoBanner(),
//         const SizedBox(height: 24),
//         _buildStatsRow(),
//         const SizedBox(height: 24),
//         _buildSectionHeader('Quick Actions'),
//         const SizedBox(height: 14),
//         _buildQuickActions(),
//         const SizedBox(height: 28),
//         _buildSectionHeader('Popular Courts'),
//         const SizedBox(height: 14),
//         _buildCourtsSection(),
//         const SizedBox(height: 28),
//         _buildSectionHeader('Recent Bookings'),
//         const SizedBox(height: 14),
//         _buildRecentBookings(),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────
//   // SHOPS TAB
//   // ─────────────────────────────────────────
//   Widget _buildShopsContent() {
//     return ListView(
//       key: const ValueKey('shops'),
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
//       children: [
//         // Create shop CTA
//         Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             gradient: _DS.cardGradient,
//             borderRadius: BorderRadius.circular(_DS.radiusLg),
//             boxShadow: _DS.shadowPrimary,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 40,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(_DS.radiusXs),
//                     ),
//                     child: const Icon(
//                       Icons.rocket_launch_rounded,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'Ready to launch a new shop?',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w700,
//                         fontSize: 17,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Create a verified shop profile with registration and branding details.',
//                 style: TextStyle(
//                   color: Colors.white.withOpacity(0.85),
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: _openCourtsPage,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 12,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(_DS.radiusSm),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.add_business_rounded,
//                         color: _DS.primaryDark,
//                         size: 18,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         'Create Shop',
//                         style: TextStyle(
//                           color: _DS.primaryDark,
//                           fontWeight: FontWeight.w800,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         _buildModernTile(
//           title: 'Bhatbhateni Outlet',
//           subtitle: 'Active · Kathmandu, Nepal',
//           icon: Icons.storefront_rounded,
//           iconColor: _DS.primary,
//           iconBg: _DS.primaryLight,
//           badge: 'Active',
//           badgeColor: _DS.primary,
//         ),
//         const SizedBox(height: 12),
//         _buildModernTile(
//           title: 'Hamro Mart',
//           subtitle: 'Pending verification · Lalitpur',
//           icon: Icons.pending_actions_rounded,
//           iconColor: _DS.orange,
//           iconBg: _DS.orangeLight,
//           badge: 'Pending',
//           badgeColor: _DS.orange,
//         ),
//       ],
//     );
//   }

//   // ─────────────────────────────────────────
//   // MODERN TILE (Shared widget)
//   // ─────────────────────────────────────────
//   Widget _buildModernTile({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color iconColor,
//     required Color iconBg,
//     String? badge,
//     Color? badgeColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _DS.surface,
//         borderRadius: BorderRadius.circular(_DS.radiusMd),
//         boxShadow: _DS.shadowSm,
//         border: Border.all(color: _DS.borderLight, width: 1),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 48,
//             height: 48,
//             decoration: BoxDecoration(
//               color: iconBg,
//               borderRadius: BorderRadius.circular(_DS.radiusSm),
//             ),
//             child: Icon(icon, color: iconColor, size: 22),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: _DS.bodyLarge.copyWith(fontWeight: FontWeight.w700),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(subtitle, style: _DS.bodySmall),
//               ],
//             ),
//           ),
//           if (badge != null)
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//               decoration: BoxDecoration(
//                 color: (badgeColor ?? _DS.primary).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(_DS.radiusFull),
//               ),
//               child: Text(
//                 badge,
//                 style: TextStyle(
//                   color: badgeColor ?? _DS.primary,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           const SizedBox(width: 8),
//           Icon(Icons.chevron_right_rounded, color: _DS.textTertiary, size: 22),
//         ],
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // OTHER TABS
//   // ─────────────────────────────────────────
//   Widget _buildProductsContent() {
//     return ListView(
//       key: const ValueKey('products'),
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
//       children: [
//         _buildModernTile(
//           title: 'Tomato x2',
//           subtitle: 'NPR 120',
//           icon: Icons.shopping_bag_outlined,
//           iconColor: _DS.red,
//           iconBg: _DS.redLight,
//         ),
//         const SizedBox(height: 12),
//         _buildModernTile(
//           title: 'Milk x1',
//           subtitle: 'NPR 90',
//           icon: Icons.shopping_bag_outlined,
//           iconColor: _DS.blue,
//           iconBg: _DS.blueLight,
//         ),
//         const SizedBox(height: 12),
//         _buildModernTile(
//           title: 'Rice x1',
//           subtitle: 'NPR 850',
//           icon: Icons.shopping_bag_outlined,
//           iconColor: _DS.orange,
//           iconBg: _DS.orangeLight,
//         ),
//       ],
//     );
//   }

//   Widget _buildCustomersContent() {
//     return ListView(
//       key: const ValueKey('customers'),
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
//       children: [
//         _buildModernTile(
//           title: 'New Customers (Today)',
//           subtitle: '24 signups from all shops',
//           icon: Icons.group_add_outlined,
//           iconColor: _DS.primary,
//           iconBg: _DS.primaryLight,
//           badge: '+24',
//           badgeColor: _DS.primary,
//         ),
//         const SizedBox(height: 12),
//         _buildModernTile(
//           title: 'Returning Customers',
//           subtitle: '132 active buyers this week',
//           icon: Icons.repeat_rounded,
//           iconColor: _DS.purple,
//           iconBg: _DS.purpleLight,
//           badge: '132',
//           badgeColor: _DS.purple,
//         ),
//       ],
//     );
//   }

//   Widget _buildAnalyticsContent() {
//     return ListView(
//       key: const ValueKey('analytics'),
//       physics: const BouncingScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
//       children: [
//         _buildModernTile(
//           title: 'Revenue Trend',
//           subtitle: 'NPR 1,20,000 this month',
//           icon: Icons.trending_up_rounded,
//           iconColor: _DS.primary,
//           iconBg: _DS.primaryLight,
//           badge: '↑ 12%',
//           badgeColor: _DS.primary,
//         ),
//         const SizedBox(height: 12),
//         _buildModernTile(
//           title: 'Conversion Rate',
//           subtitle: '3.8% from shop visits',
//           icon: Icons.insights_outlined,
//           iconColor: _DS.blue,
//           iconBg: _DS.blueLight,
//           badge: '3.8%',
//           badgeColor: _DS.blue,
//         ),
//       ],
//     );
//   }

//   Widget _buildCurrentTabSection() {
//     switch (_selectedNavIndex) {
//       case 0:
//         return _buildHomeContent();
//       case 1:
//         return _buildShopsContent();
//       case 2:
//         return _buildProductsContent();
//       case 3:
//         return _buildCustomersContent();
//       case 4:
//         return _buildAnalyticsContent();
//       default:
//         return _buildHomeContent();
//     }
//   }

//   // ─────────────────────────────────────────
//   // BOTTOM NAV BAR
//   // ─────────────────────────────────────────
//   Widget _buildBottomNav() {
//     const items = [
//       _NavItem(
//         icon: Icons.home_rounded,
//         activeIcon: Icons.home_rounded,
//         label: 'Home',
//       ),
//       _NavItem(
//         icon: Icons.storefront_outlined,
//         activeIcon: Icons.storefront_rounded,
//         label: 'Shops',
//       ),
//       _NavItem(icon: Icons.add, activeIcon: Icons.add, label: ''),
//       _NavItem(
//         icon: Icons.people_outline_rounded,
//         activeIcon: Icons.people_rounded,
//         label: 'Teams',
//       ),
//       _NavItem(
//         icon: Icons.bar_chart_rounded,
//         activeIcon: Icons.bar_chart_rounded,
//         label: 'Stats',
//       ),
//     ];

//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//       decoration: BoxDecoration(
//         color: _DS.surface,
//         borderRadius: BorderRadius.circular(_DS.radiusXl),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 30,
//             offset: const Offset(0, 10),
//           ),
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: List.generate(items.length, (i) {
//           if (i == 2) {
//             // Center FAB
//             return ScaleTransition(
//               scale: _fabScale,
//               child: GestureDetector(
//                 onTap: _openCourtsPage,
//                 child: Container(
//                   width: 52,
//                   height: 52,
//                   decoration: BoxDecoration(
//                     gradient: _DS.primaryGradient,
//                     shape: BoxShape.circle,
//                     boxShadow: _DS.shadowPrimary,
//                   ),
//                   child: const Icon(
//                     Icons.add_rounded,
//                     color: Colors.white,
//                     size: 28,
//                   ),
//                 ),
//               ),
//             );
//           }

//           final selected = _selectedNavIndex == (i > 2 ? i - 1 : i);
//           // Map visual index to nav index (skip center)
//           final navIndex = i > 2 ? i - 1 : i;

//           return GestureDetector(
//             onTap: () => _onBottomIconPressed(navIndex),
//             behavior: HitTestBehavior.opaque,
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               decoration: BoxDecoration(
//                 color: selected ? _DS.primaryLight : Colors.transparent,
//                 borderRadius: BorderRadius.circular(_DS.radiusFull),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     selected ? items[i].activeIcon : items[i].icon,
//                     color: selected ? _DS.primary : _DS.textTertiary,
//                     size: 24,
//                   ),
//                   if (selected) ...[
//                     const SizedBox(height: 2),
//                     Text(
//                       items[i].label,
//                       style: TextStyle(
//                         color: _DS.primary,
//                         fontSize: 10,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }

//   // ─────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.dark.copyWith(
//         statusBarColor: Colors.transparent,
//         systemNavigationBarColor: Colors.transparent,
//       ),
//       child: Scaffold(
//         key: _scaffoldKey,
//         backgroundColor: _DS.background,
//         drawer: AppDrawer(
//           user: _user,
//           currentIndex: _selectedNavIndex,
//           onNavTap: _onBottomIconPressed,
//           onSignOut: () => context.goNamed(AppRouterParams.login.name),
//         ),
//         body: SafeArea(
//           bottom: false,
//           child: Stack(
//             fit: StackFit.expand,
//             children: [
//               Column(
//                 children: [
//                   _buildAppBar(),
//                   const SizedBox(height: 12),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: _buildSearchBar(),
//                   ),
//                   const SizedBox(height: 14),
//                   _buildFilterRow(),
//                   const SizedBox(height: 8),
//                   Expanded(
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 350),
//                       switchInCurve: Curves.easeOutCubic,
//                       switchOutCurve: Curves.easeInCubic,
//                       transitionBuilder: (child, animation) {
//                         return FadeTransition(
//                           opacity: animation,
//                           child: SlideTransition(
//                             position: Tween<Offset>(
//                               begin: const Offset(0, 0.03),
//                               end: Offset.zero,
//                             ).animate(animation),
//                             child: child,
//                           ),
//                         );
//                       },
//                       child: _buildCurrentTabSection(),
//                     ),
//                   ),
//                 ],
//               ),
//               // Bottom nav
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: SafeArea(top: false, child: _buildBottomNav()),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // NAV ITEM MODEL
// // ─────────────────────────────────────────────
// class _NavItem {
//   const _NavItem({
//     required this.icon,
//     required this.activeIcon,
//     required this.label,
//   });
//   final IconData icon;
//   final IconData activeIcon;
//   final String label;
// }

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/theme/theme.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/overall_performance_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/recent_bookings_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/search_bar_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const DashboardUser _user = DashboardUser(
    id: 'USR-1024',
    name: 'Hamro Footsall',
    email: 'merchant@hamrofootsall.com',
  );

  int _selectedNavIndex = 0;
  int _selectedFilter = 0;

  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE8ECF0);

  void _onBottomIconPressed(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  void _openCourtsPage() {
    context.pushNamed(AppRouterParams.createCourts.name);
  }

  Widget _tapable({
    required Widget child,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: child),
    );
  }

  Widget _buildActionIcon(
    IconData icon, {
    Color color = LightColor.iconColor,
    VoidCallback? onTap,
  }) {
    return _tapable(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: AppTheme.shadow,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _appBar() {
    return Padding(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Good morning, ${_user.name.split(' ').first} 👋",
            style: AppTheme.titleStyle.copyWith(fontSize: 16),
          ),

          _tapable(
            onTap: () => context.goNamed(AppRouterParams.login.name),
            borderRadius: BorderRadius.circular(13),
            child: _buildActionIcon(
              Icons.notifications_outlined,
              color: LightColor.darkgrey,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewSection() {
    return ListView(
      key: const ValueKey<String>('overview'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      children: const <Widget>[
        OverallPerformanceWidget(),
        SizedBox(height: 20),
        RecentBookingsWidget(),
      ],
    );
  }

  Widget _shopsSection() {
    return ListView(
      key: const ValueKey<String>('shops'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                LightColor.primaryGreen,
                LightColor.secondaryGreen,
                LightColor.accentGreen,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: LightColor.primaryGreen.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Ready to launch a new shop?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create a verified shop profile with registration and branding details.',
                style: TextStyle(color: Color(0xE8FFFFFF), fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _openCourtsPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: LightColor.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('Create Shop'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _DashboardTile(
          title: 'Bhatbhateni Outlet',
          subtitle: 'Active · Kathmandu, Nepal',
          icon: Icons.storefront_outlined,
        ),
        const SizedBox(height: 12),
        const _DashboardTile(
          title: 'Hamro Mart',
          subtitle: 'Pending verification · Lalitpur, Nepal',
          icon: Icons.domain_verification_outlined,
        ),
      ],
    );
  }

  Widget _productsSection() {
    return ListView(
      key: const ValueKey<String>('products'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: const <Widget>[
        _DashboardTile(
          title: 'Tomato x2',
          subtitle: 'NPR 120',
          icon: Icons.shopping_bag_outlined,
        ),
        SizedBox(height: 12),
        _DashboardTile(
          title: 'Milk x1',
          subtitle: 'NPR 90',
          icon: Icons.shopping_bag_outlined,
        ),
        SizedBox(height: 12),
        _DashboardTile(
          title: 'Rice x1',
          subtitle: 'NPR 850',
          icon: Icons.shopping_bag_outlined,
        ),
      ],
    );
  }

  Widget _customersSection() {
    return ListView(
      key: const ValueKey<String>('customers'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: const <Widget>[
        _DashboardTile(
          title: 'New Customers (Today)',
          subtitle: '24 signups from all shops',
          icon: Icons.group_add_outlined,
        ),
        SizedBox(height: 12),
        _DashboardTile(
          title: 'Returning Customers',
          subtitle: '132 active buyers this week',
          icon: Icons.repeat_rounded,
        ),
      ],
    );
  }

  Widget _analyticsSection() {
    return ListView(
      key: const ValueKey<String>('analytics'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: const <Widget>[
        _DashboardTile(
          title: 'Revenue Trend',
          subtitle: 'NPR 1,20,000 this month',
          icon: Icons.trending_up_rounded,
        ),
        SizedBox(height: 12),
        _DashboardTile(
          title: 'Conversion Rate',
          subtitle: '3.8% from shop visits',
          icon: Icons.insights_outlined,
        ),
      ],
    );
  }

  Widget _buildCurrentTabSection() {
    switch (_selectedNavIndex) {
      case 0:
        // return _overviewSection();
        return FootsallHomePage();
      case 1:
        return _shopsSection();
      case 2:
        return _productsSection();
      case 3:
        return _customersSection();
      case 4:
        return _analyticsSection();
      default:
        return _overviewSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        user: _user,
        currentIndex: _selectedNavIndex,
        onNavTap: _onBottomIconPressed,
        onSignOut: () => context.goNamed(AppRouterParams.login.name),
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                height: AppTheme.fullHeight(context) - 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[LightColor.background, LightColor.surface],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _appBar(),
                    // _title(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Column(
                        children: [
                          // _buildSearchBar(),
                          ExpandableFocusSearchBar(),
                          const SizedBox(height: 14),
                          _buildFilterRow(),
                        ],
                      ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInToLinear,
                        switchOutCurve: Curves.easeOutBack,
                        child: _buildCurrentTabSection(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomBottomNavigationBar(
                currentIndex: _selectedNavIndex,
                onTap: _onBottomIconPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFF0D9E5C), Color(0xFF0B7A47)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? Colors.transparent : _border,
                  width: 0.6,
                ),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  color: selected ? Colors.white : _textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: LightColor.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        // style: const TextStyle(color: LightColor.black, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search courts, areas',
          hintStyle: TextStyle(color: LightColor.grey, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _textSecondary,
            size: 22,
          ),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9E5C), Color(0xFF0B7A47)],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              size: 22,
              Icons.tune_rounded,
              color: Colors.white,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  // final List<String> _filters = [
  //   'All',
  //   'Nearby',
  //   'Indoor',
  //   'Outdoor',
  //   'Open Now',
  //   'Top Rated',
  // ];
  final List<String> _filters = [
    '🔥 All',
    '📍 Nearby',
    '🏠 Indoor',
    '🌿 Outdoor',
    '🟢 Open Now',
    '⭐ Top Rated',
  ];
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: LightColor.orange.withAlpha(30), //Color(0xfffeece2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: LightColor.orange),
        ),
        title: Text(
          title,
          style: AppTheme.titleStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: LightColor.titleTextColor,
          ),
        ),
        subtitle: Text(subtitle, style: AppTheme.subTitleStyle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: LightColor.darkgrey,
        ),
      ),
    );
  }
}
