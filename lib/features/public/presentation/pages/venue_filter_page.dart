import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_court_options_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_court_options/public_court_options_bloc.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';

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
      label: 'Morning',
      range: '06:00 AM - 12:00 PM',
      icon: Icons.wb_sunny_rounded,
    ),
    _TimeSlotOption(
      key: '12:00-18:00',
      label: 'Afternoon',
      range: '12:00 PM - 06:00 PM',
      icon: Icons.wb_twilight_rounded,
    ),
    _TimeSlotOption(
      key: '18:00-00:00',
      label: 'Evening',
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
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.close_rounded,
            size: AppDimens.sizeX22,
            color: LightColor.primaryTextColor,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Filters & Sorting',
          style: textTheme.bodyTextMedium?.copyWith(
            fontSize: AppDimens.fontHeadingSmall,
            color: LightColor.primaryTextColor,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: _reset,
            child: Text(
              'Reset',
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryColor,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomBar(onClearAll: _reset, onApply: _apply),
      body: BlocBuilder<PublicCourtOptionsBloc, PublicCourtOptionsState>(
        builder: (BuildContext context, PublicCourtOptionsState optionsState) {
          final List<PublicOptionModel> matchTypeOptions = _selectableOptions(
            optionsState.matchFormats,
          );
          final List<PublicOptionModel> courtTypeOptions = _selectableOptions(
            optionsState.courtTypes,
          );

          return ListView(
            padding: AppUtils().getPadding(
              left: AppDimens.paddingX20,
              right: AppDimens.paddingX20,
              top: AppDimens.paddingX8,
              bottom: AppDimens.paddingX24,
            ),
            children: <Widget>[
              _SectionTitle(
                title: 'Price Range',
                trailing: Text(
                  '${_priceLabel(_priceRange.start)} - ${_priceLabel(_priceRange.end)}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: AppDimens.sizeX14),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: LightColor.secondaryColor,
                  inactiveTrackColor: LightColor.dividerColor,
                  thumbColor: LightColor.whiteColor,
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
              Padding(
                padding: AppUtils().getPadding(horizontal: AppDimens.sizeX4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _priceLabel(_priceMin),
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _priceLabel(_priceMax),
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontSize: AppDimens.fontBodySubTitle,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimens.paddingX20),
              const _SectionTitle(title: 'Match Type'),
              const SizedBox(height: AppDimens.paddingX14),
              _OptionStateView(
                status: optionsState.status,
                isEmpty: matchTypeOptions.isEmpty,
                emptyMessage: 'No match formats available.',
                errorMessage: optionsState.errorMessage,
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
              const SizedBox(height: AppDimens.paddingX20),

              const _SectionTitle(title: 'Court Type'),
              const SizedBox(height: AppDimens.paddingX14),
              _OptionStateView(
                status: optionsState.status,
                isEmpty: courtTypeOptions.isEmpty,
                emptyMessage: 'No court types available.',
                errorMessage: optionsState.errorMessage,
                child: _CourtTypeGrid(
                  options: courtTypeOptions,
                  selectedId: _courtTypeId,
                  onTap: _selectCourtType,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX20),

              Row(
                children: [
                  const _SectionTitle(title: 'Rating'),
                  Spacer(),
                  Text(
                    '( ${_minRating?.toStringAsFixed(1) ?? 'Any'} & up )',
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.secondaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.paddingX14),
              _RatingSelector(
                value: _minRating,
                onChanged: (double? value) =>
                    setState(() => _minRating = value),
              ),
              const SizedBox(height: AppDimens.paddingX20),

              const _SectionTitle(title: 'Time Slots'),
              const SizedBox(height: AppDimens.paddingX14),
              ..._timeSlotOptions.map((_TimeSlotOption slot) {
                return Padding(
                  padding: AppUtils().getPadding(bottom: AppDimens.paddingX12),
                  child: _TimeSlotRow(
                    option: slot,
                    isSelected: _timeSlots.contains(slot.key),
                    onTap: () => _toggle(_timeSlots, slot.key),
                  ),
                );
              }),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _OptionStateView extends StatelessWidget {
  const _OptionStateView({
    required this.status,
    required this.isEmpty,
    required this.emptyMessage,
    required this.child,
    this.errorMessage,
  });

  final PublicCourtOptionsStatus status;
  final bool isEmpty;
  final String emptyMessage;
  final String? errorMessage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    if (status == PublicCourtOptionsStatus.loading ||
        status == PublicCourtOptionsStatus.idle) {
      return Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: AppDimens.sizeX18,
          height: AppDimens.sizeX18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: LightColor.secondaryColor,
          ),
        ),
      );
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
                  const Icon(Icons.star_rounded, color: LightColor.ratingColor),
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
    return Material(
      color: isSelected ? LightColor.secondaryColor : LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
        child: Container(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX16,
            vertical: AppDimens.paddingX10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX6),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: isSelected
                  ? LightColor.whiteColor
                  : LightColor.secondaryTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
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
        final double itemWidth = (constraints.maxWidth - spacing) / 2;
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
      color: isSelected ? LightColor.secondaryColor : LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Container(
          padding: AppUtils().getPadding(all: AppDimens.paddingX14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                icon,
                size: AppDimens.sizeX16,
                color: isSelected
                    ? LightColor.whiteColor
                    : LightColor.secondaryColor,
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
                            ? LightColor.whiteColor
                            : LightColor.secondaryTextColor,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
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
      color: isSelected
          ? LightColor.secondaryColor.withValues(alpha: 0.08)
          : LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Container(
          padding: AppUtils().getPadding(all: AppDimens.paddingX14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
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
                  color: isSelected
                      ? LightColor.secondaryColor.withValues(alpha: 0.15)
                      : LightColor.background,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(
                  option.icon,
                  size: AppDimens.sizeX18,
                  color: LightColor.secondaryColor,
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
          ? const Icon(
              Icons.check_rounded,
              size: AppDimens.sizeX14,
              color: LightColor.whiteColor,
            )
          : null,
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onClearAll, required this.onApply});

  final VoidCallback onClearAll;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      decoration: const BoxDecoration(
        color: LightColor.whiteColor,
        border: Border(top: BorderSide(color: LightColor.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX20,
            vertical: AppDimens.paddingX12,
          ),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: onClearAll,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                child: Padding(
                  padding: AppUtils().getPadding(
                    horizontal: AppDimens.paddingX10,
                    vertical: AppDimens.paddingX8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(
                        Icons.refresh_rounded,
                        size: AppDimens.sizeX18,
                        color: LightColor.secondaryTextColor,
                      ),
                      const SizedBox(width: AppDimens.sizeX6),
                      Text(
                        'Clear All',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX32),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: AppDimens.sizeX50,
                  child: CustomButton(
                    minHeight: 42,
                    text: 'Apply Filters',
                    onPressed: onApply,
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
