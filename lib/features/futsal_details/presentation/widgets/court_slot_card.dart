import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_court_item_model.dart';

/// Compact selectable court row: thumbnail, name + meta chips, and the price
/// for the selected date & slot with a selection indicator.
///
/// Everything sits on a single row and every flexible part is constrained, so
/// the card keeps its height at the narrow two-column tile width as well.
class CourtSlotCard extends StatelessWidget {
  const CourtSlotCard({
    super.key,
    required this.court,
    required this.selectedDate,
    this.selectedTime,
    this.slotLabel,
    this.recurringDates,
    this.selected = false,
    this.onTap,
  });

  final VenueCourtItemModel court;
  final DateTime selectedDate;

  /// Selected slot time (e.g. '7:00 AM'), null when none selected.
  final String? selectedTime;

  /// Preformatted label for the selected date & slot.
  final String? slotLabel;

  /// When set (recurring booking), all weekly session dates. The card then
  /// shows the combined total instead of a single-session price.
  final List<DateTime>? recurringDates;

  /// Whether this court is the currently selected one.
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isAvailable = court.isAvailable;
    final bool isSelected = selected && isAvailable;
    final bool hasSlot = selectedTime != null;
    final List<DateTime> sessionDates = recurringDates ?? <DateTime>[];
    final bool isRecurring = sessionDates.length > 1;
    final double price = court.priceFor(selectedDate, selectedTime);
    final double totalPrice = isRecurring && hasSlot
        ? sessionDates.fold<double>(
            0,
            (double sum, DateTime d) => sum + court.priceFor(d, selectedTime),
          )
        : price;
    final Color accent = LightColor.secondaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      margin: AppUtils().getMargin(bottom: AppDimens.marginX10),
      decoration: BoxDecoration(
        // White in light theme (elevated surface), dark-safe in dark. Kept the
        // same in every state — selection and availability read through the
        // border, indicator and chips instead of a background tint.
        color: LightColor.elevatedCardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: isSelected
              ? accent
              : LightColor.dividerColor.withValues(alpha: 0.6),
          width: isSelected ? 1.2 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: isSelected
                ? accent.withValues(alpha: 0.14)
                : isAvailable
                ? LightColor.shadowColor.withValues(alpha: 0.05)
                : Colors.transparent,
            blurRadius: AppDimens.sizeX12,
            offset: const Offset(0, AppDimens.sizeX2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12 - 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAvailable ? onTap : null,
            splashColor: accent.withValues(alpha: 0.08),
            highlightColor: accent.withValues(alpha: 0.04),
            child: Padding(
              padding: AppUtils().getPadding(all: AppDimens.paddingX10),
              child: Row(
                children: <Widget>[
                  _buildThumbnail(isAvailable: isAvailable),
                  const SizedBox(width: AppDimens.sizeX10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          court.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextMedium?.copyWith(
                            color: isAvailable
                                ? LightColor.primaryTextColor
                                : LightColor.hintTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sizeX4),
                        // One line of meta only — the card must stay short.
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: _MetaChip(
                                icon: Icons.sports_soccer_rounded,
                                label: court.matchType,
                                enabled: isAvailable,
                              ),
                            ),
                            const SizedBox(width: AppDimens.sizeX6),
                            Flexible(
                              child: _MetaChip(
                                icon: Icons.groups_rounded,
                                label: '${court.maxPlayers}',
                                enabled: isAvailable,
                              ),
                            ),
                            if (!isAvailable) ...<Widget>[
                              const SizedBox(width: AppDimens.sizeX6),
                              Flexible(
                                child: _MetaChip(
                                  icon: _statusIcon(court.status),
                                  label: court.status.label,
                                  enabled: false,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        hasSlot
                            ? 'Rs ${totalPrice.toStringAsFixed(0)}'
                            : 'from Rs ${price.toStringAsFixed(0)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextMedium?.copyWith(
                          color: isAvailable
                              ? LightColor.primaryTextColor
                              : LightColor.hintTextColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sizeX2),
                      Text(
                        isRecurring && hasSlot
                            ? '${sessionDates.length} sessions'
                            : '/ hour',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMiniSubTitle?.copyWith(
                          color: LightColor.hintTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: AppDimens.sizeX8),
                  _SelectIndicator(
                    isSelected: isSelected,
                    isAvailable: isAvailable,
                    accent: accent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail({required bool isAvailable}) {
    final Widget image = CustomImageView(
      url: court.image,
      width: AppDimens.sizeX52,
      height: AppDimens.sizeX52,
      fit: BoxFit.cover,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: SizedBox(
        width: AppDimens.sizeX52,
        height: AppDimens.sizeX52,
        child: isAvailable
            ? image
            // Desaturate a taken court so the eye skips it.
            : ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.2126, 0.7152, 0.0722, 0, 0, //
                  0.2126, 0.7152, 0.0722, 0, 0, //
                  0.2126, 0.7152, 0.0722, 0, 0, //
                  0, 0, 0, 1, 0,
                ]),
                child: image,
              ),
      ),
    );
  }

  IconData _statusIcon(SlotStatus status) {
    return switch (status) {
      SlotStatus.booked => Icons.event_busy_rounded,
      SlotStatus.closed => Icons.lock_clock_rounded,
      SlotStatus.unavailable => Icons.block_rounded,
      SlotStatus.available => Icons.check_circle_rounded,
    };
  }
}

/// Round check/blocked indicator on the trailing edge of the card.
class _SelectIndicator extends StatelessWidget {
  const _SelectIndicator({
    required this.isSelected,
    required this.isAvailable,
    required this.accent,
  });

  final bool isSelected;
  final bool isAvailable;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: AppDimens.sizeX22,
      height: AppDimens.sizeX22,
      decoration: BoxDecoration(
        color: isSelected ? accent : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? accent
              : isAvailable
              ? LightColor.dividerColor
              : LightColor.dividerColor.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Icon(
              Icons.check_rounded,
              size: AppDimens.sizeX14,
              color: LightColor.inverseTextColor,
            )
          : !isAvailable
          ? Icon(
              Icons.close_rounded,
              size: AppDimens.sizeX14,
              color: LightColor.hintTextColor,
            )
          : null,
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color foreground = enabled
        ? LightColor.secondaryTextColor
        : LightColor.hintTextColor;

    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX6,
        vertical: AppDimens.paddingX2,
      ),
      decoration: BoxDecoration(
        color: enabled
            ? LightColor.inputFillColor
            : LightColor.dividerColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimens.radiusX50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppDimens.sizeX12, color: foreground),
          const SizedBox(width: AppDimens.sizeX4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
