import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
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
    final FutsalTextTheme theme = FutsalTheme.getTextTheme(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const _AuthBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimens.paddingX20,
                  AppDimens.paddingX24,
                  AppDimens.paddingX20,
                  AppDimens.paddingX20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        (AppDimens.sizeX130 + AppDimens.sizeX130) *
                        AppDimens.sizeX2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _AuthHeader(
                        title: title,
                        subtitle: subtitle,
                        headerIcon: headerIcon,
                        isRotate: isRotate,
                      ),
                      SizedBox(height: AppDimens.sizeX18),
                      Container(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.paddingX20,
                          AppDimens.paddingX20,
                          AppDimens.paddingX20,
                          AppDimens.paddingX14,
                        ),
                        decoration: BoxDecoration(
                          color: LightColor.whiteColor.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX20,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            ...formFields,
                            SizedBox(height: AppDimens.sizeX18),
                            CustomButton(
                              text: primaryButtonLabel,
                              minHeight: AppDimens.sizeX44,
                              isLoading: isLoading,
                              backgroundColor: LightColor.buttonColor,
                              onPressed: primaryButtonEnabled
                                  ? onPrimaryTap
                                  : null,
                            ),
                            SizedBox(height: AppDimens.sizeX20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    secondaryPrefixText,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.bodyTextSmall?.copyWith(
                                      color: LightColor.secondaryTextColor,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: onSecondaryTap,
                                  child: Text(
                                    '$secondaryActionText ?',
                                    style: theme.bodyTextSmall?.copyWith(
                                      color: LightColor.secondaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (footer != null) ...<Widget>[
                              const SizedBox(height: AppDimens.sizeX10),
                              footer!,
                            ],
                            const SizedBox(height: AppDimens.sizeX10),
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
  final Color fillColor = LightColor.cardColor;

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.15),
    );
  }

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: Icon(icon, color: LightColor.secondaryTextColor),
    suffixIcon: suffixIcon,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: fillColor,
    labelStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.secondaryTextColor,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    hintStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.hintTextColor,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    enabledBorder: border(LightColor.borderColor),
    focusedBorder: border(theme.colorScheme.secondary),
    border: border(LightColor.borderColor),
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
    return Row(
      children: <Widget>[
        Container(
          width: AppDimens.sizeX58,
          height: AppDimens.sizeX58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                LightColor.secondaryColor,
                LightColor.secondaryColor,
                LightColor.secondaryDark,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: LightColor.secondaryColor.withValues(alpha: 0.25),
                blurRadius: AppDimens.radiusX18,
                offset: const Offset(0, AppDimens.sizeX8),
              ),
            ],
          ),
          child: isRotate
              ? _RotatingIcon(headerIcon)
              : Icon(headerIcon, color: Colors.white, size: AppDimens.sizeX28),
        ),
        const SizedBox(width: AppDimens.sizeX14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: FutsalTheme.getTextTheme(
                  context,
                ).headingSubTitle?.copyWith(color: LightColor.primaryTextColor),
              ),
              const SizedBox(height: AppDimens.sizeX2),
              Text(
                subtitle,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: LightColor.secondaryTextColor,
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
    return Stack(
      children: <Widget>[
        Positioned(
          top: -84,
          left: -52,
          child: _BackgroundBubble(
            size: AppDimens.sizeX190,
            colors: const <Color>[LightColor.primarySoft, Color(0x1416A34A)],
          ),
        ),
        Positioned(
          top: 130,
          right: -70,
          child: _BackgroundBubble(
            size: AppDimens.sizeX230,
            colors: const <Color>[LightColor.secondarySoft, Color(0x1410B981)],
          ),
        ),
        Positioned(
          bottom: -65,
          left: -40,
          child: _BackgroundBubble(
            size: AppDimens.sizeX170,
            colors: const <Color>[Color(0x1A14532D), Color(0x0F14532D)],
          ),
        ),
      ],
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
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: AppDimens.sizeX34,
          ),
        );
      },
    );
  }
}
