// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// // COURT DETAIL MODEL
// // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// class CourtDetailModel {
//   final String name;
//   final String location;
//   final String address;
//   final String price;
//   final double rating;
//   final int reviewCount;
//   final List<String> images;
//   final bool isOpen;
//   final String distance;
//   final List<String> features;
//   final String description;
//   final String hostedByName;
//   final String hostedByAvatar;
//   final String hostedSince;
//   final int hostedCourts;
//   final double responseRate;
//   final List<String> policies;
//   final List<String> rules;
//   final List<ReviewModel> reviews;
//   final String openTime;
//   final String closeTime;
//   final String courtType;
//   final String surfaceType;
//   final int maxPlayers;

//   const CourtDetailModel({
//     required this.name,
//     required this.location,
//     required this.address,
//     required this.price,
//     required this.rating,
//     required this.reviewCount,
//     required this.images,
//     required this.isOpen,
//     required this.distance,
//     required this.features,
//     required this.description,
//     required this.hostedByName,
//     required this.hostedByAvatar,
//     required this.hostedSince,
//     required this.hostedCourts,
//     required this.responseRate,
//     required this.policies,
//     required this.rules,
//     required this.reviews,
//     required this.openTime,
//     required this.closeTime,
//     required this.courtType,
//     required this.surfaceType,
//     required this.maxPlayers,
//   });
// }

// class ReviewModel {
//   final String name;
//   final String avatar;
//   final double rating;
//   final String date;
//   final String comment;

//   const ReviewModel({
//     required this.name,
//     required this.avatar,
//     required this.rating,
//     required this.date,
//     required this.comment,
//   });
// }

// class TimeSlotModel {
//   final String time;
//   final bool isAvailable;
//   final bool isSelected;
//   final String? price;

//   const TimeSlotModel({
//     required this.time,
//     this.isAvailable = true,
//     this.isSelected = false,
//     this.price,
//   });
// }

// // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// // DESIGN TOKENS
// // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// class _DS {
//   _DS._();

//   static const Color primary = Color(0xFF0D9E5C);
//   static const Color primaryDark = Color(0xFF087A45);
//   static const Color primaryLight = Color(0xFFE8F8F0);
//   static const Color primarySurface = Color(0xFFF0FDF4);
//   static const Color surface = Color(0xFFFFFFFF);
//   static const Color background = Color(0xFFF7F9FC);
//   static const Color textPrimary = Color(0xFF0F1923);
//   static const Color textSecondary = Color(0xFF6B7280);
//   static const Color textTertiary = Color(0xFF9CA3AF);
//   static const Color border = Color(0xFFE5E7EB);
//   static const Color borderLight = Color(0xFFF3F4F6);
//   static const Color divider = Color(0xFFF0F2F5);
//   static const Color orange = Color(0xFFF59E0B);
//   static const Color orangeLight = Color(0xFFFFF7ED);
//   static const Color blue = Color(0xFF3B82F6);
//   static const Color blueLight = Color(0xFFEFF6FF);
//   static const Color red = Color(0xFFEF4444);
//   static const Color redLight = Color(0xFFFEF2F2);
//   static const Color purple = Color(0xFF8B5CF6);
//   static const Color purpleLight = Color(0xFFFAF5FF);
//   static const Color yellow = Color(0xFFFBBF24);

//   static const LinearGradient primaryGradient = LinearGradient(
//     colors: [Color(0xFF0D9E5C), Color(0xFF059669)],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );

//   static const LinearGradient darkGradient = LinearGradient(
//     colors: [Color(0xFF111827), Color(0xFF1F2937)],
//     begin: Alignment.topCenter,
//     end: Alignment.bottomCenter,
//   );

//   static List<BoxShadow> shadowSm = [
//     BoxShadow(
//       color: Colors.black.withOpacity(0.04),
//       blurRadius: 8,
//       offset: const Offset(0, 2),
//     ),
//   ];

//   static List<BoxShadow> shadowMd = [
//     BoxShadow(
//       color: Colors.black.withOpacity(0.06),
//       blurRadius: 16,
//       offset: const Offset(0, 4),
//     ),
//   ];

//   static List<BoxShadow> shadowLg = [
//     BoxShadow(
//       color: Colors.black.withOpacity(0.1),
//       blurRadius: 30,
//       offset: const Offset(0, 10),
//     ),
//   ];

//   static List<BoxShadow> shadowPrimary = [
//     BoxShadow(
//       color: primary.withOpacity(0.35),
//       blurRadius: 20,
//       offset: const Offset(0, 8),
//     ),
//   ];
// }

// // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// // COURT DETAIL PAGE
// // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// class CourtDetailPage extends StatefulWidget {
//   final CourtDetailModel? court;

//   const CourtDetailPage({super.key, this.court});

//   @override
//   State<CourtDetailPage> createState() => _CourtDetailPageState();
// }

// class _CourtDetailPageState extends State<CourtDetailPage>
//     with TickerProviderStateMixin {
//   late final PageController _imagePageController;
//   late final AnimationController _bottomBarController;
//   late final Animation<Offset> _bottomBarSlide;

//   int _currentImageIndex = 0;
//   bool _isSaved = false;
//   int _selectedDateIndex = 0;
//   int _selectedSlotIndex = -1;
//   bool _showAllDescription = false;

//   // ── Sample Data ──
//   late final CourtDetailModel _court;

//   late final List<DateTime> _dates;

//   final List<List<TimeSlotModel>> _timeSlotsByDate = [];

//   @override
//   void initState() {
//     super.initState();

//     _court =
//         widget.court ??
//         CourtDetailModel(
//           name: 'Galaxy Futsal Arena',
//           location: 'Baneshwor, Kathmandu',
//           address: 'Galaxy Complex, New Baneshwor Road, Kathmandu 44600',
//           price: 'Rs 1,200',
//           rating: 4.8,
//           reviewCount: 234,
//           images: [
//             'https://images.unsplash.com/photo-1575361204480-aadea25e6e68?w=800',
//             'https://images.unsplash.com/photo-1551958219-acbc608c6377?w=800',
//             'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800',
//             'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800',
//           ],
//           isOpen: true,
//           distance: '1.2 km',
//           features: [
//             'Indoor',
//             'Floodlight',
//             'Parking',
//             'Changing Room',
//             'Cafeteria',
//             'First Aid',
//           ],
//           description:
//               'Galaxy Futsal Arena is a premium indoor futsal facility located in the heart of Kathmandu. Our state-of-the-art synthetic turf provides the perfect playing surface for both casual and competitive matches. The arena features professional-grade floodlighting, comfortable changing rooms, and a fully stocked cafeteria. Whether you\'re organizing a friendly match or a tournament, Galaxy Futsal Arena delivers an exceptional experience every time.',
//           hostedByName: 'Rajesh Hamal',
//           hostedByAvatar: '',
//           hostedSince: 'Jan 2021',
//           hostedCourts: 3,
//           responseRate: 98,
//           policies: [
//             'Free cancellation up to 24 hours before the booking',
//             'Full refund for weather-related cancellations',
//             'Shoes must be non-marking indoor type',
//             'Maximum 14 players per session',
//             'Equipment rental available at the venue',
//           ],
//           rules: [
//             'No metal studs or outdoor shoes allowed',
//             'Players must wear shin guards',
//             'No smoking inside the arena premises',
//             'Respect other players and staff',
//             'Report any damage to the facility immediately',
//             'No food or drinks on the playing surface',
//           ],
//           reviews: const [
//             ReviewModel(
//               name: 'Suman Thapa',
//               avatar: '',
//               rating: 5.0,
//               date: '2 days ago',
//               comment:
//                   'Amazing facility! The turf quality is top-notch and the lighting is perfect for evening games. Highly recommended!',
//             ),
//             ReviewModel(
//               name: 'Anita Gurung',
//               avatar: '',
//               rating: 4.5,
//               date: '1 week ago',
//               comment:
//                   'Great place to play. Clean changing rooms and friendly staff. Only wish they had more parking space.',
//             ),
//             ReviewModel(
//               name: 'Bikram Shah',
//               avatar: '',
//               rating: 5.0,
//               date: '2 weeks ago',
//               comment:
//                   'Best futsal in Kathmandu. Period. We play here every weekend and it never disappoints.',
//             ),
//           ],
//           openTime: '6:00 AM',
//           closeTime: '10:00 PM',
//           courtType: 'Indoor',
//           surfaceType: 'Synthetic Turf',
//           maxPlayers: 14,
//         );

//     _imagePageController = PageController();

//     _bottomBarController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _bottomBarSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _bottomBarController,
//             curve: Curves.easeOutCubic,
//           ),
//         );

//     _dates = List.generate(14, (i) => DateTime.now().add(Duration(days: i)));

//     for (int d = 0; d < 14; d++) {
//       _timeSlotsByDate.add([
//         TimeSlotModel(time: '6:00 AM', isAvailable: d != 0),
//         const TimeSlotModel(time: '7:00 AM'),
//         TimeSlotModel(time: '8:00 AM', isAvailable: d % 2 == 0),
//         const TimeSlotModel(time: '9:00 AM'),
//         TimeSlotModel(time: '10:00 AM', isAvailable: d % 3 != 0),
//         const TimeSlotModel(time: '11:00 AM', isAvailable: false),
//         const TimeSlotModel(time: '12:00 PM', isAvailable: false),
//         const TimeSlotModel(time: '1:00 PM'),
//         TimeSlotModel(time: '2:00 PM', isAvailable: d != 1),
//         const TimeSlotModel(time: '3:00 PM'),
//         const TimeSlotModel(time: '4:00 PM'),
//         TimeSlotModel(time: '5:00 PM', isAvailable: d % 2 != 0),
//         const TimeSlotModel(time: '6:00 PM'),
//         TimeSlotModel(time: '7:00 PM', isAvailable: d != 2),
//         const TimeSlotModel(time: '8:00 PM'),
//         const TimeSlotModel(time: '9:00 PM'),
//       ]);
//     }

//     Future.delayed(const Duration(milliseconds: 400), () {
//       if (mounted) _bottomBarController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _imagePageController.dispose();
//     _bottomBarController.dispose();
//     super.dispose();
//   }

//   // ── Helpers ──
//   String _dayName(DateTime date) {
//     const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
//     return days[date.weekday - 1];
//   }

//   String _monthName(DateTime date) {
//     const months = [
//       'Jan',
//       'Feb',
//       'Mar',
//       'Apr',
//       'May',
//       'Jun',
//       'Jul',
//       'Aug',
//       'Sep',
//       'Oct',
//       'Nov',
//       'Dec',
//     ];
//     return months[date.month - 1];
//   }

//   bool _isToday(DateTime date) {
//     final now = DateTime.now();
//     return date.day == now.day &&
//         date.month == now.month &&
//         date.year == now.year;
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // IMAGE GALLERY
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildImageGallery() {
//     return SizedBox(
//       height: 340,
//       child: Stack(
//         children: [
//           // ── Swipeable images ──
//           PageView.builder(
//             controller: _imagePageController,
//             itemCount: _court.images.length,
//             onPageChanged: (i) => setState(() => _currentImageIndex = i),
//             itemBuilder: (context, index) {
//               return Stack(
//                 fit: StackFit.expand,
//                 children: [
//                   Image.network(
//                     _court.images[index],
//                     fit: BoxFit.cover,
//                     loadingBuilder: (_, child, progress) {
//                       if (progress == null) return child;
//                       return Container(
//                         color: _DS.borderLight,
//                         child: Center(
//                           child: CircularProgressIndicator(
//                             value: progress.expectedTotalBytes != null
//                                 ? progress.cumulativeBytesLoaded /
//                                       progress.expectedTotalBytes!
//                                 : null,
//                             strokeWidth: 2,
//                             color: _DS.primary,
//                           ),
//                         ),
//                       );
//                     },
//                     errorBuilder: (_, __, ___) => Container(
//                       color: _DS.borderLight,
//                       child: const Icon(
//                         Icons.sports_soccer_rounded,
//                         size: 60,
//                         color: _DS.border,
//                       ),
//                     ),
//                   ),
//                   // Bottom gradient overlay
//                   Positioned(
//                     bottom: 0,
//                     left: 0,
//                     right: 0,
//                     height: 120,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withOpacity(0.5),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),

//           // ── Back + Share buttons ──
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             left: 16,
//             right: 16,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _glassButton(
//                   icon: Icons.arrow_back_rounded,
//                   onTap: () => Navigator.of(context).pop(),
//                 ),
//                 Row(
//                   children: [
//                     _glassButton(icon: Icons.share_outlined, onTap: () {}),
//                     const SizedBox(width: 10),
//                     _glassButton(
//                       icon: _isSaved
//                           ? Icons.favorite_rounded
//                           : Icons.favorite_border_rounded,
//                       iconColor: _isSaved ? _DS.red : Colors.white,
//                       onTap: () {
//                         HapticFeedback.lightImpact();
//                         setState(() => _isSaved = !_isSaved);
//                       },
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),

//           // ── Page indicator + count ──
//           Positioned(
//             bottom: 16,
//             left: 16,
//             right: 16,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // Dots
//                 Row(
//                   children: List.generate(_court.images.length, (i) {
//                     final active = i == _currentImageIndex;
//                     return AnimatedContainer(
//                       duration: const Duration(milliseconds: 300),
//                       margin: const EdgeInsets.only(right: 6),
//                       width: active ? 24 : 8,
//                       height: 8,
//                       decoration: BoxDecoration(
//                         color: active
//                             ? Colors.white
//                             : Colors.white.withOpacity(0.4),
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                     );
//                   }),
//                 ),
//                 // Count badge
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.35),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: Colors.white.withOpacity(0.15),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(
//                             Icons.photo_library_outlined,
//                             color: Colors.white,
//                             size: 14,
//                           ),
//                           const SizedBox(width: 5),
//                           Text(
//                             '${_currentImageIndex + 1}/${_court.images.length}',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _glassButton({
//     required IconData icon,
//     required VoidCallback onTap,
//     Color iconColor = Colors.white,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(14),
//         child: BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//           child: Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.25),
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: Colors.white.withOpacity(0.15)),
//             ),
//             child: Icon(icon, color: iconColor, size: 22),
//           ),
//         ),
//       ),
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // HEADER INFO
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildHeaderInfo() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Status + Type
//           Row(
//             children: [
//               _statusPill(_court.isOpen),
//               const SizedBox(width: 8),
//               _chipTag(
//                 _court.courtType,
//                 Icons.stadium_outlined,
//                 _DS.blue,
//                 _DS.blueLight,
//               ),
//               const SizedBox(width: 8),
//               _chipTag(
//                 _court.surfaceType,
//                 Icons.grass_rounded,
//                 _DS.primary,
//                 _DS.primaryLight,
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),

//           // Name
//           Text(
//             _court.name,
//             style: const TextStyle(
//               color: _DS.textPrimary,
//               fontSize: 26,
//               fontWeight: FontWeight.w900,
//               letterSpacing: -0.8,
//               height: 1.15,
//             ),
//           ),
//           const SizedBox(height: 10),

//           // Location
//           Row(
//             children: [
//               Container(
//                 width: 32,
//                 height: 32,
//                 decoration: BoxDecoration(
//                   color: _DS.primaryLight,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.location_on_rounded,
//                   color: _DS.primary,
//                   size: 16,
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       _court.location,
//                       style: const TextStyle(
//                         color: _DS.textPrimary,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     Text(
//                       _court.address,
//                       style: const TextStyle(
//                         color: _DS.textTertiary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Distance badge
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: _DS.borderLight,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.near_me_rounded,
//                       size: 12,
//                       color: _DS.textSecondary,
//                     ),
//                     const SizedBox(width: 4),
//                     Text(
//                       _court.distance,
//                       style: const TextStyle(
//                         color: _DS.textSecondary,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),

//           // Rating + Review + Time
//           _buildStatsBar(),
//         ],
//       ),
//     );
//   }

//   Widget _statusPill(bool isOpen) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: isOpen ? _DS.primaryLight : _DS.redLight,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: isOpen
//               ? _DS.primary.withOpacity(0.25)
//               : _DS.red.withOpacity(0.25),
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 6,
//             height: 6,
//             decoration: BoxDecoration(
//               color: isOpen ? _DS.primary : _DS.red,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Text(
//             isOpen ? 'Open Now' : 'Closed',
//             style: TextStyle(
//               color: isOpen ? _DS.primary : _DS.red,
//               fontSize: 11.5,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _chipTag(String text, IconData icon, Color color, Color bg) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: color),
//           const SizedBox(width: 5),
//           Text(
//             text,
//             style: TextStyle(
//               color: color,
//               fontSize: 11.5,
//               fontWeight: FontWeight.w700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsBar() {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: _DS.borderLight.withOpacity(0.6),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _DS.border.withOpacity(0.5)),
//       ),
//       child: Row(
//         children: [
//           _statItem(
//             Icons.star_rounded,
//             _DS.yellow,
//             '${_court.rating}',
//             '${_court.reviewCount} reviews',
//           ),
//           _statDivider(),
//           _statItem(
//             Icons.schedule_rounded,
//             _DS.blue,
//             _court.openTime,
//             'to ${_court.closeTime}',
//           ),
//           _statDivider(),
//           _statItem(
//             Icons.groups_rounded,
//             _DS.purple,
//             '${_court.maxPlayers}',
//             'max players',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statItem(IconData icon, Color color, String value, String label) {
//     return Expanded(
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: const TextStyle(
//               color: _DS.textPrimary,
//               fontSize: 15,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 2),
//           Text(
//             label,
//             style: const TextStyle(
//               color: _DS.textTertiary,
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _statDivider() {
//     return Container(
//       width: 1,
//       height: 40,
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       color: _DS.border,
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // FEATURES
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildFeatures() {
//     final featureIcons = <String, IconData>{
//       'Indoor': Icons.house_rounded,
//       'Outdoor': Icons.park_rounded,
//       'Floodlight': Icons.lightbulb_rounded,
//       'Parking': Icons.local_parking_rounded,
//       'Changing Room': Icons.checkroom_rounded,
//       'Cafeteria': Icons.local_cafe_rounded,
//       'First Aid': Icons.medical_services_rounded,
//       'WiFi': Icons.wifi_rounded,
//       'AC': Icons.ac_unit_rounded,
//     };

//     final featureColors = <String, Color>{
//       'Indoor': _DS.blue,
//       'Outdoor': _DS.primary,
//       'Floodlight': _DS.orange,
//       'Parking': _DS.purple,
//       'Changing Room': const Color(0xFF06B6D4),
//       'Cafeteria': const Color(0xFFEC4899),
//       'First Aid': _DS.red,
//       'WiFi': _DS.blue,
//       'AC': const Color(0xFF06B6D4),
//     };

//     return _sectionWrapper(
//       title: 'Amenities & Features',
//       child: Wrap(
//         spacing: 10,
//         runSpacing: 10,
//         children: _court.features.map((f) {
//           final icon = featureIcons[f] ?? Icons.check_circle_outline_rounded;
//           final color = featureColors[f] ?? _DS.primary;
//           return Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: color.withOpacity(0.15)),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, size: 16, color: color),
//                 const SizedBox(width: 8),
//                 Text(
//                   f,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // DESCRIPTION
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildDescription() {
//     const maxChars = 180;
//     final isLong = _court.description.length > maxChars;
//     final displayText = _showAllDescription || !isLong
//         ? _court.description
//         : '${_court.description.substring(0, maxChars)}...';

//     return _sectionWrapper(
//       title: 'About This Court',
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AnimatedCrossFade(
//             firstChild: Text(
//               '${_court.description.substring(0, maxChars)}...',
//               style: const TextStyle(
//                 color: _DS.textSecondary,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//                 height: 1.65,
//               ),
//             ),
//             secondChild: Text(
//               _court.description,
//               style: const TextStyle(
//                 color: _DS.textSecondary,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//                 height: 1.65,
//               ),
//             ),
//             crossFadeState: _showAllDescription
//                 ? CrossFadeState.showSecond
//                 : CrossFadeState.showFirst,
//             duration: const Duration(milliseconds: 300),
//           ),
//           if (isLong) ...[
//             const SizedBox(height: 8),
//             GestureDetector(
//               onTap: () =>
//                   setState(() => _showAllDescription = !_showAllDescription),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     _showAllDescription ? 'Show less' : 'Read more',
//                     style: const TextStyle(
//                       color: _DS.primary,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   const SizedBox(width: 4),
//                   Icon(
//                     _showAllDescription
//                         ? Icons.keyboard_arrow_up_rounded
//                         : Icons.keyboard_arrow_down_rounded,
//                     color: _DS.primary,
//                     size: 18,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // DATE & TIME SLOTS
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildTimeSlots() {
//     final slots = _timeSlotsByDate[_selectedDateIndex];

//     return _sectionWrapper(
//       title: 'Select Date & Time',
//       trailing: _chipTag(
//         '${_court.openTime} – ${_court.closeTime}',
//         Icons.schedule_rounded,
//         _DS.blue,
//         _DS.blueLight,
//       ),
//       child: Column(
//         children: [
//           // ── Date selector ──
//           SizedBox(
//             height: 80,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               physics: const BouncingScrollPhysics(),
//               itemCount: _dates.length,
//               itemBuilder: (context, i) {
//                 final date = _dates[i];
//                 final selected = _selectedDateIndex == i;
//                 final today = _isToday(date);

//                 return GestureDetector(
//                   onTap: () {
//                     HapticFeedback.selectionClick();
//                     setState(() {
//                       _selectedDateIndex = i;
//                       _selectedSlotIndex = -1;
//                     });
//                   },
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 250),
//                     width: 60,
//                     margin: const EdgeInsets.only(right: 10),
//                     decoration: BoxDecoration(
//                       gradient: selected ? _DS.primaryGradient : null,
//                       color: selected ? null : _DS.surface,
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: selected
//                             ? Colors.transparent
//                             : today
//                             ? _DS.primary.withOpacity(0.3)
//                             : _DS.border,
//                         width: 1.5,
//                       ),
//                       boxShadow: selected ? _DS.shadowPrimary : _DS.shadowSm,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           _dayName(date),
//                           style: TextStyle(
//                             color: selected ? Colors.white70 : _DS.textTertiary,
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '${date.day}',
//                           style: TextStyle(
//                             color: selected ? Colors.white : _DS.textPrimary,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w800,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           today ? 'Today' : _monthName(date),
//                           style: TextStyle(
//                             color: selected
//                                 ? Colors.white70
//                                 : today
//                                 ? _DS.primary
//                                 : _DS.textTertiary,
//                             fontSize: 10,
//                             fontWeight: today
//                                 ? FontWeight.w700
//                                 : FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 18),

//           // ── Legend ──
//           Row(
//             children: [
//               _slotLegend(_DS.primaryLight, _DS.primary, 'Available'),
//               const SizedBox(width: 14),
//               _slotLegend(_DS.primary, Colors.white, 'Selected'),
//               const SizedBox(width: 14),
//               _slotLegend(_DS.borderLight, _DS.textTertiary, 'Booked'),
//             ],
//           ),
//           const SizedBox(height: 14),

//           // ── Time slots grid ──
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               mainAxisSpacing: 10,
//               crossAxisSpacing: 10,
//               childAspectRatio: 2.2,
//             ),
//             itemCount: slots.length,
//             itemBuilder: (context, i) {
//               final slot = slots[i];
//               final selected = _selectedSlotIndex == i;

//               return GestureDetector(
//                 onTap: slot.isAvailable
//                     ? () {
//                         HapticFeedback.selectionClick();
//                         setState(() => _selectedSlotIndex = selected ? -1 : i);
//                       }
//                     : null,
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 200),
//                   decoration: BoxDecoration(
//                     gradient: selected ? _DS.primaryGradient : null,
//                     color: selected
//                         ? null
//                         : slot.isAvailable
//                         ? _DS.primaryLight.withOpacity(0.5)
//                         : _DS.borderLight,
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: selected
//                           ? Colors.transparent
//                           : slot.isAvailable
//                           ? _DS.primary.withOpacity(0.2)
//                           : _DS.border.withOpacity(0.5),
//                       width: 1,
//                     ),
//                     boxShadow: selected ? _DS.shadowPrimary : null,
//                   ),
//                   child: Center(
//                     child: Text(
//                       slot.time,
//                       style: TextStyle(
//                         color: selected
//                             ? Colors.white
//                             : slot.isAvailable
//                             ? _DS.textPrimary
//                             : _DS.textTertiary,
//                         fontSize: 12,
//                         fontWeight: selected
//                             ? FontWeight.w800
//                             : FontWeight.w600,
//                         decoration: slot.isAvailable
//                             ? null
//                             : TextDecoration.lineThrough,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _slotLegend(Color bg, Color textColor, String label) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 14,
//           height: 14,
//           decoration: BoxDecoration(
//             color: bg,
//             borderRadius: BorderRadius.circular(4),
//             border: Border.all(color: _DS.border.withOpacity(0.5)),
//           ),
//         ),
//         const SizedBox(width: 6),
//         Text(
//           label,
//           style: const TextStyle(
//             color: _DS.textTertiary,
//             fontSize: 11,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // HOSTED BY
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildHostedBy() {
//     return _sectionWrapper(
//       title: 'Hosted By',
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: _DS.surface,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: _DS.border.withOpacity(0.6)),
//           boxShadow: _DS.shadowSm,
//         ),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 // Avatar
//                 Container(
//                   width: 52,
//                   height: 52,
//                   decoration: BoxDecoration(
//                     gradient: _DS.primaryGradient,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: _DS.primary.withOpacity(0.25),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Center(
//                     child: Text(
//                       _court.hostedByName.substring(0, 1),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 22,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 14),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Text(
//                             _court.hostedByName,
//                             style: const TextStyle(
//                               color: _DS.textPrimary,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w800,
//                             ),
//                           ),
//                           const SizedBox(width: 6),
//                           Container(
//                             padding: const EdgeInsets.all(2),
//                             decoration: const BoxDecoration(
//                               color: _DS.primary,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.check_rounded,
//                               color: Colors.white,
//                               size: 10,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         'Hosting since ${_court.hostedSince}',
//                         style: const TextStyle(
//                           color: _DS.textTertiary,
//                           fontSize: 12.5,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // Contact
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(
//                     color: _DS.primaryLight,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.chat_bubble_outline_rounded,
//                     color: _DS.primary,
//                     size: 19,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),
//             const Divider(color: _DS.divider, height: 1),
//             const SizedBox(height: 14),
//             Row(
//               children: [
//                 _hostStat(
//                   '${_court.hostedCourts}',
//                   'Courts',
//                   Icons.sports_soccer_rounded,
//                 ),
//                 _hostStatDivider(),
//                 _hostStat(
//                   '${_court.responseRate.toInt()}%',
//                   'Response',
//                   Icons.flash_on_rounded,
//                 ),
//                 _hostStatDivider(),
//                 _hostStat('${_court.rating}', 'Rating', Icons.star_rounded),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _hostStat(String value, String label, IconData icon) {
//     return Expanded(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 16, color: _DS.primary.withOpacity(0.6)),
//           const SizedBox(width: 6),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 value,
//                 style: const TextStyle(
//                   color: _DS.textPrimary,
//                   fontSize: 14,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: _DS.textTertiary,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _hostStatDivider() {
//     return Container(width: 1, height: 32, color: _DS.divider);
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // POLICIES
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildPolicies() {
//     return _sectionWrapper(
//       title: 'Booking Policies',
//       icon: Icons.policy_outlined,
//       iconColor: _DS.blue,
//       child: Column(
//         children: _court.policies.asMap().entries.map((entry) {
//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: entry.key < _court.policies.length - 1 ? 12 : 0,
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: _DS.blueLight,
//                     borderRadius: BorderRadius.circular(7),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${entry.key + 1}',
//                       style: const TextStyle(
//                         color: _DS.blue,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     entry.value,
//                     style: const TextStyle(
//                       color: _DS.textSecondary,
//                       fontSize: 13.5,
//                       fontWeight: FontWeight.w400,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // RULES
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildRules() {
//     return _sectionWrapper(
//       title: 'Court Rules',
//       icon: Icons.gavel_rounded,
//       iconColor: _DS.orange,
//       child: Column(
//         children: _court.rules.asMap().entries.map((entry) {
//           return Padding(
//             padding: EdgeInsets.only(
//               bottom: entry.key < _court.rules.length - 1 ? 10 : 0,
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 22,
//                   height: 22,
//                   decoration: BoxDecoration(
//                     color: _DS.orangeLight,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: const Icon(
//                     Icons.warning_amber_rounded,
//                     size: 13,
//                     color: _DS.orange,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     entry.value,
//                     style: const TextStyle(
//                       color: _DS.textSecondary,
//                       fontSize: 13.5,
//                       fontWeight: FontWeight.w400,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // REVIEWS
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildReviews() {
//     return _sectionWrapper(
//       title: 'Reviews',
//       trailing: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         decoration: BoxDecoration(
//           color: _DS.primaryLight,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           'See All (${_court.reviewCount})',
//           style: const TextStyle(
//             color: _DS.primary,
//             fontSize: 11.5,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ),
//       child: Column(
//         children: [
//           // Overall rating card
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               gradient: _DS.primaryGradient,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: _DS.shadowPrimary,
//             ),
//             child: Row(
//               children: [
//                 Column(
//                   children: [
//                     Text(
//                       '${_court.rating}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 40,
//                         fontWeight: FontWeight.w900,
//                         letterSpacing: -1,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: List.generate(5, (i) {
//                         return Icon(
//                           i < _court.rating.floor()
//                               ? Icons.star_rounded
//                               : i < _court.rating
//                               ? Icons.star_half_rounded
//                               : Icons.star_outline_rounded,
//                           color: Colors.white,
//                           size: 16,
//                         );
//                       }),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       '${_court.reviewCount} reviews',
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.75),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(width: 24),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       _ratingBar('5', 0.72),
//                       _ratingBar('4', 0.18),
//                       _ratingBar('3', 0.07),
//                       _ratingBar('2', 0.02),
//                       _ratingBar('1', 0.01),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),

//           // Review items
//           ...(_court.reviews.map((r) => _buildReviewItem(r))),
//         ],
//       ),
//     );
//   }

//   Widget _ratingBar(String label, double value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 5),
//       child: Row(
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.7),
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: value,
//                 backgroundColor: Colors.white.withOpacity(0.15),
//                 color: Colors.white,
//                 minHeight: 5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReviewItem(ReviewModel review) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _DS.surface,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _DS.border.withOpacity(0.5)),
//         boxShadow: _DS.shadowSm,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               // Avatar
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: _DS.primaryLight,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Center(
//                   child: Text(
//                     review.name.substring(0, 1),
//                     style: const TextStyle(
//                       color: _DS.primary,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w800,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       review.name,
//                       style: const TextStyle(
//                         color: _DS.textPrimary,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                       ),
//                     ),
//                     Text(
//                       review.date,
//                       style: const TextStyle(
//                         color: _DS.textTertiary,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Stars
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: _DS.primaryLight,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.star_rounded,
//                       color: _DS.primary,
//                       size: 14,
//                     ),
//                     const SizedBox(width: 3),
//                     Text(
//                       '${review.rating}',
//                       style: const TextStyle(
//                         color: _DS.primary,
//                         fontSize: 12.5,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             review.comment,
//             style: const TextStyle(
//               color: _DS.textSecondary,
//               fontSize: 13.5,
//               fontWeight: FontWeight.w400,
//               height: 1.55,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // BOTTOM BOOKING BAR
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _buildBottomBar() {
//     final hasSelection = _selectedSlotIndex >= 0;
//     final selectedTime = hasSelection
//         ? _timeSlotsByDate[_selectedDateIndex][_selectedSlotIndex].time
//         : null;
//     final selectedDate = _dates[_selectedDateIndex];

//     return SlideTransition(
//       position: _bottomBarSlide,
//       child: Container(
//         padding: EdgeInsets.fromLTRB(
//           20,
//           16,
//           20,
//           MediaQuery.of(context).padding.bottom + 16,
//         ),
//         decoration: BoxDecoration(
//           color: _DS.surface,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.08),
//               blurRadius: 30,
//               offset: const Offset(0, -8),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             // Price info
//             Expanded(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (hasSelection)
//                     Text(
//                       '${_dayName(selectedDate)}, ${selectedDate.day} ${_monthName(selectedDate)} · $selectedTime',
//                       style: const TextStyle(
//                         color: _DS.textTertiary,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     )
//                   else
//                     const Text(
//                       'Select a time slot',
//                       style: TextStyle(
//                         color: _DS.textTertiary,
//                         fontSize: 11.5,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   const SizedBox(height: 4),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Text(
//                         _court.price,
//                         style: const TextStyle(
//                           color: _DS.textPrimary,
//                           fontSize: 24,
//                           fontWeight: FontWeight.w900,
//                           letterSpacing: -0.5,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       const Padding(
//                         padding: EdgeInsets.only(bottom: 3),
//                         child: Text(
//                           '/ hour',
//                           style: TextStyle(
//                             color: _DS.textTertiary,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 16),
//             // Book button
//             GestureDetector(
//               onTap: hasSelection
//                   ? () {
//                       HapticFeedback.mediumImpact();
//                       // Handle booking
//                     }
//                   : null,
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 28,
//                   vertical: 16,
//                 ),
//                 decoration: BoxDecoration(
//                   gradient: hasSelection ? _DS.primaryGradient : null,
//                   color: hasSelection ? null : _DS.border,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: hasSelection ? _DS.shadowPrimary : null,
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(
//                       Icons.flash_on_rounded,
//                       color: hasSelection ? Colors.white : _DS.textTertiary,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Book Now',
//                       style: TextStyle(
//                         color: hasSelection ? Colors.white : _DS.textTertiary,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // SECTION WRAPPER
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   Widget _sectionWrapper({
//     required String title,
//     required Widget child,
//     Widget? trailing,
//     IconData? icon,
//     Color? iconColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 28),
//           Row(
//             children: [
//               if (icon != null) ...[
//                 Container(
//                   width: 28,
//                   height: 28,
//                   decoration: BoxDecoration(
//                     color: (iconColor ?? _DS.primary).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, size: 15, color: iconColor ?? _DS.primary),
//                 ),
//                 const SizedBox(width: 10),
//               ],
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     color: _DS.textPrimary,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w800,
//                     letterSpacing: -0.3,
//                   ),
//                 ),
//               ),
//               if (trailing != null) trailing,
//             ],
//           ),
//           const SizedBox(height: 16),
//           child,
//         ],
//       ),
//     );
//   }

//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   // BUILD
//   // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light.copyWith(
//         statusBarColor: Colors.transparent,
//       ),
//       child: Scaffold(
//         backgroundColor: _DS.background,
//         body: Stack(
//           children: [
//             // ── Scrollable content ──
//             CustomScrollView(
//               physics: const BouncingScrollPhysics(),
//               slivers: [
//                 // Image gallery (not a sliver app bar for cleaner control)
//                 SliverToBoxAdapter(child: _buildImageGallery()),

//                 // All content sections
//                 SliverToBoxAdapter(
//                   child: Container(
//                     decoration: const BoxDecoration(
//                       color: _DS.background,
//                       borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(28),
//                       ),
//                     ),
//                     transform: Matrix4.translationValues(0, -24, 0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Drag handle
//                         Center(
//                           child: Container(
//                             margin: const EdgeInsets.only(top: 12, bottom: 4),
//                             width: 40,
//                             height: 4,
//                             decoration: BoxDecoration(
//                               color: _DS.border,
//                               borderRadius: BorderRadius.circular(100),
//                             ),
//                           ),
//                         ),

//                         _buildHeaderInfo(),
//                         _buildFeatures(),
//                         _buildDescription(),

//                         // Divider
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 20),
//                           child: Divider(color: _DS.divider, height: 40),
//                         ),

//                         _buildTimeSlots(),
//                         _buildHostedBy(),
//                         _buildPolicies(),
//                         _buildRules(),
//                         _buildReviews(),

//                         // Bottom spacing for the bar
//                         SizedBox(
//                           height: MediaQuery.of(context).padding.bottom + 100,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             // ── Bottom booking bar ──
//             Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),
//           ],
//         ),
//       ),
//     );
//   }
// }
