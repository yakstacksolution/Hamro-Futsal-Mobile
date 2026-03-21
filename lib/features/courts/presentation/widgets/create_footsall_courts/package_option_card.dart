import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/courts/presentation/models/create_courts_package_option.dart';

class PackageOptionCard extends StatelessWidget {
  const PackageOptionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final CreateCourtsPackageOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? LightColor.skyBlue
                  : LightColor.lightGrey.withValues(alpha: 0.95),
              width: isSelected ? 1.7 : 1.1,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: LightColor.skyBlue.withValues(alpha: 0.14),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          option.title,
                          style: const TextStyle(
                            color: LightColor.titleTextColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option.subtitle,
                          style: const TextStyle(
                            color: LightColor.darkgrey,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (option.isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: LightColor.orange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Recommended',
                        style: TextStyle(
                          color: LightColor.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                option.priceLabel,
                style: const TextStyle(
                  color: LightColor.skyBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final String feature in option.features) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: isSelected
                          ? LightColor.skyBlue
                          : LightColor.secondaryGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: LightColor.titleTextColor,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: <Widget>[
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    size: 18,
                    color: isSelected ? LightColor.skyBlue : LightColor.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSelected ? 'Selected package' : 'Tap to choose package',
                    style: TextStyle(
                      color: isSelected
                          ? LightColor.skyBlue
                          : LightColor.darkgrey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
