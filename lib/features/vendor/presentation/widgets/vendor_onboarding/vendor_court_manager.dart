import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_delete_dialog.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/courts/data/repositories/venue_court_repository_impl.dart';
import 'package:hamro_footsall/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_templates_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_footsall/features/vendor/data/repositories/vendor_onboarding_repository_impl.dart';
import 'package:hamro_footsall/features/vendor/data/vendor_draft_repository.dart';
import 'package:hamro_footsall/features/vendor/domain/usecase/vendor_onboarding_usecase.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_bottom_action_bar.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_onboarding_step_content.dart';

class VendorCourtManager extends StatelessWidget {
  const VendorCourtManager({
    super.key,
    required this.cubit,
    required this.state,
  });

  final VendorOnboardingCubit cubit;
  final VendorOnboardingState state;

  Future<void> _showAddCourtSheet(BuildContext context) async {
    final String? courtName = await showAppBottomSheet<String>(
      context: context,
      child: const _AddCourtSheet(),
    );

    if (courtName != null) {
      cubit.addCourt(name: courtName);
      final String? courtId = cubit.state.activeCourtId;
      if (context.mounted && courtId != null) {
        unawaited(_openCourtEditor(context, courtId, resolveRemote: false));
      }
    }
  }

  Future<void> _openCourtEditor(
    BuildContext context,
    String courtId, {
    bool resolveRemote = true,
  }) async {
    // Find the court being opened in the shared onboarding state.
    CourtDraft? court;
    for (final CourtDraft item in cubit.state.courts) {
      if (item.id == courtId) {
        court = item;
        break;
      }
    }
    if (court == null) return;

    final int? venueId = cubit.state.remoteFutsalId;
    final CourtDraft resolvedCourt = resolveRemote
        ? await _resolveRemoteCourt(court, venueId)
        : court;
    final CourtDraft editorCourt = resolveRemote
        ? await _fetchCourtDetailsForEditor(resolvedCourt)
        : resolvedCourt;
    if (!context.mounted) return;

    final VendorOnboardingCubit editorCubit = VendorOnboardingCubit(
      const EphemeralVendorDraftRepository(),
      onboardingUseCase: VendorOnboardingUseCase(
        VendorOnboardingRepositoryImpl(),
      ),
    );
    if (venueId != null) {
      editorCubit.setRemoteFutsalId(venueId);
    }
    editorCubit.prepareCourtForEditing(editorCourt);
    final String editorCourtId =
        editorCourt.remoteId?.toString() ?? editorCourt.id;
    editorCubit.openCourtForEditing(editorCourtId);

    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name: '/vendor/court-onboarding/$editorCourtId',
        ),
        builder: (_) => MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<VendorOnboardingCubit>(create: (_) => editorCubit),
            BlocProvider<PublicTemplatesBloc>(
              create: (_) => PublicTemplatesBloc(
                GetPublicTemplatesUseCase(PublicRepositoryImpl()),
              )..add(FetchPublicTemplatesEvent()),
            ),
          ],
          child: CourtOnboardingPage(courtId: editorCourtId),
        ),
      ),
    );

    final List<CourtDraft> editedCourts = editorCubit.state.courts;
    if (editedCourts.isNotEmpty) {
      cubit.upsertCourt(editedCourts.first);
    }
  }

  Future<CourtDraft> _resolveRemoteCourt(CourtDraft court, int? venueId) async {
    if (court.remoteId != null || int.tryParse(court.id) != null) {
      return court;
    }
    if (venueId == null) return court;

    final VendorOnboardingUseCase useCase = VendorOnboardingUseCase(
      VendorOnboardingRepositoryImpl(),
    );
    final response = await useCase.fetchCourtsByVenueId(venueId);

    return response.fold((_) => court, (List<CourtDraft> remoteCourts) {
      if (remoteCourts.isEmpty) return court;

      cubit.replaceCourts(remoteCourts);

      for (final CourtDraft remoteCourt in remoteCourts) {
        if (remoteCourt.id == court.id ||
            remoteCourt.remoteId?.toString() == court.id ||
            (court.remoteId != null &&
                remoteCourt.remoteId == court.remoteId)) {
          return remoteCourt;
        }
      }

      final String courtName = court.name.trim().toLowerCase();
      if (courtName.isNotEmpty) {
        for (final CourtDraft remoteCourt in remoteCourts) {
          if (remoteCourt.name.trim().toLowerCase() == courtName) {
            return remoteCourt;
          }
        }
      }

      return court;
    });
  }

  Future<CourtDraft> _fetchCourtDetailsForEditor(CourtDraft court) async {
    final int? courtId = court.remoteId ?? int.tryParse(court.id);
    if (courtId == null) return court;

    final response = await GetVenueCourtUseCase(
      VenueCourtRepositoryImpl(),
    ).getCourtDetails(courtId);

    return response.fold((_) => court, (CourtDraft details) => details);
  }

  Future<void> _confirmRemoveCourt(
    BuildContext context,
    CourtDraft court,
    String courtName,
  ) async {
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: 'Delete Court?',
      message:
          'Are you sure you want to delete "$courtName"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_outline_rounded,
      confirmColor: LightColor.redColor,
    );

    if (!confirmed || !context.mounted) return;

    // A court that was never persisted has no remote id, so there is nothing to
    // delete on the server — just drop it from local state.
    final int? remoteCourtId = court.remoteId ?? int.tryParse(court.id);
    if (remoteCourtId == null) {
      cubit.removeCourt(court.id);
      return;
    }

    // Block the UI with a loader while the delete request is in flight.
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CustomLoading(
            color: LightColor.secondaryColor,
            size: 36,
            strokeWidth: 3.5,
            secondCircleColor: LightColor.secondaryLight,
            thirdCircleColor: LightColor.secondaryLight,
          ),
        ),
      ),
    );

    final String? error = await cubit.deleteCourtById(remoteCourtId);
    if (!context.mounted) return;

    // Dismiss the loader.
    Navigator.of(context, rootNavigator: true).pop();

    if (error != null) {
      AppUtils().showSnackBar(context, MsgType.error, error);
      return;
    }

    cubit.removeCourt(court.id);
    AppUtils().showSnackBar(
      context,
      MsgType.success,
      '"$courtName" deleted successfully.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Courts',
                      style: FutsalTheme.getTextTheme(context).bodyTextMedium
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    SizedBox(height: AppDimens.sizeX2),
                    Text(
                      'Manage courts in compact view',
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: LightColor.secondaryTextColor,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimens.sizeX10),
              _AddCourtButton(onTap: () => _showAddCourtSheet(context)),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (state.isLoadingCourts)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX24),
              child: Center(
                child: CustomLoading(
                  color: LightColor.secondaryColor,
                  size: 30,
                  strokeWidth: 3.5,
                  secondCircleColor: LightColor.secondaryLight,
                  thirdCircleColor: LightColor.secondaryLight,
                ),
              ),
            )
          else if (state.courts.isEmpty)
            GestureDetector(
              onTap: () => _showAddCourtSheet(context),
              child: const _CourtEmptyStateCompact(),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.courts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimens.sizeX10),
              itemBuilder: (BuildContext context, int index) {
                final CourtDraft court = state.courts[index];
                final int completedSections = _completedSectionCount(court);
                return _CourtListTile(
                  court: court,
                  isSelected: state.activeCourtId == court.id,
                  completedSections: completedSections,
                  totalSections: courtSectionDefinitions.length,
                  onTap: () => unawaited(_openCourtEditor(context, court.id)),
                  onRemove: () => _confirmRemoveCourt(
                    context,
                    court,
                    court.name.trim().isEmpty
                        ? 'Unnamed Court'
                        : court.name.trim(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  int _completedSectionCount(CourtDraft court) {
    int completedSections = 0;
    for (
      int sectionIndex = 0;
      sectionIndex < courtSectionDefinitions.length;
      sectionIndex++
    ) {
      if (cubit.courtSectionStatus(court.id, sectionIndex) ==
          StepStatus.complete) {
        completedSections++;
      }
    }
    return completedSections;
  }
}

class _AddCourtButton extends StatelessWidget {
  const _AddCourtButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.secondaryColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Padding(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.add_rounded,
                size: AppDimens.sizeX12,
                color: LightColor.whiteColor,
              ),
              SizedBox(width: AppDimens.sizeX4),
              Text(
                'New Court',
                style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                  color: LightColor.whiteColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourtEmptyStateCompact extends StatelessWidget {
  const _CourtEmptyStateCompact();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX42,
            height: AppDimens.sizeX42,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: const Icon(
              Icons.stadium_rounded,
              color: LightColor.whiteColor,
              size: AppDimens.sizeX20,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No courts yet',
                  style: FutsalTheme.getTextTheme(
                    context,
                  ).bodyTextMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: AppDimens.sizeX4),
                Text(
                  'Add your first court to continue setup.',
                  style: FutsalTheme.getTextTheme(context).bodySubTitle
                      ?.copyWith(color: LightColor.secondaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtListTile extends StatelessWidget {
  const _CourtListTile({
    required this.court,
    required this.isSelected,
    required this.completedSections,
    required this.totalSections,
    required this.onTap,
    required this.onRemove,
  });

  final CourtDraft court;
  final bool isSelected;
  final int completedSections;
  final int totalSections;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    final String courtName = court.name.trim().isEmpty
        ? 'Unnamed Court'
        : court.name.trim();
    final bool isComplete =
        totalSections > 0 && completedSections == totalSections;
    final double progress = totalSections == 0
        ? 0
        : (completedSections / totalSections).clamp(0, 1);
    final int progressPercent = (progress * 100).round();

    final UploadRef? coverImage = court.photos.isNotEmpty
        ? court.photos.first
        : (court.memories.isNotEmpty ? court.memories.first : null);

    final int slotCount = court.slotCount ?? court.slotConfigs.length;
    final String price = formatDouble(court.basePrice);
    final String courtType = court.courtType?.trim() ?? '';
    final String matchFormat = court.matchFormat?.trim() ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Ink(
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: LightColor.greyBorderColor,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _CourtThumbnail(image: coverImage),
                  const SizedBox(width: AppDimens.sizeX12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                courtName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyTextMedium?.copyWith(
                                  color: LightColor.primaryTextColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppDimens.sizeX8),
                            _RemoveButton(onTap: onRemove),
                          ],
                        ),
                        const SizedBox(height: AppDimens.sizeX6),
                        Wrap(
                          spacing: AppDimens.sizeX6,
                          runSpacing: AppDimens.sizeX6,
                          children: <Widget>[
                            if (courtType.isNotEmpty)
                              _InfoChip(
                                icon: Icons.stadium_rounded,
                                label: courtType,
                              ),
                            if (matchFormat.isNotEmpty)
                              _InfoChip(
                                icon: Icons.sports_soccer_rounded,
                                label: matchFormat,
                              ),
                            _InfoChip(
                              icon: Icons.schedule_rounded,
                              label:
                                  '$slotCount ${slotCount == 1 ? 'slot' : 'slots'}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    price.isEmpty ? '—' : 'Rs $price',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isComplete ? 'Complete' : '$progressPercent%',
                    style: textTheme.bodyMiniSubTitle?.copyWith(
                      color: isComplete
                          ? LightColor.secondaryColor
                          : LightColor.secondaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusX4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: AppDimens.sizeX3,
                  backgroundColor: LightColor.greyBorderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete
                        ? LightColor.secondaryColor
                        : LightColor.secondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX6,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX4),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: AppDimens.sizeX12,
            color: LightColor.secondaryTextColor,
          ),
          const SizedBox(width: AppDimens.sizeX4),
          Text(
            label,
            style: FutsalTheme.getTextTheme(
              context,
            ).bodyMiniSubTitle?.copyWith(color: LightColor.primaryTextColor),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: AppDimens.sizeX28,
        height: AppDimens.sizeX28,
        decoration: BoxDecoration(
          color: LightColor.primaryTextColor.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          size: AppDimens.sizeX12,
          color: LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}

class _CourtThumbnail extends StatelessWidget {
  const _CourtThumbnail({required this.image});

  final UploadRef? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.sizeX58,
      height: AppDimens.sizeX58,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: image?.remoteUrl?.trim().isNotEmpty == true
          ? CustomImageView(
              url: image!.remoteUrl,
              width: AppDimens.sizeX58,
              height: AppDimens.sizeX58,
              fit: BoxFit.cover,
            )
          : const Icon(
              Icons.stadium_rounded,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX24,
            ),
    );
  }
}

class CourtOnboardingPage extends StatefulWidget {
  const CourtOnboardingPage({super.key, required this.courtId});

  final String courtId;

  @override
  State<CourtOnboardingPage> createState() => CourtOnboardingPageState();
}

class CourtOnboardingPageState extends State<CourtOnboardingPage> {
  late final VendorOnboardingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<VendorOnboardingCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cubit.openCourtForEditing(widget.courtId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOnboardingCubit, VendorOnboardingState>(
      bloc: _cubit,
      builder: (BuildContext context, VendorOnboardingState state) {
        final CourtDraft? court = _visibleCourt(state);
        final String courtName = court == null || court.name.trim().isEmpty
            ? 'Court Setup'
            : court.name.trim();

        return Scaffold(
          backgroundColor: LightColor.whiteColor,
          appBar: AppBar(
            title: Text(
              courtName,
              style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
            leading: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: LightColor.primaryTextColor,
                size: AppDimens.sizeX18,
              ),
            ),
            backgroundColor: LightColor.whiteColor,
            elevation: 0,
            surfaceTintColor: LightColor.background,
            foregroundColor: LightColor.primaryTextColor,
          ),
          bottomNavigationBar: (court == null || state.isLoadingCourtDetails)
              ? null
              : VendorBottomActionBar(
                  hasPrevious: true,
                  isSubmitting: state.isSubmitting,
                  nextLabel: _cubit.nextButtonLabel,
                  onPrevious: () {
                    if (_cubit.currentSectionIndex == 0 &&
                        _cubit.currentSubstepIndex == 0) {
                      Navigator.of(context).maybePop();
                      return;
                    }
                    _cubit.previous();
                  },
                  onNext: () async {
                    await _cubit.next();
                    if (!context.mounted) return;
                    if (!_cubit.state.isInCourtCategory ||
                        _cubit.state.activeCourtId != widget.courtId) {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
          body: SafeArea(
            top: false,
            child: state.isLoadingCourtDetails
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimens.paddingX24),
                      child: CustomLoading(
                        color: LightColor.secondaryColor,
                        size: 30,
                        strokeWidth: 3.5,
                        secondCircleColor: LightColor.secondaryLight,
                        thirdCircleColor: LightColor.secondaryLight,
                      ),
                    ),
                  )
                : court == null
                ? const Center(child: Text('Court not found.'))
                : SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: AppUtils().getPadding(
                      horizontal: AppDimens.paddingX12,
                      vertical: AppDimens.paddingX10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        VendorOnboardingStepContent(
                          title: 'Court Setup',
                          cubit: _cubit,
                          state: state,
                          court: court,
                          errorSpacing: AppDimens.sizeX10,
                          contentSpacing: AppDimens.sizeX12,
                        ),
                        const SizedBox(height: AppDimens.sizeX90),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  CourtDraft? _visibleCourt(VendorOnboardingState state) {
    for (final CourtDraft item in state.courts) {
      if (item.id == widget.courtId ||
          item.remoteId?.toString() == widget.courtId) {
        return item;
      }
    }

    final CourtDraft? activeCourt = state.activeCourt;
    if (activeCourt != null) {
      return activeCourt;
    }

    return state.courts.length == 1 ? state.courts.first : null;
  }
}

class _AddCourtSheet extends StatefulWidget {
  const _AddCourtSheet();

  @override
  State<_AddCourtSheet> createState() => _AddCourtSheetState();
}

class _AddCourtSheetState extends State<_AddCourtSheet> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Add New Court',
          style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX10),
        Text(
          'Enter a name for the court. You can change it later. \nMake sure to use a proper standard name for the court.',
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX18),
        CustomTextField(
          controller: _nameController,
          focusNode: _focusNode,
          labelText: 'Court Name',
          hintText: 'e.g. Court A, Main Field',
          icon: Icons.sports_soccer_rounded,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppDimens.sizeX20),
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                isOutlined: true,
                backgroundColor: Colors.white,
                foregroundColor: LightColor.secondaryColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX46,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX14),
            Expanded(
              child: CustomButton(
                text: 'Add Court',
                minHeight: AppDimens.sizeX46,
                onPressed: _submit,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sizeX20),
      ],
    );
  }
}
