import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class CourtBookingPoliciesSection extends StatelessWidget {
  const CourtBookingPoliciesSection({super.key, required this.policies});

  final List<String> policies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: LightColor.borderColor.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.policy_outlined,
                  size: 18,
                  color: LightColor.secondaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Booking Policies',
                  style: TextStyle(
                    color: LightColor.primaryTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (policies.isEmpty)
              const Text(
                'No booking policy added yet.',
                style: TextStyle(
                  color: LightColor.secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Column(
                children: policies.asMap().entries.map((entry) {
                  final isLast = entry.key == policies.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: LightColor.secondaryLight,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: LightColor.secondaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              color: LightColor.secondaryTextColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
