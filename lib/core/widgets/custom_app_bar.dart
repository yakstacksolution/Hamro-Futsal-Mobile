import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = true,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: LightColor.background,
      surfaceTintColor: LightColor.transparentColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: showBack
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: LightColor.primaryTextColor,
              ),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: Text(
        title,
        style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: LightColor.primaryTextColor,
        ),
      ),
      actions: actions,
    );
  }
}
