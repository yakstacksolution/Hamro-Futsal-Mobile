import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class SelectionOptionChip extends StatelessWidget {
  const SelectionOptionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: LightColor.skyBlue.withValues(alpha: 0.14),
      checkmarkColor: LightColor.skyBlue,
      labelStyle: TextStyle(
        color: isSelected ? LightColor.skyBlue : LightColor.titleTextColor,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: isSelected
            ? LightColor.skyBlue.withValues(alpha: 0.45)
            : LightColor.lightGrey,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
    );
  }
}
