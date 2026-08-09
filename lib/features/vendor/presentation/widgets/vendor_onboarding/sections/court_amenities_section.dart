import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_court_options_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_court_options/public_court_options_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class CourtAmenitiesSection extends StatefulWidget {
  const CourtAmenitiesSection({
    super.key,
    required this.cubit,
    required this.court,
    required this.subsectionIndex,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;
  final int subsectionIndex;

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
    );
    _ensureFetchedForSubstep(widget.subsectionIndex);
  }

  @override
  void didUpdateWidget(covariant CourtAmenitiesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.subsectionIndex != widget.subsectionIndex) {
      _ensureFetchedForSubstep(widget.subsectionIndex);
    }
  }

  void _ensureFetchedForSubstep(int subsection) {
    final PublicCourtOptionsState state = _optionsBloc.state;
    if (subsection == 1) {
      if (state.facilities.isEmpty && !state.isLoadingFacilities) {
        _optionsBloc.add(const FetchPublicFacilitiesEvent());
      }
    } else {
      if (state.amenities.isEmpty && !state.isLoadingAmenities) {
        _optionsBloc.add(const FetchPublicAmenitiesEvent());
      }
    }
  }

  @override
  void dispose() {
    _optionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFacilities = widget.subsectionIndex == 1;
    return BlocProvider<PublicCourtOptionsBloc>.value(
      value: _optionsBloc,
      child: BlocBuilder<PublicCourtOptionsBloc, PublicCourtOptionsState>(
        builder: (BuildContext context, PublicCourtOptionsState state) {
          final bool isLoading = isFacilities
              ? state.isLoadingFacilities && state.facilities.isEmpty
              : state.isLoadingAmenities && state.amenities.isEmpty;
          return VendorPanel(
            padding: AppUtils().getPadding(all: AppDimens.paddingX12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                VendorOnboardingSectionHeader(
                  title: isFacilities ? 'Facilities' : 'Amenities',
                  subtitle: isFacilities
                      ? 'Player-facing facilities available at this court.'
                      : 'Court-specific services and equipment.',
                  icon: isFacilities
                      ? Icons.meeting_room_rounded
                      : Icons.chair_alt_rounded,
                ),
                const SizedBox(height: AppDimens.sizeX12),
                if (isLoading)
                  const SizedBox(
                    height: 200,
                    child: Center(child: LoadingWidget()),
                  )
                else if (isFacilities)
                  _CourtOptionGroup(
                    title: StringConstants.facilities,
                    icon: Icons.meeting_room_rounded,
                    options: state.facilities,
                    selectedIds: widget.court.facilities,
                    onTap: widget.cubit.toggleCourtFacility,
                    emptyMessage:
                        'No facilities available right now. Please try again later.',
                  )
                else
                  _CourtOptionGroup(
                    title: StringConstants.amenities,
                    icon: Icons.chair_alt_rounded,
                    options: state.amenities,
                    selectedIds: widget.court.amenities,
                    onTap: widget.cubit.toggleCourtAmenity,
                    emptyMessage:
                        'No amenities available right now. Please try again later.',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CourtOptionGroup extends StatelessWidget {
  const _CourtOptionGroup({
    required this.title,
    required this.icon,
    required this.options,
    required this.selectedIds,
    required this.onTap,
    required this.emptyMessage,
  });

  final String title;
  final IconData icon;
  final List<PublicOptionModel> options;
  final Set<int> selectedIds;
  final ValueChanged<int> onTap;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final int selectedCount = selectedIds.length;
    final String countLabel = '$selectedCount/${options.length} selected';

    return VendorGroupedContentCard(
      title: title,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SelectionCountPill(label: countLabel),
          const SizedBox(height: AppDimens.sizeX10),
          if (options.isEmpty)
            _CourtOptionEmpty(message: emptyMessage)
          else
            _CourtOptionGrid(
              options: options,
              selectedIds: selectedIds,
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
    required this.selectedIds,
    required this.onTap,
  });

  final List<PublicOptionModel> options;
  final Set<int> selectedIds;
  final ValueChanged<int> onTap;

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
        final PublicOptionModel item = options[index];
        final int? id = item.idAsInt;
        if (id == null) return const SizedBox.shrink();
        return VendorSelectableChip(
          label: item.name,
          imageUrl: item.hasImage ? item.image : null,
          isSelected: selectedIds.contains(id),
          onTap: () => onTap(id),
        );
      },
    );
  }
}

class _CourtOptionEmpty extends StatelessWidget {
  const _CourtOptionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Text(
        message,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          height: 1.5,
        ),
      ),
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
          color: LightColor.inverseTextColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
