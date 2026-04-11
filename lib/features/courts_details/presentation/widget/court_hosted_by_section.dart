import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';

class CourtHostedBySection extends StatelessWidget {
  const CourtHostedBySection({
    super.key,
    required this.hostName,
    required this.hostSince,
    required this.hostedCourts,
    required this.responseRate,
    required this.rating,
  });

  final String hostName;
  final String hostSince;
  final int hostedCourts;
  final double responseRate;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final initial = _initial(hostName);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF7FBFF)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: LightColor.borderColor.withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hosted By',
              style: TextStyle(
                color: LightColor.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[
                        LightColor.secondaryColor,
                        LightColor.secondaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              hostName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: LightColor.primaryTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: LightColor.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hosting since $hostSince',
                        style: const TextStyle(
                          color: LightColor.secondaryTextColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: LightColor.secondaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: LightColor.secondaryColor,
                    size: 19,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _HostMetricTile(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Courts',
                  value: hostedCourts.toString(),
                ),
                const SizedBox(width: 10),
                _HostMetricTile(
                  icon: Icons.flash_on_rounded,
                  label: 'Response',
                  value: '${responseRate.toInt()}%',
                ),
                const SizedBox(width: 10),
                _HostMetricTile(
                  icon: Icons.star_rounded,
                  label: 'Rating',
                  value: rating.toStringAsFixed(1),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _HostMetricTile extends StatelessWidget {
  const _HostMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: LightColor.secondaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: LightColor.borderColor.withValues(alpha: 0.8),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: LightColor.secondaryColor),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                color: LightColor.primaryTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: const TextStyle(
                color: LightColor.secondaryTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
