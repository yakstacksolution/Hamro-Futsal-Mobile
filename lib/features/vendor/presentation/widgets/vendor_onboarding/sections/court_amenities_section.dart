import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_court_options_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_court_options/public_court_options_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class CourtAmenitiesSection extends StatefulWidget {
  const CourtAmenitiesSection({
    super.key,
    required this.cubit,
    required this.court,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  State<CourtAmenitiesSection> createState() => _CourtAmenitiesSectionState();
}

class _CourtAmenitiesSectionState extends State<CourtAmenitiesSection> {
  late final PublicCourtOptionsBloc _optionsBloc;

  @override
  void initState() {
    super.initState();
    _optionsBloc = PublicCourtOptionsBloc(
      GetCourtOptionsUseCase(PublicRepositoryImpl()),
    )..add(const FetchPublicCourtOptionsEvent());
  }

  @override
  void dispose() {
    _optionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PublicCourtOptionsBloc>.value(
      value: _optionsBloc,
      child: BlocBuilder<PublicCourtOptionsBloc, PublicCourtOptionsState>(
        builder: (BuildContext context, PublicCourtOptionsState state) {
          final List<String> amenities = _optionLabels(
            state.amenities,
            fallback: courtAmenityOptions,
          );
          final List<String> facilities = _optionLabels(
            state.facilities,
            fallback: courtFacilityOptions,
          );

          return VendorPanel(
            padding: AppUtils().getPadding(all: AppDimens.paddingX12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const VendorOnboardingSectionHeader(
                  title: 'Amenities & Facilities',
                  subtitle: 'Court-specific services and player facilities.',
                  icon: Icons.dashboard_customize_rounded,
                ),
                const SizedBox(height: AppDimens.sizeX12),
                _CourtOptionGroup(
                  title: 'Amenities',
                  icon: Icons.chair_alt_rounded,
                  options: amenities,
                  icons: courtAmenityIcons,
                  selectedValues: widget.court.amenities,
                  onTap: widget.cubit.toggleCourtAmenity,
                ),
                const SizedBox(height: AppDimens.sizeX12),
                _CourtOptionGroup(
                  title: 'Facilities',
                  icon: Icons.meeting_room_rounded,
                  options: facilities,
                  icons: courtFacilityIcons,
                  selectedValues: widget.court.facilities,
                  onTap: widget.cubit.toggleCourtFacility,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _optionLabels(
    List<PublicOptionModel> models, {
    required List<String> fallback,
  }) {
    final List<String> labels = models
        .map((PublicOptionModel item) => item.name.trim())
        .where((String item) => item.isNotEmpty)
        .toSet()
        .toList(growable: false);
    return labels.isEmpty ? fallback : labels;
  }
}

class _CourtOptionGroup extends StatelessWidget {
  const _CourtOptionGroup({
    required this.title,
    required this.icon,
    required this.options,
    required this.icons,
    required this.selectedValues,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final List<String> options;
  final Map<String, IconData> icons;
  final Set<String> selectedValues;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final int selectedCount = selectedValues.length;
    final String countLabel = '$selectedCount/${options.length} selected';

    return VendorGroupedContentCard(
      title: title,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SelectionCountPill(label: countLabel),
          const SizedBox(height: AppDimens.sizeX10),
          _CourtOptionGrid(
            options: options,
            icons: icons,
            selectedValues: selectedValues,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _CourtOptionGrid extends StatelessWidget {
  const _CourtOptionGrid({
    required this.options,
    required this.icons,
    required this.selectedValues,
    required this.onTap,
  });

  final List<String> options;
  final Map<String, IconData> icons;
  final Set<String> selectedValues;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimens.sizeX8,
        mainAxisSpacing: AppDimens.sizeX8,
        mainAxisExtent: AppDimens.sizeX48,
      ),
      itemCount: options.length,
      itemBuilder: (BuildContext context, int index) {
        final String item = options[index];
        return VendorSelectableChip(
          label: item,
          icon: icons[item],
          isSelected: selectedValues.contains(item),
          onTap: () => onTap(item),
        );
      },
    );
  }
}

class _SelectionCountPill extends StatelessWidget {
  const _SelectionCountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
          color: LightColor.whiteColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
