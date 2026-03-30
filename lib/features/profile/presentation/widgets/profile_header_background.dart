import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

const String kProfileHeaderSurfaceHeroTag = 'profile-header-surface';

class ProfileHeaderBackground extends StatefulWidget {
  const ProfileHeaderBackground({
    super.key,
    this.height = 230,
    this.child,
    this.borderRadius,
    this.heroTag,
    this.backgroundColors,
  });

  final double height;
  final Widget? child;
  final BorderRadius? borderRadius;
  final Object? heroTag;
  final List<Color>? backgroundColors;

  @override
  State<ProfileHeaderBackground> createState() =>
      _ProfileHeaderBackgroundState();
}

class _ProfileHeaderBackgroundState extends State<ProfileHeaderBackground>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _floatController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _childFadeAnimation;
  late final Animation<double> _childSlideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..forward();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.965, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _slideAnimation = Tween<double>(begin: 18, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _childFadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.18, 1, curve: Curves.easeOut),
    );
    _childSlideAnimation = Tween<double>(begin: 10, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
        widget.borderRadius ?? BorderRadius.circular(28);

    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _floatController]),
      builder: (BuildContext context, Widget? _) {
        final double phase = _floatController.value * math.pi * 2;
        final double driftX = math.sin(phase) * 8;
        final double driftY = math.cos(phase * 0.85) * 6;
        final double shadowPulse = (math.sin(phase) + 1) / 2;
        final double shimmerShift = math.sin(phase * 0.55) * 0.55;

        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color(
                        0xFF245FCC,
                      ).withValues(alpha: 0.22 + shadowPulse * 0.08),
                      blurRadius: 26 + shadowPulse * 10,
                      spreadRadius: 1.5 + shadowPulse,
                      offset: Offset(0, 8 + shadowPulse * 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Positioned.fill(
                        child: widget.heroTag != null
                            ? Hero(
                                tag: widget.heroTag!,
                                transitionOnUserGestures: true,
                                flightShuttleBuilder: _buildHeroFlight,
                                child: _HeaderSurface(
                                  borderRadius: radius,
                                  driftX: driftX,
                                  driftY: driftY,
                                  shimmerShift: shimmerShift,
                                  backgroundColors: widget.backgroundColors,
                                ),
                              )
                            : _HeaderSurface(
                                borderRadius: radius,
                                driftX: driftX,
                                driftY: driftY,
                                shimmerShift: shimmerShift,
                                backgroundColors: widget.backgroundColors,
                              ),
                      ),
                      if (widget.child != null)
                        Positioned.fill(
                          child: Opacity(
                            opacity: _childFadeAnimation.value,
                            child: Transform.translate(
                              offset: Offset(0, _childSlideAnimation.value),
                              child: widget.child,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildHeroFlight(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final _HeaderSurface fromSurface =
        (fromHeroContext.widget as Hero).child as _HeaderSurface;
    final _HeaderSurface toSurface =
        (toHeroContext.widget as Hero).child as _HeaderSurface;

    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double t = Curves.easeInOutCubic.transform(animation.value);
        final double heroDriftX = math.sin(t * math.pi) * 6;
        final double heroDriftY = math.cos(t * math.pi * 0.8) * 4;

        return _HeaderSurface(
          borderRadius:
              BorderRadius.lerp(
                fromSurface.borderRadius,
                toSurface.borderRadius,
                t,
              ) ??
              toSurface.borderRadius,
          driftX: heroDriftX,
          driftY: heroDriftY,
          shimmerShift: -0.20 + (0.60 * t),
          backgroundColors: _lerpColorList(
            fromSurface.backgroundColors,
            toSurface.backgroundColors,
            t,
          ),
        );
      },
    );
  }

  static List<Color>? _lerpColorList(
    List<Color>? from,
    List<Color>? to,
    double t,
  ) {
    if (from == null && to == null) {
      return null;
    }

    final List<Color> fallback =
        from ??
        to ??
        const <Color>[
          LightColor.accent,
          LightColor.primaryDark,
          LightColor.primary,
        ];
    final int length = math.max(from?.length ?? 0, to?.length ?? 0);

    return List<Color>.generate(length == 0 ? fallback.length : length, (
      int index,
    ) {
      final Color begin = index < (from?.length ?? 0) ? from![index] : fallback[index % fallback.length];
      final Color end = index < (to?.length ?? 0) ? to![index] : fallback[index % fallback.length];
      return Color.lerp(begin, end, t) ?? end;
    });
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.width, required this.height, required this.color});

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(width * 0.65),
          topRight: Radius.circular(width * 0.28),
          bottomLeft: Radius.circular(width * 0.42),
          bottomRight: Radius.circular(width * 0.72),
        ),
      ),
    );
  }
}

class _HeaderSurface extends StatelessWidget {
  const _HeaderSurface({
    required this.borderRadius,
    required this.driftX,
    required this.driftY,
    required this.shimmerShift,
    this.backgroundColors,
  });

  final BorderRadius borderRadius;
  final double driftX;
  final double driftY;
  final double shimmerShift;
  final List<Color>? backgroundColors;

  List<Color> get _resolvedBackgroundColors =>
      backgroundColors ??
      const <Color>[
        LightColor.accent,
        LightColor.primaryDark,
        LightColor.primary,
      ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _resolvedBackgroundColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.25 + shimmerShift, -1),
                  end: Alignment(0.55 + shimmerShift, 1),
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.11),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const <double>[0.18, 0.48, 0.82],
                ),
              ),
            ),
          ),
          Positioned(
            right: -30 + driftX * 0.35,
            top: -25 + driftY * 0.45,
            child: _Blob(
              width: 170,
              height: 160,
              color: _resolvedBackgroundColors.last.withValues(alpha: 0.24),
            ),
          ),
          Positioned(
            right: 30 - driftX * 0.22,
            bottom: -45 + driftY * 0.40,
            child: _Blob(
              width: 190,
              height: 150,
              color: _resolvedBackgroundColors[1].withValues(alpha: 0.20),
            ),
          ),
          Positioned(
            left: 70 + driftX * 0.18,
            bottom: -55 - driftY * 0.34,
            child: _Blob(
              width: 200,
              height: 200,
              color: _resolvedBackgroundColors.first.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            left: -20 - driftX * 0.20,
            top: -20 - driftY * 0.15,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LightColor.secondaryLight.withValues(alpha: 0.34),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
