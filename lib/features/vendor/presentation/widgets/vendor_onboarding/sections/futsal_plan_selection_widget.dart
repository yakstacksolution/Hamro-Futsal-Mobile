import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/core/widgets/custom_html_viewer.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/public/data/model/public_package_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_packages_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_packages/public_packages_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class FutsalPlanSelectionWidget extends StatelessWidget {
  const FutsalPlanSelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final PublicPackagesBloc? existingBloc = _maybeExistingPackagesBloc(
      context,
    );

    if (existingBloc != null) {
      return BlocProvider<PublicPackagesBloc>.value(
        value: existingBloc,
        child: const _FutsalPlanSelectionContent(),
      );
    }

    final publicRepository = PublicRepositoryImpl();
    return BlocProvider<PublicPackagesBloc>(
      create: (_) =>
          PublicPackagesBloc(GetPublicPackagesUseCase(publicRepository)),
      child: const _FutsalPlanSelectionContent(),
    );
  }

  PublicPackagesBloc? _maybeExistingPackagesBloc(BuildContext context) {
    try {
      return BlocProvider.of<PublicPackagesBloc>(context, listen: false);
    } catch (_) {
      return null;
    }
  }
}

class _FutsalPlanSelectionContent extends StatefulWidget {
  const _FutsalPlanSelectionContent();

  @override
  State<_FutsalPlanSelectionContent> createState() =>
      _FutsalPlanSelectionContentState();
}

class _FutsalPlanSelectionContentState
    extends State<_FutsalPlanSelectionContent> {
  late final VendorOnboardingCubit _vendorOnboardingCubit;
  late final PublicPackagesBloc _publicPackagesBloc;

  @override
  void initState() {
    super.initState();

    _vendorOnboardingCubit = context.read<VendorOnboardingCubit>();
    _publicPackagesBloc = context.read<PublicPackagesBloc>();

    _publicPackagesBloc.add(const FetchPublicPackagesEvent());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncSelectionWithAvailablePackages(_publicPackagesBloc.state.packages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PublicPackagesBloc, PublicPackagesState>(
      listenWhen: (PublicPackagesState previous, PublicPackagesState current) {
        return previous.status != current.status ||
            previous.packages != current.packages;
      },
      listener: (BuildContext context, PublicPackagesState state) {
        if (state.status == PublicPackagesStatus.loading &&
            state.packages.isEmpty) {
          return;
        }
        _syncSelectionWithAvailablePackages(state.packages);
      },
      child: BlocBuilder<PublicPackagesBloc, PublicPackagesState>(
        builder: (BuildContext context, PublicPackagesState packagesState) {
          if (packagesState.status == PublicPackagesStatus.loading &&
              packagesState.packages.isEmpty) {
            return const SizedBox(
              height: 140,
              child: Center(child: LoadingWidget()),
            );
          }

          return BlocBuilder<VendorOnboardingCubit, VendorOnboardingState>(
            builder: (BuildContext context, VendorOnboardingState vendorState) {
              final double? selectedPercent =
                  vendorState.futsal.commissionPercent;
              final int? selectedPackageId = vendorState.futsal.packageId;
              final List<_PackageOption> packageOptions =
                  _resolvePackageOptions(packagesState.packages);

              return _buildCommissionPackages(
                packageOptions: packageOptions,
                selectedPackageId: selectedPackageId,
                selectedPercent: selectedPercent,
                futsalDraft: vendorState.futsal,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCommissionPackages({
    required List<_PackageOption> packageOptions,
    required int? selectedPackageId,
    required double? selectedPercent,
    required FutsalDraft futsalDraft,
  }) {
    const double spacing = 12;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double cardWidth = packageOptions.length == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: packageOptions
              .map((_PackageOption option) {
                final bool isSelected = selectedPackageId != null
                    ? selectedPackageId == option.id
                    : selectedPercent != null
                    ? (selectedPercent - option.percentage).abs() < 0.0001
                    : false;

                return SizedBox(
                  width: cardWidth,
                  child: _CommissionPackageCard(
                    title: option.title,
                    percentage: option.percentage,
                    isSelected: isSelected,
                    icon: option.icon,
                    color: LightColor.secondaryColor,
                    isRecommended: option.isPopular,
                    descriptionHtml: option.descriptionHtml,
                    onTap: () => _selectPackage(
                      option: option,
                      futsalDraft: futsalDraft,
                      isSelected: isSelected,
                      hasExistingSelection:
                          selectedPackageId != null || selectedPercent != null,
                    ),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }

  /// Applies [option] to the draft. Swapping an already-chosen plan changes
  /// the commission the vendor is billed at, so it is confirmed first; the
  /// very first pick has nothing to lose and goes straight through.
  Future<void> _selectPackage({
    required _PackageOption option,
    required FutsalDraft futsalDraft,
    required bool isSelected,
    required bool hasExistingSelection,
  }) async {
    if (isSelected) return;

    if (hasExistingSelection) {
      final bool confirmed = await showConfirmDialog(
        context: context,
        title: StringConstants.changeServicePlan,
        message: StringConstants.changeServicePlanConfirmation,
        confirmText: StringConstants.yesChange,
        cancelText: StringConstants.cancel,
        icon: Icons.swap_horiz_rounded,
      );
      if (!confirmed || !mounted) return;
    }

    _vendorOnboardingCubit.updateFutsal(
      futsalDraft.copyWith(
        packageId: option.id,
        commissionPercent: option.percentage,
      ),
    );
  }

  void _syncSelectionWithAvailablePackages(List<PublicPackageModel> packages) {
    final List<_PackageOption> options = _resolvePackageOptions(packages);
    if (options.isEmpty) return;

    final double? currentPercent =
        _vendorOnboardingCubit.state.futsal.commissionPercent;
    final int? currentPackageId = _vendorOnboardingCubit.state.futsal.packageId;
    if (currentPackageId != null &&
        options.any((_PackageOption option) => option.id == currentPackageId)) {
      return;
    }

    final _PackageOption? matchingPercentOption = currentPercent == null
        ? null
        : options
              .where(
                (_PackageOption option) =>
                    (option.percentage - currentPercent).abs() < 0.0001,
              )
              .firstOrNull;
    if (matchingPercentOption != null) {
      _vendorOnboardingCubit.updateFutsal(
        _vendorOnboardingCubit.state.futsal.copyWith(
          packageId: matchingPercentOption.id,
        ),
      );
      return;
    }

    final _PackageOption preferred =
        options.where((option) => option.isPopular).firstOrNull ??
        options.first;

    _vendorOnboardingCubit.updateFutsal(
      _vendorOnboardingCubit.state.futsal.copyWith(
        packageId: preferred.id,
        commissionPercent: preferred.percentage,
      ),
    );
  }

  List<_PackageOption> _resolvePackageOptions(List<PublicPackageModel> models) {
    final List<_PackageOption> parsed = models
        .map(_packageFromModel)
        .whereType<_PackageOption>()
        .toList(growable: false);

    if (parsed.isNotEmpty) {
      parsed.sort(
        (_PackageOption a, _PackageOption b) =>
            a.percentage.compareTo(b.percentage),
      );
      return parsed;
    }

    return const <_PackageOption>[
      _PackageOption(
        id: 1,
        title: StringConstants.basic,
        percentage: 5,
        isPopular: false,
        icon: Icons.rocket_launch_rounded,
        descriptionHtml:
            '<ul><li>Basic listing</li><li>Standard visibility</li><li>Email support</li></ul>',
      ),
      _PackageOption(
        id: 2,
        title: StringConstants.standard,
        percentage: 10,
        isPopular: true,
        icon: Icons.star_rounded,
        descriptionHtml:
            '<ul><li>Priority support</li><li>Featured listing</li><li>Activity logs</li><li>Detailed reports</li></ul>',
      ),
    ];
  }

  _PackageOption? _packageFromModel(PublicPackageModel package) {
    final double? percentage = _extractPercent(package);
    if (percentage == null) {
      return null;
    }

    final String title = package.name.trim().isEmpty
        ? 'Plan ${percentage.toInt()}%'
        : package.name.trim();

    return _PackageOption(
      id: int.tryParse(package.id) ?? _asInt(package.raw['id']),
      title: title,
      percentage: percentage,
      isPopular: _isPopularPackage(package),
      icon: _iconForPackage(package.name),
      descriptionHtml: package.description.trim().isEmpty
          ? '<p>Platform support based on selected package</p>'
          : package.description.trim(),
    );
  }

  double? _extractPercent(PublicPackageModel package) {
    final List<dynamic> candidates = <dynamic>[
      package.raw['percentage'],
      package.raw['package_percentage'],
      package.raw['commission_percentage'],
      package.raw['commission_percent'],
      package.raw['commission'],
      package.raw['percent'],
      package.raw['rate'],
      package.description,
      package.name,
    ];

    for (final dynamic candidate in candidates) {
      final double? parsed = _parsePercent(candidate);
      if (parsed != null) {
        return parsed;
      }
    }

    return null;
  }

  double? _parsePercent(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();

    final String text = value.toString().trim();
    if (text.isEmpty) return null;

    final RegExp matchRegex = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*%?');
    final RegExpMatch? match = matchRegex.firstMatch(text);
    if (match == null) return null;

    return double.tryParse(match.group(1) ?? '');
  }

  bool _isPopularPackage(PublicPackageModel package) {
    final List<dynamic> flags = <dynamic>[
      package.raw['is_popular'],
      package.raw['isPopular'],
      package.raw['popular'],
      package.raw['recommended'],
      package.raw['is_recommended'],
      package.raw['is_default'],
      package.raw['default'],
    ];

    for (final dynamic value in flags) {
      if (_isTruthy(value)) {
        return true;
      }
    }

    final String combined = '${package.name} ${package.description}'
        .toLowerCase();
    return combined.contains('popular') || combined.contains('recommended');
  }

  bool _isTruthy(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;

    final String normalized = value.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  IconData _iconForPackage(String name) {
    final String normalized = name.trim().toLowerCase();

    if (normalized.contains('basic') || normalized.contains('starter')) {
      return Icons.rocket_launch_rounded;
    }
    if (normalized.contains('standard') || normalized.contains('popular')) {
      return Icons.star_rounded;
    }
    if (normalized.contains('premium') || normalized.contains('pro')) {
      return Icons.workspace_premium_rounded;
    }
    return Icons.local_offer_rounded;
  }
}

class _PackageOption {
  const _PackageOption({
    required this.id,
    required this.title,
    required this.percentage,
    required this.isPopular,
    required this.icon,
    required this.descriptionHtml,
  });

  final int id;
  final String title;
  final double percentage;
  final bool isPopular;
  final IconData icon;
  final String descriptionHtml;
}

class _CommissionPackageCard extends StatelessWidget {
  const _CommissionPackageCard({
    required this.title,
    required this.percentage,
    required this.isSelected,
    required this.icon,
    required this.color,
    required this.descriptionHtml,
    required this.onTap,
    this.isRecommended = false,
  });

  final String title;
  final double percentage;
  final bool isSelected;
  final IconData icon;
  final Color color;
  final String descriptionHtml;
  final VoidCallback onTap;
  final bool isRecommended;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : LightColor.elevatedCardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX16),
          border: Border.all(
            color: isSelected ? color : LightColor.greyBorderColor,
            width: isSelected ? 1 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: AppUtils().getPadding(all: AppDimens.paddingX8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: AppUtils().getPadding(
                          all: AppDimens.paddingX8,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX12,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: AppDimens.sizeX20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sizeX14),
                  Text(
                    title,
                    style: FutsalTheme.getTextTheme(context).bodyTextMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? color
                              : LightColor.primaryTextColor,
                        ),
                  ),
                  const SizedBox(height: AppDimens.sizeX4),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${percentage.toInt()}%',
                          style: FutsalTheme.getTextTheme(context).headingSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                        ),
                        TextSpan(
                          text: StringConstants.bookingUnitSuffix,
                          style: FutsalTheme.getTextTheme(context).bodyTextSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: LightColor.hintTextColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimens.sizeX14),
                  CustomHtmlViewer(
                    html: descriptionHtml,
                    textStyle: FutsalTheme.getTextTheme(context).bodyTextSmall
                        ?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: LightColor.secondaryTextColor,
                        ),
                  ),
                ],
              ),
            ),
            if (isRecommended)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: AppUtils().getPadding(
                    horizontal: AppDimens.paddingX10,
                    vertical: AppDimens.paddingX4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(AppDimens.radiusX14),
                      bottomLeft: Radius.circular(AppDimens.radiusX10),
                    ),
                  ),
                  child: Text(
                    StringConstants.popular,
                    style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                        ?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: LightColor.onBrandSurface,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
