import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class ReviewSummaryTile extends StatelessWidget {
  const ReviewSummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = value.trim().isEmpty || value.trim() == ',';

    return Container(
      decoration: BoxDecoration(
        color: LightColor.elevatedCardColor,
        border: Border(
          left: const BorderSide(color: LightColor.secondaryColor, width: 2.5),
          right: BorderSide(
            color: LightColor.borderColor.withValues(alpha: 0.6),
          ),
          top: BorderSide(color: LightColor.borderColor.withValues(alpha: 0.6)),
          bottom: isLast
              ? BorderSide(color: LightColor.borderColor.withValues(alpha: 0.6))
              : BorderSide.none,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: LightColor.secondaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isEmpty ? '-' : value,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: isEmpty
                        ? LightColor.hintTextColor
                        : LightColor.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          if (!isEmpty)
            Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: LightColor.secondaryColor.withValues(alpha: 0.6),
            ),
        ],
      ),
    );
  }
}
