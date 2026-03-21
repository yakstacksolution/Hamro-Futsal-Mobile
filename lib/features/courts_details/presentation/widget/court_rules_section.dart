import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';

class CourtRulesSection extends StatelessWidget {
  const CourtRulesSection({super.key, required this.rules});

  final List<String> rules;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LightColor.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: LightColor.border.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadow.withValues(alpha: 0.04),
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
                Icon(Icons.gavel_rounded, size: 18, color: LightColor.amber),
                SizedBox(width: 8),
                Text(
                  'Court Rules',
                  style: TextStyle(
                    color: LightColor.titleText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (rules.isEmpty)
              const Text(
                'No rules listed yet.',
                style: TextStyle(
                  color: LightColor.subtitleText,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Column(
                children: rules.asMap().entries.map((entry) {
                  final isLast = entry.key == rules.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 13,
                            color: LightColor.amber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              color: LightColor.subtitleText,
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
