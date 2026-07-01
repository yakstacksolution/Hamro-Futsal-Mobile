import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_court_item_model.dart';

/// Compact, selectable court row: thumbnail, name + meta, price for the
/// selected date & slot, and a radio selection indicator.
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

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        margin: AppUtils().getMargin(bottom: AppDimens.marginX12),
        padding: AppUtils().getPadding(all: AppDimens.paddingX12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffF4FBF9)
              : isAvailable
              ? LightColor.cardColor
              : LightColor.inputFillColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          border: Border.all(
            color: isSelected
                ? LightColor.secondaryColor
                : LightColor.dividerColor.withValues(alpha: 0.6),
            width: isSelected ? 0.5 : 1,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: isSelected
                  ? LightColor.secondaryColor.withValues(alpha: 0.12)
                  : isAvailable
                  ? LightColor.shadowColor.withValues(alpha: 0.05)
                  : Colors.transparent,
              blurRadius: AppDimens.sizeX14,
              offset: const Offset(0, AppDimens.sizeX4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Opacity(
              opacity: isAvailable ? 1 : 0.55,
              child: CustomImageView(
                url: court.image,
                width: AppDimens.sizeX68,
                height: AppDimens.sizeX68,
                fit: BoxFit.cover,
                radius: BorderRadius.circular(AppDimens.radiusX10),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    court.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: isAvailable
                          ? LightColor.primaryTextColor
                          : LightColor.hintTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppDimens.sizeX4),
                  Wrap(
                    spacing: AppDimens.sizeX6,
                    runSpacing: AppDimens.sizeX4,
                    children: <Widget>[
                      _MetaChip(
                        icon: Icons.sports_soccer_rounded,
                        label: court.matchType,
                      ),
                      _MetaChip(
                        icon: Icons.groups_rounded,
                        label: '${court.maxPlayers} players',
                      ),
                      if (!isAvailable)
                        _MetaChip(
                          icon: _statusIcon(court.status),
                          label: court.status.label,
                          muted: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildRadio(isSelected: isSelected, isAvailable: isAvailable),
                const SizedBox(height: AppDimens.sizeX8),
                Text(
                  hasSlot
                      ? 'Rs ${totalPrice.toStringAsFixed(0)}'
                      : 'from Rs ${price.toStringAsFixed(0)}',
                  style: textTheme.bodyTextLarge?.copyWith(
                    color: isAvailable
                        ? LightColor.secondaryColor
                        : LightColor.hintTextColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  isRecurring && hasSlot
                      ? '${sessionDates.length} sessions'
                      : '/ hour',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildRadio({required bool isSelected, required bool isAvailable}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: AppDimens.sizeX22,
      height: AppDimens.sizeX22,
      decoration: BoxDecoration(
        color: isSelected ? LightColor.secondaryColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? LightColor.secondaryColor
              : LightColor.dividerColor,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(
              Icons.check_rounded,
              size: AppDimens.sizeX14,
              color: Colors.white,
            )
          : !isAvailable
          ? const Icon(
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
    this.muted = false,
  });

  final IconData icon;
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: muted
            ? LightColor.dividerColor.withValues(alpha: 0.55)
            : LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppDimens.sizeX12, color: LightColor.hintTextColor),
          const SizedBox(width: AppDimens.sizeX4),
          Text(
            label,
            style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
              color: muted
                  ? LightColor.hintTextColor
                  : LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
