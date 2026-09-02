import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/venue_status_widget.dart';

class CourtIntroWidget extends StatelessWidget {
  final CourtDetailModel court;

  const CourtIntroWidget({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX16,
        top: AppDimens.paddingX18,
        right: AppDimens.paddingX16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopTags(context),
          const SizedBox(height: AppDimens.sizeX18),
          _buildTitleSection(context),
          const SizedBox(height: AppDimens.sizeX18),
          _buildLocationCard(context),
        ],
      ),
    );
  }

  Widget _buildTopTags(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: _chipTag(
            court.courtType,
            Icons.stadium_outlined,
            LightColor.blueColor,
            LightColor.blueLightColor,
            context,
          ),
        ),
        const SizedBox(width: AppDimens.sizeX4),
        Expanded(
          flex: 2,
          child: _chipTag(
            '${court.maxPlayers} Players',
            Icons.groups_rounded,
            LightColor.purpleColor,
            LightColor.purpleLightColor,
            context,
          ),
        ),
        const SizedBox(width: AppDimens.sizeX4),
        Expanded(
          flex: 2,
          child: _chipTag(
            court.openTime.isEmpty || court.closeTime.isEmpty
                ? 'Contact for hours'
                : '${court.openTime} - ${court.closeTime}',
            Icons.access_time_rounded,
            LightColor.secondaryColor,
            LightColor.secondarySoft,
            context,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            court.name,
            style: FutsalTheme.getTextTheme(context).headingSubTitle!.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
              height: 1.4,
              letterSpacing: -0.6,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.sizeX12),
        VenueStatusWidget(isOpen: court.isOpen),
      ],
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.sizeX8),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowOf(0.03),
            blurRadius: AppDimens.sizeX14,
            offset: const Offset(0, AppDimens.sizeX6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: AppDimens.sizeX42,
                height: AppDimens.sizeX42,
                decoration: BoxDecoration(
                  color: LightColor.secondarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.sizeX8),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX20,
                ),
              ),
              const SizedBox(height: AppDimens.sizeX4),
              Text(
                court.distance.trim().isEmpty ? '--' : court.distance,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall!
                    .copyWith(
                      color: LightColor.hintTextColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(width: AppDimens.sizeX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.location,
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium!
                      .copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX4),
                Text(
                  court.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall!
                      .copyWith(
                        color: LightColor.secondaryTextColor,
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

  Widget _chipTag(
    String label,
    IconData icon,
    Color fg,
    Color bg,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimens.sizeX14, color: fg),
          const SizedBox(width: AppDimens.sizeX4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall!
                    .copyWith(color: fg, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
