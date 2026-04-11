import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class PolicyToggleTile extends StatelessWidget {
  const PolicyToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? LightColor.secondaryColor.withValues(alpha: 0.35)
              : LightColor.borderColor,
        ),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: LightColor.secondaryColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        title: Text(
          title,
          style: const TextStyle(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: LightColor.secondaryTextColor, fontSize: 12.5),
        ),
      ),
    );
  }
}
