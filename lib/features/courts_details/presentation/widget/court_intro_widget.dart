import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';

class CourtIntroWidget extends StatelessWidget {
  final CourtDetailModel court;

  const CourtIntroWidget({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopTags(),
          const SizedBox(height: 18),
          _buildTitleSection(),
          const SizedBox(height: 18),
          _buildLocationCard(),
          const SizedBox(height: 14),

          _buildDescriptionCard(),
        ],
      ),
    );
  }

  Widget _buildTopTags() {
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.start,
      alignment: WrapAlignment.spaceBetween,
      direction: Axis.horizontal,
      children: [
        _chipTag(
          court.courtType,
          Icons.stadium_outlined,
          DS.blue,
          DS.blueLight,
        ),
        _chipTag(
          '${court.maxPlayers} Players',
          Icons.groups_rounded,
          DS.purple,
          DS.purpleLight,
        ),
        _chipTag(
          '${court.openTime} - ${court.closeTime}',
          Icons.access_time_rounded,
          DS.primary,
          DS.primaryLight,
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            court.name,
            style: const TextStyle(
              color: DS.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _statusPill(court.isOpen),
      ],
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DS.border.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: DS.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: DS.primary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "2.1 KM",
                style: TextStyle(fontSize: 11, color: DS.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.location,
                  style: const TextStyle(
                    color: DS.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  court.address,
                  style: const TextStyle(
                    color: DS.textTertiary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    final description = court.description.trim();
    final hasDescription = description.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF9FBFF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: DS.border.withOpacity(0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [DS.blueLight, DS.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: LightColor.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About this court',
                      style: TextStyle(
                        color: DS.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Overview and important details',
                      style: TextStyle(
                        color: DS.textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: hasDescription
                ? Text(
                    description,
                    style: const TextStyle(
                      color: DS.textSecondary,
                      fontSize: 13.8,
                      fontWeight: FontWeight.w400,
                      height: 1.75,
                      letterSpacing: 0.1,
                    ),
                  )
                : const Text(
                    'No description available for this court yet.',
                    style: TextStyle(
                      color: DS.textTertiary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(bool isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? DS.primaryLight : DS.redLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isOpen
              ? DS.primary.withOpacity(0.25)
              : DS.red.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? DS.primary : DS.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOpen ? 'Open Now' : 'Closed',
            style: TextStyle(
              color: isOpen ? DS.primary : DS.red,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipTag(String text, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
