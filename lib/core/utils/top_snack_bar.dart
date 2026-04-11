import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

typedef ControllerCallback = void Function(AnimationController);

enum DismissType { onTap, onSwipe, none }

OverlayEntry? _previousEntry;

void showTopSnackBar(
  OverlayState overlayState,
  Widget child, {
  Duration animationDuration = const Duration(milliseconds: 1000),
  Duration reverseAnimationDuration = const Duration(milliseconds: 550),
  Duration displayDuration = const Duration(milliseconds: 1500),
  VoidCallback? onTap,
  bool persistent = false,
  ControllerCallback? onAnimationControllerInit,
  EdgeInsets padding = const EdgeInsets.all(16),
  Curve curve = Curves.elasticOut,
  Curve reverseCurve = Curves.linearToEaseOut,
  SafeAreaValues safeAreaValues = const SafeAreaValues(),
  DismissType dismissType = DismissType.onTap,
  List<DismissDirection> dismissDirection = const [DismissDirection.up],
}) {
  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (_) {
      return _TopSnackBar(
        onDismissed: () {
          overlayEntry.remove();
          _previousEntry = null;
        },
        animationDuration: animationDuration,
        reverseAnimationDuration: reverseAnimationDuration,
        displayDuration: displayDuration,
        onTap: onTap,
        persistent: persistent,
        onAnimationControllerInit: onAnimationControllerInit,
        padding: padding,
        curve: curve,
        reverseCurve: reverseCurve,
        safeAreaValues: safeAreaValues,
        dismissType: dismissType,
        dismissDirections: dismissDirection,
        child: child,
      );
    },
  );

  if (_previousEntry != null && _previousEntry!.mounted) {
    _previousEntry?.remove();
  }

  overlayState.insert(overlayEntry);
  _previousEntry = overlayEntry;
}

class _TopSnackBar extends StatefulWidget {
  const _TopSnackBar({
    required this.child,
    required this.onDismissed,
    required this.animationDuration,
    required this.reverseAnimationDuration,
    required this.displayDuration,
    required this.padding,
    required this.curve,
    required this.reverseCurve,
    required this.safeAreaValues,
    required this.dismissDirections,
    this.onTap,
    this.persistent = false,
    this.onAnimationControllerInit,
    this.dismissType = DismissType.onTap,
  });

  final Widget child;
  final VoidCallback onDismissed;
  final Duration animationDuration;
  final Duration reverseAnimationDuration;
  final Duration displayDuration;
  final VoidCallback? onTap;
  final ControllerCallback? onAnimationControllerInit;
  final bool persistent;
  final EdgeInsets padding;
  final Curve curve;
  final Curve reverseCurve;
  final SafeAreaValues safeAreaValues;
  final DismissType dismissType;
  final List<DismissDirection> dismissDirections;

  @override
  _TopSnackBarState createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final Animation<Offset> _offsetAnimation;
  late final AnimationController _animationController;

  Timer? _timer;

  final _offsetTween = Tween(begin: const Offset(0, -1), end: Offset.zero);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.reverseAnimationDuration,
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !widget.persistent) {
        _timer = Timer(widget.displayDuration, () {
          if (mounted) {
            _animationController.reverse();
          }
        });
      }
      if (status == AnimationStatus.dismissed) {
        _timer?.cancel();
        widget.onDismissed.call();
      }
    });

    widget.onAnimationControllerInit?.call(_animationController);

    _offsetAnimation = _offsetTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      ),
    );
    if (mounted) {
      _animationController.forward();
    }
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Positioned(
          top: widget.padding.top,
          child: SlideTransition(
            position: _offsetAnimation,
            child: SafeArea(
              top: widget.safeAreaValues.top,
              bottom: widget.safeAreaValues.bottom,
              left: widget.safeAreaValues.left,
              right: widget.safeAreaValues.right,
              minimum: widget.safeAreaValues.minimum,
              maintainBottomViewPadding:
                  widget.safeAreaValues.maintainBottomViewPadding,
              child: _buildDismissibleChild(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDismissibleChild() {
    switch (widget.dismissType) {
      case DismissType.onTap:
        return TapBounceContainer(
          onTap: () {
            widget.onTap?.call();
            if (!widget.persistent && mounted) {
              _animationController.reverse();
            }
          },
          child: widget.child,
        );
      case DismissType.onSwipe:
        var childWidget = widget.child;
        for (final direction in widget.dismissDirections) {
          childWidget = Dismissible(
            direction: direction,
            key: UniqueKey(),
            dismissThresholds: const {DismissDirection.up: 0.2},
            confirmDismiss: (direction) async {
              if (!widget.persistent && mounted) {
                if (direction == DismissDirection.down) {
                  await _animationController.reverse();
                } else {
                  _animationController.reset();
                }
              }
              return false;
            },
            child: childWidget,
          );
        }
        return childWidget;
      case DismissType.none:
        return widget.child;
    }
  }
}

class SafeAreaValues {
  const SafeAreaValues({
    this.left = true,
    this.right = true,
    this.top = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.maintainBottomViewPadding = false,
  });

  final bool left;
  final bool top;
  final bool right;
  final bool bottom;
  final EdgeInsets minimum;
  final bool maintainBottomViewPadding;
}

class CustomSnackBar extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final TextStyle textStyle;
  final int maxLines;
  final List<BoxShadow> boxShadow;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry messagePadding;
  final double textScaleFactor;
  final TextAlign textAlign;
  final String svgIcon;
  final Color color;

  const CustomSnackBar.success({
    super.key,
    required this.message,
    this.messagePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.textStyle = const TextStyle(
      color: LightColor.secondaryDark,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    this.color = LightColor.secondaryDark,
    this.maxLines = 2,
    this.backgroundColor = LightColor.secondarySoft,
    this.boxShadow = kDefaultBoxShadow,
    this.borderRadius = kDefaultBorderRadius,
    this.textScaleFactor = 1.0,
    this.textAlign = TextAlign.center,
    this.svgIcon = "done",
  });

  const CustomSnackBar.error({
    super.key,
    this.messagePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.textStyle = const TextStyle(
      color: LightColor.red,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    this.color = LightColor.red,
    this.maxLines = 2,
    this.backgroundColor = LightColor.redLight,
    this.boxShadow = kDefaultBoxShadow,
    this.borderRadius = kDefaultBorderRadius,
    this.textScaleFactor = 1.0,
    this.textAlign = TextAlign.center,
    this.svgIcon = "close",
    required this.message,
  });

  const CustomSnackBar.info({
    super.key,
    this.messagePadding = const EdgeInsets.symmetric(horizontal: 24),
    this.textStyle = const TextStyle(
      color: LightColor.primaryDark,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    this.color = LightColor.primaryDark,
    this.maxLines = 2,
    this.backgroundColor = LightColor.primarySoft,
    this.boxShadow = kDefaultBoxShadow,
    this.borderRadius = kDefaultBorderRadius,
    this.textScaleFactor = 1.0,
    this.textAlign = TextAlign.center,
    this.svgIcon = "info",
    required this.message,
  });

  @override
  CustomSnackBarState createState() => CustomSnackBarState();
}

class CustomSnackBarState extends State<CustomSnackBar> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        clipBehavior: Clip.antiAlias,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(
                "assets/icons/${widget.svgIcon}.svg",
                width: AppDimens.sizeX18,
                height: AppDimens.sizeX18,
                colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
              ),
              SizedBox(width: AppDimens.sizeX8),
              Text(
                widget.message,
                style: widget.textStyle,
                textAlign: widget.textAlign,
                textScaler: TextScaler.linear(widget.textScaleFactor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const kDefaultBoxShadow = [
  BoxShadow(
    color: Color(0x14000000),
    offset: Offset(0, 8),
    spreadRadius: 1,
    blurRadius: 30,
  ),
];

const kDefaultBorderRadius = BorderRadius.all(Radius.circular(8.0));

class TapBounceContainer extends StatefulWidget {
  const TapBounceContainer({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  TapBounceContainerState createState() => TapBounceContainerState();
}

class TapBounceContainerState extends State<TapBounceContainer>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  final animationDuration = const Duration(milliseconds: 200);

  @override
  void initState() {
    _controller =
        AnimationController(
          vsync: this,
          duration: animationDuration,
          upperBound: 0.04,
        )..addListener(() {
          if (mounted) {
            setState(() {});
          }
        });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onPanEnd: _onPanEnd,
      child: Transform.scale(scale: _scale, child: widget.child),
    );
  }

  void _onTapDown(TapDownDetails details) {
    if (mounted) {
      _controller.forward();
    }
  }

  Future<void> _onTapUp(TapUpDetails details) async {
    await _closeSnackBar();
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    await _closeSnackBar();
  }

  Future<void> _closeSnackBar() async {
    if (mounted) {
      unawaited(_controller.reverse());
      await Future.delayed(animationDuration);
      widget.onTap?.call();
    }
  }
}
