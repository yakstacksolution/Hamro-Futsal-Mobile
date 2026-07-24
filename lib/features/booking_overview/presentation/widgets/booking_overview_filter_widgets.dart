import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Compact selectable chip with haptic feedback, shared by all filter rows.
class BookingChip extends StatelessWidget {
  const BookingChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 12,
                  color: selected
                      ? LightColor.whiteColor
                      : LightColor.secondaryTextColor,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: selected
                      ? LightColor.whiteColor
                      : LightColor.secondaryTextColor,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookingPeriodChips extends StatelessWidget {
  const BookingPeriodChips({
    super.key,
    required this.period,
    required this.customRange,
    required this.onPeriod,
    required this.onEditCustom,
  });

  final BookingPeriod period;
  final DateTimeRange? customRange;
  final ValueChanged<BookingPeriod> onPeriod;
  final VoidCallback onEditCustom;

  @override
  Widget build(BuildContext context) {
    // Single horizontally scrollable row, same pattern as the expenses screen.
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: BookingPeriod.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          final p = BookingPeriod.values[i];
          return BookingChip(
            label: p == BookingPeriod.custom && customRange != null
                ? '${customRange!.duration.inDays + 1}d'
                : p.label,
            selected: period == p,
            icon: p == BookingPeriod.custom ? Icons.date_range_outlined : null,
            onTap: () {
              if (p == BookingPeriod.custom && period == BookingPeriod.custom) {
                onEditCustom();
              } else {
                onPeriod(p);
              }
            },
          );
        },
      ),
    );
  }
}

class BookingVenueFilter extends StatelessWidget {
  const BookingVenueFilter({
    super.key,
    required this.venues,
    required this.selectedId,
    required this.onChange,
  });

  final List<OverviewVenue> venues;
  final String? selectedId;
  final ValueChanged<String?> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: venues.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return BookingChip(
              label: StringConstants.allVenues,
              selected: selectedId == null,
              onTap: () => onChange(null),
            );
          }
          final v = venues[i - 1];
          return BookingChip(
            label: v.name,
            selected: selectedId == v.id,
            onTap: () => onChange(v.id),
          );
        },
      ),
    );
  }
}
