import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_html_viewer.dart';
import 'package:hamro_footsall/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/venue_status_widget.dart';

class CourtIntroWidget extends StatelessWidget {
  final CourtDetailModel court;

  const CourtIntroWidget({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX18,
        left: AppDimens.paddingX16,
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
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.sizeX8),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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

  Widget _buildDescriptionCard(BuildContext context) {
    final description = court.description.trim();
    final hasDescription = description.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF9FBFF)],
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: AppDimens.sizeX18,
            offset: const Offset(0, AppDimens.sizeX8),
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
                width: AppDimens.sizeX42,
                height: AppDimens.sizeX42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      LightColor.blueLightColor,
                      LightColor.secondarySoft,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX20,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About this court',
                      style: FutsalTheme.getTextTheme(context).bodyTextLarge!
                          .copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: AppDimens.sizeX3),
                    Text(
                      'Overview and important details',
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall!
                          .copyWith(
                            color: LightColor.hintTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),

          Container(
            padding: AppUtils().getPadding(horizontal: AppDimens.paddingX6),
            child: hasDescription
                ? CustomHtmlReader(
                    html: description,
                    textStyle: FutsalTheme.getTextTheme(context).bodyTextMedium
                        ?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w400,
                          height: 1.75,
                          letterSpacing: 0.1,
                        ),
                  )
                : Text(
                    'No description available for this court yet.',
                    style: FutsalTheme.getTextTheme(context).bodyTextMedium!
                        .copyWith(
                          color: LightColor.hintTextColor,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                        ),
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
      padding: AppUtils().getPadding(
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
