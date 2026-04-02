// import 'dart:ui';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hamro_footsall/core/routers/app_router_params.dart';
// import 'package:hamro_footsall/core/theme/light_color.dart';

// class VendorOnboardingPage extends StatefulWidget {
//   const VendorOnboardingPage({super.key});

//   @override
//   State<VendorOnboardingPage> createState() => _VendorOnboardingPageState();
// }

// class _VendorOnboardingPageState extends State<VendorOnboardingPage>
//     with TickerProviderStateMixin {
//   late final AnimationController _pageController;
//   late final Animation<double> _fadeAnimation;
//   late final Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _pageController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );

//     _fadeAnimation = CurvedAnimation(
//       parent: _pageController,
//       curve: Curves.easeOutCubic,
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
//           CurvedAnimation(parent: _pageController, curve: Curves.easeOutCubic),
//         );

//     _pageController.forward();
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).padding.bottom;

//     return Scaffold(
//       backgroundColor: LightColor.background,
//       body: Stack(
//         children: [
//           const _BackgroundDecorations(),
//           SafeArea(
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: SlideTransition(
//                 position: _slideAnimation,
//                 child: CustomScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   slivers: [
//                     SliverToBoxAdapter(
//                       child: Padding(
//                         padding: const EdgeInsets.fromLTRB(20, 18, 20, 140),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: const [
//                             _TopHeader(),
//                             SizedBox(height: 20),
//                             _PremiumHeroCard(),
//                             SizedBox(height: 24),
//                             _QuickStatsRow(),
//                             SizedBox(height: 28),
//                             _SectionTitle(
//                               title: 'Simple onboarding flow',
//                               subtitle:
//                                   'Set up your futsal venue and start receiving bookings in minutes.',
//                             ),
//                             SizedBox(height: 16),
//                             _StepCardsSection(),
//                             SizedBox(height: 28),
//                             _SectionTitle(
//                               title: 'Why partners love Hamro Futsal',
//                               subtitle:
//                                   'Everything you need to manage courts, bookings, and customers in one place.',
//                             ),
//                             SizedBox(height: 16),
//                             _BenefitGrid(),
//                             SizedBox(height: 28),
//                             _SectionTitle(
//                               title: 'What you can manage',
//                               subtitle:
//                                   'From venue information to court scheduling and online payments.',
//                             ),
//                             SizedBox(height: 16),
//                             _ManagementHighlights(),
//                             SizedBox(height: 28),
//                             _TrustBanner(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),

//           // Sticky bottom CTA
//           Positioned(
//             left: 16,
//             right: 16,
//             bottom: 16 + bottomPadding,
//             child: _BottomCta(
//               onPressed: () {
//                 context.pushNamed(AppRouterParams.vendorStepper.name);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BackgroundDecorations extends StatelessWidget {
//   const _BackgroundDecorations();

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Positioned(
//           top: -70,
//           right: -30,
//           child: Container(
//             width: 220,
//             height: 220,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: LightColor.secondary.withValues(alpha: 0.09),
//             ),
//           ),
//         ),
//         Positioned(
//           top: 180,
//           left: -50,
//           child: Container(
//             width: 160,
//             height: 160,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: LightColor.primary.withValues(alpha: 0.08),
//             ),
//           ),
//         ),
//         Positioned(
//           bottom: 140,
//           right: -40,
//           child: Container(
//             width: 180,
//             height: 180,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: LightColor.amber.withValues(alpha: 0.08),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _TopHeader extends StatelessWidget {
//   const _TopHeader();

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 46,
//           height: 46,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [LightColor.secondary, LightColor.secondaryDark],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: LightColor.secondary.withValues(alpha: 0.28),
//                 blurRadius: 18,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: const Icon(
//             Icons.storefront_rounded,
//             color: LightColor.white,
//             size: 24,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Vendor Onboarding',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                   color: LightColor.titleText,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 'Grow your futsal business with us',
//                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: LightColor.subtitleText,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
//           decoration: BoxDecoration(
//             color: LightColor.secondaryLight,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: LightColor.successBorder),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Icon(
//                 Icons.verified_rounded,
//                 size: 16,
//                 color: LightColor.secondary,
//               ),
//               SizedBox(width: 6),
//               Text(
//                 'Trusted',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w700,
//                   color: LightColor.secondaryDark,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _PremiumHeroCard extends StatelessWidget {
//   const _PremiumHeroCard();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(22),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         gradient: LinearGradient(
//           colors: [
//             LightColor.secondary,
//             LightColor.secondaryDark,
//             LightColor.accent,
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: LightColor.secondary.withValues(alpha: 0.28),
//             blurRadius: 28,
//             offset: const Offset(0, 18),
//           ),
//         ],
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             right: -10,
//             top: -10,
//             child: Container(
//               width: 110,
//               height: 110,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: LightColor.white.withValues(alpha: 0.08),
//               ),
//             ),
//           ),
//           Positioned(
//             bottom: -20,
//             left: -10,
//             child: Container(
//               width: 95,
//               height: 95,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: LightColor.white.withValues(alpha: 0.06),
//               ),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: const [
//                   _HeroIconBox(icon: Icons.stadium_rounded, isLarge: false),
//                   SizedBox(width: 10),
//                   _HeroIconBox(
//                     icon: Icons.sports_soccer_rounded,
//                     isLarge: true,
//                   ),
//                   SizedBox(width: 10),
//                   _HeroIconBox(
//                     icon: Icons.calendar_month_rounded,
//                     isLarge: false,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 22),
//               Text(
//                 'Turn your futsal venue into a booking powerhouse',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   color: LightColor.white,
//                   fontWeight: FontWeight.w800,
//                   height: 1.15,
//                   letterSpacing: -0.4,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 'Create your venue, add courts, manage schedules, and accept online bookings — all from one beautiful dashboard.',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: LightColor.white.withValues(alpha: 0.90),
//                   height: 1.55,
//                 ),
//               ),
//               const SizedBox(height: 18),
//               Wrap(
//                 spacing: 10,
//                 runSpacing: 10,
//                 children: const [
//                   _HeroChip(icon: Icons.flash_on_rounded, label: 'Fast setup'),
//                   _HeroChip(
//                     icon: Icons.payments_rounded,
//                     label: 'Secure payments',
//                   ),
//                   _HeroChip(
//                     icon: Icons.bar_chart_rounded,
//                     label: 'More bookings',
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _HeroIconBox extends StatelessWidget {
//   const _HeroIconBox({required this.icon, required this.isLarge});

//   final IconData icon;
//   final bool isLarge;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: isLarge ? 62 : 50,
//       height: isLarge ? 62 : 50,
//       decoration: BoxDecoration(
//         color: LightColor.white.withValues(alpha: isLarge ? 0.18 : 0.12),
//         borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
//         border: Border.all(color: LightColor.white.withValues(alpha: 0.12)),
//       ),
//       child: Icon(icon, color: LightColor.white, size: isLarge ? 30 : 24),
//     );
//   }
// }

// class _HeroChip extends StatelessWidget {
//   const _HeroChip({required this.icon, required this.label});

//   final IconData icon;
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(100),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
//           decoration: BoxDecoration(
//             color: LightColor.white.withValues(alpha: 0.10),
//             borderRadius: BorderRadius.circular(100),
//             border: Border.all(color: LightColor.white.withValues(alpha: 0.14)),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, color: LightColor.white, size: 16),
//               const SizedBox(width: 8),
//               Text(
//                 label,
//                 style: const TextStyle(
//                   color: LightColor.white,
//                   fontSize: 12.5,
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

// class _QuickStatsRow extends StatelessWidget {
//   const _QuickStatsRow();

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: const [
//         Expanded(
//           child: _MiniStatCard(
//             icon: Icons.store_mall_directory_rounded,
//             value: '1 Venue',
//             label: 'Create property',
//           ),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: _MiniStatCard(
//             icon: Icons.grid_view_rounded,
//             value: 'Multi Court',
//             label: 'Add courts',
//           ),
//         ),
//         SizedBox(width: 12),
//         Expanded(
//           child: _MiniStatCard(
//             icon: Icons.calendar_today_rounded,
//             value: '24/7',
//             label: 'Booking access',
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _MiniStatCard extends StatelessWidget {
//   const _MiniStatCard({
//     required this.icon,
//     required this.value,
//     required this.label,
//   });

//   final IconData icon;
//   final String value;
//   final String label;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: LightColor.surface.withValues(alpha: 0.86),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: LightColor.border),
//         boxShadow: [
//           BoxShadow(
//             color: LightColor.shadow.withValues(alpha: 0.04),
//             blurRadius: 18,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: LightColor.secondaryLight,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: Icon(icon, color: LightColor.secondary, size: 22),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             value,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: Theme.of(context).textTheme.titleSmall?.copyWith(
//               color: LightColor.titleText,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             textAlign: TextAlign.center,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: LightColor.subtitleText,
//               fontWeight: FontWeight.w600,
//               height: 1.3,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   const _SectionTitle({required this.title, required this.subtitle});

//   final String title;
//   final String subtitle;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: Theme.of(context).textTheme.titleLarge?.copyWith(
//             color: LightColor.titleText,
//             fontWeight: FontWeight.w800,
//             letterSpacing: -0.2,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           subtitle,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             color: LightColor.subtitleText,
//             height: 1.5,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _StepCardsSection extends StatelessWidget {
//   const _StepCardsSection();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _StepCard(
//           step: '01',
//           title: 'Add futsal details',
//           description:
//               'Enter your futsal name, contact details, location, amenities, and business information.',
//           icon: Icons.apartment_rounded,
//           gradient: LinearGradient(
//             colors: [LightColor.secondary, LightColor.secondaryDark],
//           ),
//         ),
//         const SizedBox(height: 14),
//         _StepCard(
//           step: '02',
//           title: 'Create your courts',
//           description:
//               'Add multiple courts, set pricing, court type, availability, and booking settings.',
//           icon: Icons.grid_on_rounded,
//           gradient: LinearGradient(
//             colors: [LightColor.primary, LightColor.primaryDark],
//           ),
//         ),
//         const SizedBox(height: 14),
//         _StepCard(
//           step: '03',
//           title: 'Review and go live',
//           description:
//               'Check everything, publish your venue, and start receiving online bookings from players.',
//           icon: Icons.rocket_launch_rounded,
//           gradient: LinearGradient(
//             colors: [LightColor.amber, const Color(0xFFD97706)],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _StepCard extends StatelessWidget {
//   const _StepCard({
//     required this.step,
//     required this.title,
//     required this.description,
//     required this.icon,
//     required this.gradient,
//   });

//   final String step;
//   final String title;
//   final String description;
//   final IconData icon;
//   final LinearGradient gradient;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: LightColor.surface.withValues(alpha: 0.92),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: LightColor.border),
//         boxShadow: [
//           BoxShadow(
//             color: LightColor.shadow.withValues(alpha: 0.05),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 58,
//             height: 58,
//             decoration: BoxDecoration(
//               gradient: gradient,
//               borderRadius: BorderRadius.circular(18),
//               boxShadow: [
//                 BoxShadow(
//                   color: gradient.colors.first.withValues(alpha: 0.25),
//                   blurRadius: 14,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Icon(icon, color: LightColor.white, size: 28),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: LightColor.surfaceSubtle,
//                     borderRadius: BorderRadius.circular(100),
//                   ),
//                   child: Text(
//                     'Step $step',
//                     style: const TextStyle(
//                       fontSize: 11.5,
//                       fontWeight: FontWeight.w800,
//                       color: LightColor.subtitleText,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: LightColor.titleText,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   description,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: LightColor.subtitleText,
//                     height: 1.5,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BenefitGrid extends StatelessWidget {
//   const _BenefitGrid();

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _BenefitTile(
//                 icon: Icons.trending_up_rounded,
//                 title: 'More visibility',
//                 description: 'Reach players searching nearby courts instantly.',
//                 topColor: LightColor.secondaryLight,
//                 iconColor: LightColor.secondary,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _BenefitTile(
//                 icon: Icons.schedule_rounded,
//                 title: 'Easy scheduling',
//                 description:
//                     'Manage slots, pricing, and court timing effortlessly.',
//                 topColor: LightColor.primaryLight,
//                 iconColor: LightColor.primary,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             Expanded(
//               child: _BenefitTile(
//                 icon: Icons.payments_rounded,
//                 title: 'Online booking',
//                 description: 'Accept bookings and advance payments securely.',
//                 topColor: LightColor.secondaryLight,
//                 iconColor: LightColor.secondaryDark,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: _BenefitTile(
//                 icon: Icons.support_agent_rounded,
//                 title: 'Better control',
//                 description:
//                     'Keep venue details and business settings updated.',
//                 topColor: LightColor.warningLight,
//                 iconColor: LightColor.amber,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }

// class _BenefitTile extends StatelessWidget {
//   const _BenefitTile({
//     required this.icon,
//     required this.title,
//     required this.description,
//     required this.topColor,
//     required this.iconColor,
//   });

//   final IconData icon;
//   final String title;
//   final String description;
//   final Color topColor;
//   final Color iconColor;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: LightColor.surface.withValues(alpha: 0.94),
//         borderRadius: BorderRadius.circular(22),
//         border: Border.all(color: LightColor.border),
//         boxShadow: [
//           BoxShadow(
//             color: LightColor.shadow.withValues(alpha: 0.045),
//             blurRadius: 18,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: topColor,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Icon(icon, color: iconColor, size: 26),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleSmall?.copyWith(
//               fontWeight: FontWeight.w800,
//               color: LightColor.titleText,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             description,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: LightColor.subtitleText,
//               height: 1.45,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ManagementHighlights extends StatelessWidget {
//   const _ManagementHighlights();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: LightColor.accent,
//         borderRadius: BorderRadius.circular(26),
//         boxShadow: [
//           BoxShadow(
//             color: LightColor.accent.withValues(alpha: 0.18),
//             blurRadius: 24,
//             offset: const Offset(0, 14),
//           ),
//         ],
//       ),
//       child: Column(
//         children: const [
//           _ManageRow(
//             icon: Icons.info_outline_rounded,
//             text: 'Venue information, address, map location, amenities',
//           ),
//           SizedBox(height: 14),
//           _ManageRow(
//             icon: Icons.photo_library_outlined,
//             text: 'Cover image, gallery, documents, branding',
//           ),
//           SizedBox(height: 14),
//           _ManageRow(
//             icon: Icons.sports_score_rounded,
//             text: 'Court details, base price, type, availability',
//           ),
//           SizedBox(height: 14),
//           _ManageRow(
//             icon: Icons.rule_folder_outlined,
//             text: 'Booking rules, policies, commissions, advance settings',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ManageRow extends StatelessWidget {
//   const _ManageRow({required this.icon, required this.text});

//   final IconData icon;
//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           width: 42,
//           height: 42,
//           decoration: BoxDecoration(
//             color: LightColor.white.withValues(alpha: 0.08),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Icon(icon, color: LightColor.white, size: 21),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             text,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//               color: LightColor.white.withValues(alpha: 0.92),
//               fontWeight: FontWeight.w500,
//               height: 1.45,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _TrustBanner extends StatelessWidget {
//   const _TrustBanner();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             LightColor.secondaryLight,
//             LightColor.secondaryLight.withValues(alpha: 0.5),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: LightColor.successBorder),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               color: LightColor.secondarySoft,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.emoji_events_rounded,
//               color: LightColor.secondary,
//               size: 28,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Designed for growth',
//                   style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                     color: LightColor.secondaryDark,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'A professional onboarding flow helps vendors understand the process faster and improves completion rate.',
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: LightColor.secondary,
//                     height: 1.5,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _BottomCta extends StatelessWidget {
//   const _BottomCta({required this.onPressed});

//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(24),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
//         child: Container(
//           padding: const EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             color: LightColor.surface.withValues(alpha: 0.82),
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(
//               color: LightColor.surface.withValues(alpha: 0.8),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: LightColor.shadow.withValues(alpha: 0.08),
//                 blurRadius: 24,
//                 offset: const Offset(0, 12),
//               ),
//             ],
//           ),
//           child: Container(
//             height: 60,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [LightColor.secondary, LightColor.secondaryDark],
//                 begin: Alignment.centerLeft,
//                 end: Alignment.centerRight,
//               ),
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: LightColor.secondary.withValues(alpha: 0.30),
//                   blurRadius: 18,
//                   offset: const Offset(0, 8),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: LightColor.transparent,
//               child: InkWell(
//                 onTap: onPressed,
//                 borderRadius: BorderRadius.circular(20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.rocket_launch_rounded,
//                       color: LightColor.white,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       'Start Vendor Onboarding',
//                       style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                         color: LightColor.white,
//                         fontWeight: FontWeight.w800,
//                         letterSpacing: 0.2,
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Container(
//                       width: 30,
//                       height: 30,
//                       decoration: BoxDecoration(
//                         color: LightColor.white.withValues(alpha: 0.18),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: const Icon(
//                         Icons.arrow_forward_rounded,
//                         color: LightColor.white,
//                         size: 18,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
