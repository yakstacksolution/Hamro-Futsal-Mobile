import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/public/data/model/public_option_model.dart';
import 'package:hamro_futsal/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_court_options_use_case.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/public_court_options/public_court_options_bloc.dart';
import 'package:hamro_futsal/features/public/presentation/models/venue_filter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class VenueFilterPage extends StatelessWidget {
  const VenueFilterPage({super.key, this.initialFilter = VenueFilter.empty});

  final VenueFilter initialFilter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PublicCourtOptionsBloc>(
      create: (_) =>
          PublicCourtOptionsBloc(GetCourtOptionsUseCase(PublicRepositoryImpl()))
            ..add(const FetchPublicCourtOptionsEvent()),
      child: _VenueFilterView(initialFilter: initialFilter),
    );
  }
}

class _VenueFilterView extends StatefulWidget {
  const _VenueFilterView({required this.initialFilter});

  final VenueFilter initialFilter;

  @override
  State<_VenueFilterView> createState() => _VenueFilterViewState();
}

class _VenueFilterViewState extends State<_VenueFilterView> {
  static const double _priceMin = 0;
  static const double _priceMax = 5000;

  static const List<_TimeSlotOption> _timeSlotOptions = <_TimeSlotOption>[
    _TimeSlotOption(
      key: '06:00-12:00',
      label: StringConstants.morning,
      range: '06:00 AM - 12:00 PM',
      icon: Icons.wb_sunny_rounded,
    ),
    _TimeSlotOption(
      key: '12:00-18:00',
      label: StringConstants.afternoon,
      range: '12:00 PM - 06:00 PM',
      icon: Icons.wb_twilight_rounded,
    ),
    _TimeSlotOption(
      key: '18:00-00:00',
      label: StringConstants.evening,
      range: '06:00 PM - 12:00 AM',
      icon: Icons.nightlight_round,
    ),
  ];

  late RangeValues _priceRange;
  late Set<String> _timeSlots;
  int? _matchTypeId;
  int? _courtTypeId;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    final VenueFilter f = widget.initialFilter;
    _priceRange = RangeValues(
      (f.minPrice ?? _priceMin).clamp(_priceMin, _priceMax),
      (f.maxPrice ?? _priceMax).clamp(_priceMin, _priceMax),
    );
    _timeSlots = <String>{...f.timeSlots};
    _matchTypeId = f.matchTypeId;
    _courtTypeId = f.courtTypeId;
    _minRating = f.minRating;
  }

  bool get _isPriceConstrained =>
      _priceRange.start > _priceMin || _priceRange.end < _priceMax;

  int get _activeFilterCount {
    int count = 0;
    if (_isPriceConstrained) count += 1;
    if (_matchTypeId != null) count += 1;
    if (_courtTypeId != null) count += 1;
    if (_minRating != null) count += 1;
    if (_timeSlots.isNotEmpty) count += 1;
    return count;
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(_priceMin, _priceMax);
      _timeSlots = <String>{};
      _matchTypeId = null;
      _courtTypeId = null;
      _minRating = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      VenueFilter(
        minPrice: _isPriceConstrained ? _priceRange.start : null,
        maxPrice: _isPriceConstrained ? _priceRange.end : null,
        matchTypeId: _matchTypeId,
        courtTypeId: _courtTypeId,
        timeSlots: _timeSlots,
        minRating: _minRating,
      ),
    );
  }

  void _toggle(Set<String> target, String value) {
    setState(() {
      if (target.contains(value)) {
        target.remove(value);
      } else {
        target.add(value);
      }
    });
  }

  List<PublicOptionModel> _selectableOptions(List<PublicOptionModel> options) {
    return options
        .where(
          (PublicOptionModel option) =>
              option.idAsInt != null && option.name.trim().isNotEmpty,
        )
        .toList(growable: false);
  }

  void _selectMatchType(PublicOptionModel option) {
    setState(() {
      final int id = option.idAsInt!;
      _matchTypeId = _matchTypeId == id ? null : id;
    });
  }

  void _selectCourtType(PublicOptionModel option) {
    setState(() {
      final int id = option.idAsInt!;
      _courtTypeId = _courtTypeId == id ? null : id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: AppBar(
        backgroundColor: LightColor.background,
        elevation: 0,
        surfaceTintColor: LightColor.background,
        centerTitle: false,
        leading: IconButton(
          tooltip: StringConstants.close,
          icon: Icon(
            Icons.close_rounded,
            size: AppDimens.sizeX20,
            color: LightColor.primaryTextColor,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          StringConstants.filtersAndSorting,
          style: textTheme.bodyTextMedium?.copyWith(
            fontSize: AppDimens.fontBodyTextLarge,
            fontWeight: FontWeight.w700,
            color: LightColor.primaryTextColor,
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.paddingX12),
            child: TextButton(
              onPressed: _reset,
              style: TextButton.styleFrom(
                foregroundColor: LightColor.brandTextColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX10,
                  vertical: AppDimens.paddingX8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
              ),
              child: Text(
                StringConstants.reset,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        activeFilterCount: _activeFilterCount,
        onClearAll: _reset,
        onApply: _apply,
      ),
      body: BlocBuilder<PublicCourtOptionsBloc, PublicCourtOptionsState>(
        builder: (BuildContext context, PublicCourtOptionsState optionsState) {
          final List<PublicOptionModel> matchTypeOptions = _selectableOptions(
            optionsState.matchFormats,
          );
          final List<PublicOptionModel> courtTypeOptions = _selectableOptions(
            optionsState.courtTypes,
          );

          final List<Widget> primary = <Widget>[
            _FilterSectionCard(
              icon: Icons.payments_outlined,
              title: StringConstants.priceRange,
              subtitle: 'Set your hourly budget',
              trailing: _SelectionPill(
                label:
                    '${_priceLabel(_priceRange.start)} – ${_priceLabel(_priceRange.end)}',
              ),
              child: Column(
                children: <Widget>[
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      activeTrackColor: LightColor.secondaryColor,
                      inactiveTrackColor: LightColor.dividerColor,
                      thumbColor: LightColor.inverseTextColor,
                      overlayColor: LightColor.secondaryColor.withValues(
                        alpha: 0.12,
                      ),
                      rangeThumbShape: const RoundRangeSliderThumbShape(
                        enabledThumbRadius: 11,
                        elevation: 2,
                      ),
                      rangeTickMarkShape: const RoundRangeSliderTickMarkShape(
                        tickMarkRadius: 0,
                      ),
                      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
                      rangeValueIndicatorShape:
                          const PaddleRangeSliderValueIndicatorShape(),
                      valueIndicatorColor: LightColor.secondaryColor,
                    ),
                    child: RangeSlider(
                      values: _priceRange,
                      min: _priceMin,
                      max: _priceMax,
                      divisions: 50,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.sizeX4,
                      ),
                      labels: RangeLabels(
                        _priceLabel(_priceRange.start),
                        _priceLabel(_priceRange.end),
                      ),
                      onChanged: (RangeValues value) =>
                          setState(() => _priceRange = value),
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _PriceBoundary(
                          label: 'Minimum',
                          value: _priceLabel(_priceRange.start),
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX10),
                      Expanded(
                        child: _PriceBoundary(
                          label: 'Maximum',
                          value: _priceLabel(_priceRange.end),
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            _FilterSectionCard(
              icon: Icons.stadium_outlined,
              title: 'Court preferences',
              subtitle: 'Choose the court and match you prefer',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _FilterFieldLabel(title: StringConstants.matchType),
                  const SizedBox(height: AppDimens.paddingX10),
                  _OptionStateView(
                    status: optionsState.status,
                    isEmpty: matchTypeOptions.isEmpty,
                    emptyMessage: StringConstants.noMatchFormatsAvailable,
                    errorMessage: optionsState.errorMessage,
                    loading: const _PillRowLoading(),
                    child: Wrap(
                      spacing: AppDimens.paddingX8,
                      runSpacing: AppDimens.paddingX8,
                      children: matchTypeOptions
                          .map((PublicOptionModel option) {
                            return _PillChip(
                              label: option.name,
                              isSelected: _matchTypeId == option.idAsInt,
                              onTap: () => _selectMatchType(option),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppDimens.paddingX16,
                    ),
                    child: Divider(height: 1),
                  ),
                  const _FilterFieldLabel(title: StringConstants.courtType),
                  const SizedBox(height: AppDimens.paddingX10),
                  _OptionStateView(
                    status: optionsState.status,
                    isEmpty: courtTypeOptions.isEmpty,
                    emptyMessage: StringConstants.noCourtTypesAvailable,
                    errorMessage: optionsState.errorMessage,
                    loading: const _CourtTypeRowLoading(),
                    child: _CourtTypeGrid(
                      options: courtTypeOptions,
                      selectedId: _courtTypeId,
                      onTap: _selectCourtType,
                    ),
                  ),
                ],
              ),
            ),
          ];

          final List<Widget> secondary = <Widget>[
            _FilterSectionCard(
              icon: Icons.star_outline_rounded,
              title: StringConstants.rating,
              subtitle: 'Only show courts with your preferred rating',
              trailing: _SelectionPill(
                label: _minRating == null
                    ? 'Any rating'
                    : '${_minRating!.toStringAsFixed(1)} & up',
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _RatingSelector(
                    value: _minRating,
                    onChanged: (double? value) =>
                        setState(() => _minRating = value),
                  ),
                  const SizedBox(height: AppDimens.paddingX6),
                  Text(
                    'Tap a star to set the minimum venue rating.',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontSize: AppDimens.fontBodySubTitle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            _FilterSectionCard(
              icon: Icons.schedule_outlined,
              title: StringConstants.timeSlots,
              subtitle: 'Select one or more convenient play times',
              child: Column(
                children: List<Widget>.generate(_timeSlotOptions.length, (
                  int index,
                ) {
                  final _TimeSlotOption slot = _timeSlotOptions[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _timeSlotOptions.length - 1
                          ? 0
                          : AppDimens.paddingX10,
                    ),
                    child: _TimeSlotRow(
                      option: slot,
                      isSelected: _timeSlots.contains(slot.key),
                      onTap: () => _toggle(_timeSlots, slot.key),
                    ),
                  );
                }),
              ),
            ),
          ];

          final EdgeInsets padding = EdgeInsets.only(
            left: context.responsive<double>(
              mobile: AppDimens.paddingX16,
              tablet: AppDimens.paddingX32,
            ),
            right: context.responsive<double>(
              mobile: AppDimens.paddingX16,
              tablet: AppDimens.paddingX32,
            ),
            top: AppDimens.paddingX12,
            bottom: AppDimens.paddingX125 + AppDimens.paddingX12,
          );

          return ListView(
            padding: padding,
            children: <Widget>[
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.isDesktop
                        ? AppDimens.filterDesktopMaxWidth
                        : context.isTablet
                        ? AppDimens.filterColumnMaxWidth
                        : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _FilterOverview(activeFilterCount: _activeFilterCount),
                      const SizedBox(height: AppDimens.paddingX16),
                      if (context.isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: primary,
                              ),
                            ),
                            const SizedBox(width: AppDimens.paddingX20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: secondary,
                              ),
                            ),
                          ],
                        )
                      else ...<Widget>[...primary, ...secondary],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _priceLabel(double value) => 'Rs ${value.round()}';
}

class _TimeSlotOption {
  const _TimeSlotOption({
    required this.key,
    required this.label,
    required this.range,
    required this.icon,
  });

  final String key;
  final String label;
  final String range;
  final IconData icon;
}

class _FilterOverview extends StatelessWidget {
  const _FilterOverview({required this.activeFilterCount});

  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool hasFilters = activeFilterCount > 0;
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX44,
            height: AppDimens.sizeX44,
            decoration: BoxDecoration(
              color: LightColor.secondarySoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: LightColor.brandTextColor,
              size: AppDimens.sizeX22,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  hasFilters
                      ? 'Your preferences are ready'
                      : 'Refine your search',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  hasFilters
                      ? 'Adjust selections or apply them to see matching courts.'
                      : 'Choose a budget, court type, rating, or play time.',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (hasFilters) _SelectionPill(label: '$activeFilterCount selected'),
        ],
      ),
    );
  }
}

class _FilterSectionCard extends StatelessWidget {
  const _FilterSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowOf(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX36,
                decoration: BoxDecoration(
                  color: LightColor.secondarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: Icon(
                  icon,
                  size: AppDimens.sizeX18,
                  color: LightColor.brandTextColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      subtitle,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: AppDimens.paddingX8),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppDimens.paddingX16),
          child,
        ],
      ),
    );
  }
}

class _FilterFieldLabel extends StatelessWidget {
  const _FilterFieldLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
        color: LightColor.primaryTextColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SelectionPill extends StatelessWidget {
  const _SelectionPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: LightColor.secondarySoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        label,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.brandTextColor,
          fontSize: AppDimens.fontBodyMiniSubTitle,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PriceBoundary extends StatelessWidget {
  const _PriceBoundary({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final CrossAxisAlignment alignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX8,
      ),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Column(
        crossAxisAlignment: alignment,
        children: <Widget>[
          Text(
            label,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontSize: AppDimens.fontBodyMiniSubTitle,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX2),
          Text(
            value,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionStateView extends StatelessWidget {
  const _OptionStateView({
    required this.status,
    required this.isEmpty,
    required this.emptyMessage,
    required this.child,
    required this.loading,
    this.errorMessage,
  });

  final PublicCourtOptionsStatus status;
  final bool isEmpty;
  final String emptyMessage;
  final String? errorMessage;
  final Widget child;
  final Widget loading;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    if (status == PublicCourtOptionsStatus.loading ||
        status == PublicCourtOptionsStatus.idle) {
      return loading;
    }

    if (status == PublicCourtOptionsStatus.failure && isEmpty) {
      return Text(
        errorMessage ?? 'Could not load options.',
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.redColor,
          height: 1.4,
        ),
      );
    }

    if (isEmpty) {
      return Text(
        emptyMessage,
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          height: 1.4,
        ),
      );
    }

    return child;
  }
}

/// Single shimmer row of pill placeholders for the Match Type section.
class _PillRowLoading extends StatelessWidget {
  const _PillRowLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: LightColor.skeletonBaseColor,
      highlightColor: LightColor.skeletonHighlightColor,
      child: Row(
        children: const <Widget>[
          _SkeletonBlock(width: AppDimens.sizeX70, height: AppDimens.sizeX38),
          SizedBox(width: AppDimens.paddingX8),
          _SkeletonBlock(width: AppDimens.sizeX90, height: AppDimens.sizeX38),
          SizedBox(width: AppDimens.paddingX8),
          _SkeletonBlock(width: AppDimens.sizeX60, height: AppDimens.sizeX38),
        ],
      ),
    );
  }
}

/// Single shimmer row of two card placeholders for the Court Type section.
class _CourtTypeRowLoading extends StatelessWidget {
  const _CourtTypeRowLoading();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: LightColor.skeletonBaseColor,
      highlightColor: LightColor.skeletonHighlightColor,
      child: Row(
        children: const <Widget>[
          Expanded(
            child: _SkeletonBlock(
              height: AppDimens.sizeX50,
              radius: AppDimens.radiusX8,
            ),
          ),
          SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: _SkeletonBlock(
              height: AppDimens.sizeX50,
              radius: AppDimens.radiusX8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.height,
    this.width,
    this.radius = AppDimens.radiusX6,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: LightColor.skeletonBaseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _RatingSelector extends StatelessWidget {
  const _RatingSelector({required this.value, required this.onChanged});

  final double? value;
  final ValueChanged<double?> onChanged;

  @override
  Widget build(BuildContext context) {
    final double current = value ?? 0;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          KeyedSubtree(
            key: ValueKey<double?>(value),
            child: RatingBar.builder(
              initialRating: current,
              minRating: 0,
              allowHalfRating: true,
              glow: false,
              itemCount: 5,
              itemSize: AppDimens.sizeX38,
              unratedColor: LightColor.dividerColor,

              itemPadding: EdgeInsets.only(right: AppDimens.sizeX6),
              itemBuilder: (BuildContext context, int index) =>
                  Icon(Icons.star_rounded, color: LightColor.ratingColor),
              onRatingUpdate: (double rating) =>
                  onChanged(rating <= 0 ? null : rating),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: isSelected ? LightColor.secondarySoft : LightColor.inputFillColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (isSelected) ...<Widget>[
                Icon(
                  Icons.check_rounded,
                  size: AppDimens.sizeX14,
                  color: LightColor.brandTextColor,
                ),
                const SizedBox(width: AppDimens.sizeX4),
              ],
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isSelected
                      ? LightColor.brandTextColor
                      : LightColor.secondaryTextColor,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourtTypeGrid extends StatelessWidget {
  const _CourtTypeGrid({
    required this.options,
    required this.selectedId,
    required this.onTap,
  });

  final List<PublicOptionModel> options;
  final int? selectedId;
  final ValueChanged<PublicOptionModel> onTap;

  static IconData _iconFor(String name) {
    final String n = name.toLowerCase();
    if (n.contains('indoor')) return Icons.meeting_room_rounded;
    if (n.contains('outdoor')) return Icons.wb_sunny_rounded;
    if (n.contains('artificial') || n.contains('turf')) {
      return Icons.grass_rounded;
    }
    if (n.contains('natural') || n.contains('grass')) return Icons.park_rounded;
    if (n.contains('hard')) return Icons.dashboard_rounded;
    return Icons.stadium_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = AppDimens.paddingX10;
        // Two on a phone, more when the pane allows, rather than a fixed two
        // that leaves very wide cards in a roomy column.
        final int columns = columnsFor(
          availableWidth: constraints.maxWidth,
          minItemWidth: AppDimens.courtTypeCardMinWidth,
          spacing: spacing,
          maxColumns: 4,
        ).clamp(2, 4);
        final double itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: options
              .map((PublicOptionModel option) {
                final bool isSelected = selectedId == option.idAsInt;
                return SizedBox(
                  width: itemWidth,
                  child: _CourtTypeCard(
                    label: option.name,
                    icon: _iconFor(option.name),
                    isSelected: isSelected,
                    onTap: () => onTap(option),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class _CourtTypeCard extends StatelessWidget {
  const _CourtTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? LightColor.secondarySoft : LightColor.inputFillColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.paddingX12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: AppDimens.sizeX16,
                color: isSelected
                    ? LightColor.brandTextColor
                    : LightColor.secondaryTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        color: isSelected
                            ? LightColor.brandTextColor
                            : LightColor.secondaryTextColor,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                ),
              ),
              if (isSelected) ...<Widget>[
                const SizedBox(width: AppDimens.paddingX6),
                Icon(
                  Icons.check_circle_rounded,
                  size: AppDimens.sizeX16,
                  color: LightColor.brandTextColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Selectable row with icon, title, time range and a trailing radio indicator.
class _TimeSlotRow extends StatelessWidget {
  const _TimeSlotRow({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _TimeSlotOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: isSelected ? LightColor.secondarySoft : LightColor.inputFillColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: Container(
          padding: const EdgeInsets.all(AppDimens.paddingX12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX38,
                height: AppDimens.sizeX38,
                decoration: BoxDecoration(
                  color: LightColor.cardColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(
                  option.icon,
                  size: AppDimens.sizeX18,
                  color: isSelected
                      ? LightColor.brandTextColor
                      : LightColor.secondaryTextColor,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      option.label,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      option.range,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _SelectIndicator(isSelected: isSelected),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectIndicator extends StatelessWidget {
  const _SelectIndicator({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.sizeX22,
      height: AppDimens.sizeX22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? LightColor.secondaryColor : Colors.transparent,
        border: Border.all(
          color: isSelected ? LightColor.secondaryColor : LightColor.iconGrey,
          width: 1.6,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              size: AppDimens.sizeX14,
              color: LightColor.inverseTextColor,
            )
          : null,
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.activeFilterCount,
    required this.onClearAll,
    required this.onApply,
  });

  final int activeFilterCount;
  final VoidCallback onClearAll;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      height: AppDimens.sizeX140,
      decoration: BoxDecoration(
        color: LightColor.elevatedCardColor,
        border: Border(top: BorderSide(color: LightColor.dividerColor)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowOf(0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.isDesktop
                  ? AppDimens.filterDesktopMaxWidth
                  : context.isTablet
                  ? AppDimens.filterColumnMaxWidth
                  : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.responsive<double>(
                  mobile: AppDimens.paddingX20,
                  tablet: AppDimens.paddingX32,
                ),
                vertical: AppDimens.paddingX12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    activeFilterCount == 0
                        ? 'Showing all courts'
                        : '$activeFilterCount filter${activeFilterCount == 1 ? '' : 's'} selected',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontSize: AppDimens.fontBodySubTitle,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX8),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final bool compact = constraints.maxWidth < 360;
                          final double gap = compact
                              ? AppDimens.paddingX8
                              : AppDimens.paddingX12;
                          final EdgeInsets buttonPadding = EdgeInsets.symmetric(
                            horizontal: compact
                                ? AppDimens.paddingX8
                                : AppDimens.paddingX12,
                          );
                          final Widget clearButton = SizedBox(
                            height: AppDimens.sizeX42,
                            child: OutlinedButton.icon(
                              onPressed: onClearAll,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(StringConstants.clearAll),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: LightColor.secondaryTextColor,
                                side: BorderSide(
                                  color: LightColor.dividerColor,
                                ),
                                padding: buttonPadding,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.radiusX8,
                                  ),
                                ),
                                textStyle: textTheme.bodyTextSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                          final Widget applyButton = SizedBox(
                            height: AppDimens.sizeX42,
                            child: CustomButton(
                              minHeight: AppDimens.sizeX42,
                              text: activeFilterCount == 0
                                  ? 'Show courts'
                                  : StringConstants.applyFilters,
                              onPressed: onApply,
                            ),
                          );

                          return Row(
                            children: <Widget>[
                              Expanded(child: clearButton),
                              SizedBox(width: gap),
                              Expanded(child: applyButton),
                            ],
                          );
                        },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
