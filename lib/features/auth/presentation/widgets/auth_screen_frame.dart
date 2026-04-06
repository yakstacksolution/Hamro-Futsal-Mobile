import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

class AuthScreenFrame extends StatelessWidget {
  const AuthScreenFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryButtonLabel,
    required this.onPrimaryTap,
    required this.secondaryPrefixText,
    required this.secondaryActionText,
    required this.onSecondaryTap,
    required this.formFields,
    this.primaryButtonIcon,
    this.primaryButtonEnabled = true,
    this.headerIcon = Icons.storefront_rounded,
    this.footer,
    this.isRotate = false,
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final String primaryButtonLabel;
  final IconData? primaryButtonIcon;
  final VoidCallback? onPrimaryTap;
  final bool primaryButtonEnabled;
  final String secondaryPrefixText;
  final String secondaryActionText;
  final VoidCallback onSecondaryTap;
  final IconData headerIcon;
  final List<Widget> formFields;
  final Widget? footer;
  final bool isRotate;
  final bool isLoading;
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const _AuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _AuthHeader(
                        title: title,
                        subtitle: subtitle,
                        headerIcon: headerIcon,
                        isRotate: isRotate,
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                        decoration: BoxDecoration(
                          color: LightColor.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(26),
                          border: Border.all(
                            color: LightColor.border.withValues(alpha: 0.7),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: LightColor.secondary.withValues(
                                alpha: 0.14,
                              ),
                              blurRadius: 32,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ...formFields,
                            const SizedBox(height: 18),
                            CustomButton(
                              text: primaryButtonLabel,
                              minHeight: 45,
                              borderRadius: 10,
                              fontSize: 14,
                              isLoading: isLoading,
                              backgroundColor: theme.colorScheme.secondary,
                              onPressed: primaryButtonEnabled
                                  ? onPrimaryTap
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    secondaryPrefixText,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: LightColor.subtitleText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: onSecondaryTap,
                                  child: Text(
                                    '$secondaryActionText ?',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: LightColor.secondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // if (footer != null) ...<Widget>[
                            const SizedBox(height: 8),
                            //   footer!,
                            // ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration authInputDecoration({
  required BuildContext context,
  required String labelText,
  required IconData icon,
  String? hintText,
  Widget? suffixIcon,
}) {
  final ThemeData theme = Theme.of(context);
  final Color fillColor = LightColor.surface;

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.15),
    );
  }

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: Icon(icon, color: LightColor.subtitleText),
    suffixIcon: suffixIcon,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: fillColor,
    labelStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.subtitleText,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    hintStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.hintText,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    enabledBorder: border(LightColor.border),
    focusedBorder: border(theme.colorScheme.secondary),
    border: border(LightColor.border),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
  );
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    this.isRotate = false,
  });

  final String title;
  final String subtitle;
  final IconData headerIcon;
  final bool isRotate;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                LightColor.primary,
                LightColor.secondary,
                LightColor.secondaryDark,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: LightColor.primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isRotate
              ? _RotatingIcon(headerIcon)
              : Icon(headerIcon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: LightColor.titleText,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: LightColor.subtitleText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            LightColor.secondarySoft,
            LightColor.primarySoft,
            LightColor.background,
          ],
          stops: const <double>[0, 0.35, 1],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -84,
            left: -52,
            child: _BackgroundBubble(
              size: 190,
              colors: const <Color>[LightColor.primarySoft, Color(0x1416A34A)],
            ),
          ),
          Positioned(
            top: 130,
            right: -70,
            child: _BackgroundBubble(
              size: 230,
              colors: const <Color>[LightColor.secondarySoft, Color(0x1410B981)],
            ),
          ),
          Positioned(
            bottom: -65,
            left: -40,
            child: _BackgroundBubble(
              size: 170,
              colors: const <Color>[Color(0x1A14532D), Color(0x0F14532D)],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundBubble extends StatelessWidget {
  const _BackgroundBubble({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

class _RotatingIcon extends StatefulWidget {
  final IconData icon;
  const _RotatingIcon(this.icon);

  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: Icon(widget.icon, color: Colors.white, size: 34),
        );
      },
    );
  }
}
