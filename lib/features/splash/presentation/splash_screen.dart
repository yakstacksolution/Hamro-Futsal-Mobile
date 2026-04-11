// import 'dart:async';
// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hamro_footsall/core/helper/share_preferences.dart';
// import 'package:hamro_footsall/core/routers/app_router_params.dart';
// import 'package:hamro_footsall/core/theme/light_color.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with TickerProviderStateMixin {
//   late final AnimationController _loopController;
//   late final AnimationController _entryController;

//   late final Animation<double> _logoScale;
//   late final Animation<double> _logoFloat;
//   late final Animation<double> _ringPulse;
//   late final Animation<double> _shineOffset;
//   late final Animation<double> _contentFade;
//   late final Animation<double> _cardSlide;

//   @override
//   void initState() {
//     super.initState();

//     _loopController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 3200),
//     )..repeat();

//     _entryController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1150),
//     )..forward();

//     _logoScale = Tween<double>(begin: 0.94, end: 1.03).animate(
//       CurvedAnimation(parent: _loopController, curve: Curves.easeInOut),
//     );
//     _logoFloat = Tween<double>(begin: -9, end: 9).animate(
//       CurvedAnimation(parent: _loopController, curve: Curves.easeInOutSine),
//     );
//     _ringPulse = Tween<double>(begin: 0.92, end: 1.1).animate(
//       CurvedAnimation(parent: _loopController, curve: Curves.easeInOutCubic),
//     );
//     _shineOffset = Tween<double>(begin: -1.4, end: 1.4).animate(
//       CurvedAnimation(parent: _loopController, curve: Curves.easeInOut),
//     );

//     _contentFade = CurvedAnimation(
//       parent: _entryController,
//       curve: const Interval(0.0, 0.72, curve: Curves.easeOutCubic),
//     );
//     _cardSlide = CurvedAnimation(
//       parent: _entryController,
//       curve: const Interval(0.32, 1, curve: Curves.easeOutCubic),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FlutterNativeSplash.remove();
//     });

//     _handleInitialNavigation();
//   }

//   @override
//   void dispose() {
//     _loopController.dispose();
//     _entryController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleInitialNavigation() async {
//     await Future<void>.delayed(const Duration(seconds: 3));
//     if (!mounted) return;

//     final tokenModel = AppSettings().tokenModel;
//     final bool hasToken = tokenModel.accessToken?.trim().isNotEmpty ?? false;

//     context.goNamed(
//       hasToken ? AppRouterParams.dashboard.name : AppRouterParams.login.name,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Size size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: Listenable.merge(<Listenable>[
//           _loopController,
//           _entryController,
//         ]),
//         builder: (BuildContext context, Widget? child) {
//           return DecoratedBox(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: <Color>[
//                   LightColor.secondaryColor,
//                   LightColor.secondaryDark,
//                   LightColor.secondaryColor,
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//             child: Stack(
//               children: <Widget>[
//                 Positioned(
//                   top: -size.width * 0.12,
//                   right: -size.width * 0.08,
//                   child: _GlowCircle(
//                     size: size.width * 0.62,
//                     color: LightColor.secondaryLight.withValues(alpha: 0.16),
//                   ),
//                 ),
//                 Positioned(
//                   left: -size.width * 0.18,
//                   top: size.height * 0.22 + _logoFloat.value,
//                   child: _GlowCircle(
//                     size: size.width * 0.5,
//                     color: LightColor.primarySoft.withValues(alpha: 0.42),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: -size.width * 0.2,
//                   right: size.width * 0.02,
//                   child: _GlowCircle(
//                     size: size.width * 0.68,
//                     color: Colors.white.withValues(alpha: 0.07),
//                   ),
//                 ),
//                 Positioned.fill(
//                   child: CustomPaint(painter: _FieldLinesPainter()),
//                 ),
//                 SafeArea(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: Column(
//                       children: <Widget>[
//                         const Spacer(flex: 1),
//                         Opacity(
//                           opacity: _contentFade.value,
//                           child: Transform.translate(
//                             offset: Offset(0, 24 * (1 - _contentFade.value)),
//                             child: Column(
//                               children: <Widget>[
//                                 Transform.translate(
//                                   offset: Offset(0, _logoFloat.value),
//                                   child: Transform.scale(
//                                     scale: _logoScale.value,
//                                     child: SizedBox(
//                                       width: 168,
//                                       height: 168,
//                                       child: Stack(
//                                         alignment: Alignment.center,
//                                         children: <Widget>[
//                                           Transform.scale(
//                                             scale: _ringPulse.value,
//                                             child: Container(
//                                               width: 162,
//                                               height: 162,
//                                               decoration: BoxDecoration(
//                                                 shape: BoxShape.circle,
//                                                 border: Border.all(
//                                                   color: LightColor
//                                                       .secondaryLight
//                                                       .withValues(alpha: 0.22),
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             width: 126,
//                                             height: 126,
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               border: Border.all(
//                                                 color: Colors.white.withValues(
//                                                   alpha: 0.14,
//                                                 ),
//                                                 width: 1.3,
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             width: 96,
//                                             height: 96,
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               color: Colors.white,
//                                               boxShadow: <BoxShadow>[
//                                                 BoxShadow(
//                                                   color: LightColor.secondaryColor
//                                                       .withValues(alpha: 0.28),
//                                                   blurRadius: 28,
//                                                   spreadRadius: 1,
//                                                   offset: const Offset(0, 12),
//                                                 ),
//                                               ],
//                                             ),
//                                             child: ClipOval(
//                                               child: Stack(
//                                                 children: <Widget>[
//                                                   Positioned.fill(
//                                                     child: CustomPaint(
//                                                       painter:
//                                                           _SoccerBallPainter(),
//                                                     ),
//                                                   ),
//                                                   Align(
//                                                     alignment: Alignment(
//                                                       _shineOffset.value,
//                                                       0,
//                                                     ),
//                                                     child: Container(
//                                                       width: 28,
//                                                       decoration: BoxDecoration(
//                                                         gradient:
//                                                             LinearGradient(
//                                                               colors: <Color>[
//                                                                 Colors.white
//                                                                     .withValues(
//                                                                       alpha: 0,
//                                                                     ),
//                                                                 Colors.white
//                                                                     .withValues(
//                                                                       alpha:
//                                                                           0.45,
//                                                                     ),
//                                                                 Colors.white
//                                                                     .withValues(
//                                                                       alpha: 0,
//                                                                     ),
//                                                               ],
//                                                             ),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 28),
//                                 Text(
//                                   'Hamro Futsal',
//                                   textAlign: TextAlign.center,
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .headlineLarge
//                                       ?.copyWith(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w900,
//                                         fontSize: 34,
//                                         letterSpacing: -0.8,
//                                       ),
//                                 ),
//                                 const SizedBox(height: 20),
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 16,
//                                     vertical: 9,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: LightColor.secondaryLight.withValues(
//                                       alpha: 0.16,
//                                     ),
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(
//                                       color: LightColor.secondaryLight
//                                           .withValues(alpha: 0.34),
//                                     ),
//                                   ),
//                                   child: Text(
//                                     'Book courts. Play harder. Manage better.',
//                                     textAlign: TextAlign.center,
//                                     style: Theme.of(context)
//                                         .textTheme
//                                         .bodyMedium
//                                         ?.copyWith(
//                                           color: Colors.white.withValues(
//                                             alpha: 0.92,
//                                           ),
//                                           fontWeight: FontWeight.w700,
//                                           fontSize: 12,
//                                           letterSpacing: 0.2,
//                                         ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         const Spacer(),
//                         Opacity(
//                           opacity: _cardSlide.value,
//                           child: Transform.translate(
//                             offset: Offset(0, 36 * (1 - _cardSlide.value)),
//                             child: Container(
//                               width: double.infinity,
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.fromLTRB(
//                                 22,
//                                 22,
//                                 22,
//                                 20,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withValues(alpha: 0.12),
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: Colors.white.withValues(alpha: 0.18),
//                                 ),
//                                 boxShadow: <BoxShadow>[
//                                   BoxShadow(
//                                     color: LightColor.shadowColor.withValues(
//                                       alpha: 0.12,
//                                     ),
//                                     blurRadius: 28,
//                                     offset: const Offset(0, 18),
//                                   ),
//                                 ],
//                               ),
//                               child: SizedBox(
//                                 height: 112,
//                                 child: Center(
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: <Widget>[
//                                       const _LoadingDots(),
//                                       const SizedBox(height: 14),
//                                       Text(
//                                         'Play or Manage',
//                                         textAlign: TextAlign.center,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .titleMedium
//                                             ?.copyWith(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.w800,
//                                               fontSize: 14,
//                                             ),
//                                       ),
//                                       const SizedBox(height: 6),
//                                       Text(
//                                         'Continue as Player or Vendor',
//                                         textAlign: TextAlign.center,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .bodySmall
//                                             ?.copyWith(
//                                               color: Colors.white.withValues(
//                                                 alpha: 0.8,
//                                               ),
//                                               fontSize: 11,
//                                               height: 1.4,
//                                             ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),

//                         SizedBox(height: 20),
//                         Text(
//                           'Version 1.0.0',
//                           style: Theme.of(context).textTheme.titleMedium
//                               ?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w800,
//                                 fontSize: 10,
//                               ),
//                         ),
//                         SizedBox(height: 24),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _GlowCircle extends StatelessWidget {
//   const _GlowCircle({required this.size, required this.color});

//   final double size;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     return IgnorePointer(
//       child: Container(
//         width: size,
//         height: size,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           gradient: RadialGradient(colors: <Color>[color, Colors.transparent]),
//         ),
//       ),
//     );
//   }
// }

// class _LoadingDots extends StatefulWidget {
//   const _LoadingDots();

//   @override
//   State<_LoadingDots> createState() => _LoadingDotsState();
// }

// class _LoadingDotsState extends State<_LoadingDots>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (BuildContext context, _) {
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List<Widget>.generate(4, (int index) {
//             final double progress = ((_controller.value - index * 0.18) % 1.0)
//                 .clamp(0.0, 1.0);
//             final double scale = 0.62 + (math.sin(progress * math.pi) * 0.52);
//             final double opacity = 0.24 + (math.sin(progress * math.pi) * 0.76);

//             final Color dotColor = index.isEven
//                 ? LightColor.secondaryLight
//                 : Colors.white;

//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4),
//               child: Transform.scale(
//                 scale: scale,
//                 child: Container(
//                   width: 8,
//                   height: 8,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: dotColor.withValues(alpha: opacity),
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
// }

// class _SoccerBallPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint whitePaint = Paint()..color = Colors.white;
//     final Paint darkPaint = Paint()..color = const Color(0xFF1A1A1A);

//     canvas.drawRect(Offset.zero & size, whitePaint);

//     final double cx = size.width / 2;
//     final double cy = size.height / 2;
//     final double r = size.width * 0.14;

//     _drawHex(canvas, darkPaint, cx, cy, r);

//     final List<Offset> positions = <Offset>[
//       Offset(cx, cy - r * 2.3),
//       Offset(cx + r * 2.0, cy - r * 1.2),
//       Offset(cx + r * 2.0, cy + r * 1.2),
//       Offset(cx, cy + r * 2.3),
//       Offset(cx - r * 2.0, cy + r * 1.2),
//       Offset(cx - r * 2.0, cy - r * 1.2),
//     ];

//     for (final Offset pos in positions) {
//       _drawHex(canvas, darkPaint, pos.dx, pos.dy, r);
//     }
//   }

//   void _drawHex(Canvas canvas, Paint paint, double cx, double cy, double r) {
//     final Path path = Path();
//     for (int i = 0; i < 6; i++) {
//       final double angle = (math.pi / 3) * i - math.pi / 6;
//       final double x = cx + r * math.cos(angle);
//       final double y = cy + r * math.sin(angle);
//       if (i == 0) {
//         path.moveTo(x, y);
//       } else {
//         path.lineTo(x, y);
//       }
//     }
//     path.close();
//     canvas.drawPath(path, paint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _FieldLinesPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final Paint linePaint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.07)
//       ..strokeWidth = 1.0
//       ..style = PaintingStyle.stroke;

//     final double w = size.width;
//     final double h = size.height;

//     canvas.drawRRect(
//       RRect.fromRectAndRadius(
//         Rect.fromLTWH(w * 0.04, h * 0.08, w * 0.92, h * 0.84),
//         const Radius.circular(12),
//       ),
//       linePaint,
//     );

//     canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), linePaint);
//     canvas.drawCircle(Offset(w / 2, h * 0.5), w * 0.24, linePaint);

//     canvas.drawArc(
//       Rect.fromCenter(
//         center: Offset(w / 2, h * 0.08),
//         width: w * 0.38,
//         height: h * 0.16,
//       ),
//       0,
//       math.pi,
//       false,
//       linePaint,
//     );

//     canvas.drawArc(
//       Rect.fromCenter(
//         center: Offset(w / 2, h * 0.92),
//         width: w * 0.38,
//         height: h * 0.16,
//       ),
//       math.pi,
//       math.pi,
//       false,
//       linePaint,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
