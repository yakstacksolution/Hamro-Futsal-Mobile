import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/info_banner.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/logo_picker_card.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/review_summary_tile.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class BrandingReviewSection extends StatelessWidget {
  const BrandingReviewSection({
    super.key,
    required this.bloc,
    required this.onPickLogo,
  });

  final CreateFootsallCourtsBloc bloc;
  final VoidCallback onPickLogo;

  @override
  Widget build(BuildContext context) {
    final String coordinates =
        bloc.state.selectedLatitude == null ||
            bloc.state.selectedLongitude == null
        ? ''
        : '${bloc.state.selectedLatitude!.toStringAsFixed(6)}, ${bloc.state.selectedLongitude!.toStringAsFixed(6)}';

    return Column(
      children: <Widget>[
        LogoPickerCard(
          logoBytes: bloc.state.selectedLogoBytes,
          fileName: bloc.state.selectedLogoName,
          onPick: onPickLogo,
          onRemove: bloc.removeSelectedLogo,
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            StringConstants.orProvideADirectImageUrl,
            style: TextStyle(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: bloc.shopLogoController,
          focusNode: bloc.shopLogoFocus,
          ensureVisibleOnFocus: true,
          isRequired: false,
          textInputAction: TextInputAction.done,
          labelText: StringConstants.shopLogoUrl,
          hintText: StringConstants.cloudinaryImageUrlExample,
          icon: Icons.photo_camera_back_rounded,
          validator: bloc.logoUrlValidator,
        ),
        const SizedBox(height: 16),
        InfoBanner(
          icon: Icons.info_outline_rounded,
          color: LightColor.warningColor,
          backgroundColor: LightColor.warningLightColor,
          borderColor: LightColor.warningColor,
          message: StringConstants
              .youCanUseEitherUploadedFileOrLogoUrlOwnerWillBeA12d1d437,
        ),
        const SizedBox(height: 16),
        ReviewSummaryTile(
          label: StringConstants.futsalName,
          value: bloc.shopNameController.text.trim(),
          icon: Icons.badge_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.slug,
          value: bloc.slugController.text.trim(),
          icon: Icons.link_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.establishedYear,
          value: bloc.establishedYearController.text.trim(),
          icon: Icons.event_available_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.basicPrice,
          value: bloc.basicPriceController.text.trim().isEmpty
              ? ''
              : 'NPR ${bloc.basicPriceController.text.trim()}',
          icon: Icons.payments_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.website,
          value: bloc.websiteController.text.trim().isEmpty
              ? 'Not provided'
              : bloc.websiteController.text.trim(),
          icon: Icons.language_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.exactLocation,
          value: bloc.exactLocationController.text.trim(),
          icon: Icons.place_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.coordinates,
          value: coordinates,
          icon: Icons.my_location_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.location,
          value:
              '${bloc.cityController.text.trim()}, ${bloc.countryController.text.trim()}',
          icon: Icons.location_on_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.status,
          value: bloc.state.status.toUpperCase(),
          icon: Icons.toggle_on_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.amenities,
          value: bloc.amenitiesSummary,
          icon: Icons.local_activity_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.facilities,
          value: bloc.facilitiesSummary,
          icon: Icons.home_work_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.policies,
          value: bloc.policiesSummary,
          icon: Icons.policy_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.package,
          value: bloc.selectedPackageOption?.title ?? '',
          icon: Icons.workspace_premium_rounded,
        ),
        ReviewSummaryTile(
          label: StringConstants.logo,
          value: (bloc.state.selectedLogoName ?? bloc.shopLogoController.text)
              .trim(),
          icon: Icons.image_rounded,
          isLast: true,
        ),
      ],
    );
  }
}
