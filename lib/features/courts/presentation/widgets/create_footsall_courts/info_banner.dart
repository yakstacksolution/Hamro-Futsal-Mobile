import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: LightColor.darkgrey,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
