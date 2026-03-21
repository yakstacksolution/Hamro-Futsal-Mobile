import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/info_banner.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/logo_picker_card.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/review_summary_tile.dart';

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
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'OR provide a direct image URL',
            style: TextStyle(
              color: LightColor.darkgrey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: bloc.shopLogoController,
          textInputAction: TextInputAction.done,
          labelText: 'Shop Logo URL',
          hintText: 'https://res.cloudinary.com/demo/image/upload/sample.jpg',
          icon: Icons.photo_camera_back_rounded,
          validator: bloc.logoUrlValidator,
        ),
        const SizedBox(height: 16),
        const InfoBanner(
          icon: Icons.info_outline_rounded,
          color: LightColor.orange,
          backgroundColor: Color(0xFFFFF8F3),
          borderColor: LightColor.orange,
          message:
              'You can use either uploaded file or logo URL. Owner will be assigned automatically from logged-in AdminUser.',
        ),
        const SizedBox(height: 16),
        ReviewSummaryTile(
          label: 'Futsal Name',
          value: bloc.shopNameController.text.trim(),
          icon: Icons.badge_rounded,
        ),
        ReviewSummaryTile(
          label: 'Slug',
          value: bloc.slugController.text.trim(),
          icon: Icons.link_rounded,
        ),
        ReviewSummaryTile(
          label: 'Established Year',
          value: bloc.establishedYearController.text.trim(),
          icon: Icons.event_available_rounded,
        ),
        ReviewSummaryTile(
          label: 'Basic Price',
          value: bloc.basicPriceController.text.trim().isEmpty
              ? ''
              : 'NPR ${bloc.basicPriceController.text.trim()}',
          icon: Icons.payments_rounded,
        ),
        ReviewSummaryTile(
          label: 'Website',
          value: bloc.websiteController.text.trim().isEmpty
              ? 'Not provided'
              : bloc.websiteController.text.trim(),
          icon: Icons.language_rounded,
        ),
        ReviewSummaryTile(
          label: 'Exact Location',
          value: bloc.exactLocationController.text.trim(),
          icon: Icons.place_rounded,
        ),
        ReviewSummaryTile(
          label: 'Coordinates',
          value: coordinates,
          icon: Icons.my_location_rounded,
        ),
        ReviewSummaryTile(
          label: 'Location',
          value:
              '${bloc.cityController.text.trim()}, ${bloc.countryController.text.trim()}',
          icon: Icons.location_on_rounded,
        ),
        ReviewSummaryTile(
          label: 'Status',
          value: bloc.state.status.toUpperCase(),
          icon: Icons.toggle_on_rounded,
        ),
        ReviewSummaryTile(
          label: 'Amenities',
          value: bloc.amenitiesSummary,
          icon: Icons.local_activity_rounded,
        ),
        ReviewSummaryTile(
          label: 'Facilities',
          value: bloc.facilitiesSummary,
          icon: Icons.home_work_rounded,
        ),
        ReviewSummaryTile(
          label: 'Policies',
          value: bloc.policiesSummary,
          icon: Icons.policy_rounded,
        ),
        ReviewSummaryTile(
          label: 'Package',
          value: bloc.selectedPackageOption?.title ?? '',
          icon: Icons.workspace_premium_rounded,
        ),
        ReviewSummaryTile(
          label: 'Logo',
          value: (bloc.state.selectedLogoName ?? bloc.shopLogoController.text)
              .trim(),
          icon: Icons.image_rounded,
          isLast: true,
        ),
      ],
    );
  }
}
