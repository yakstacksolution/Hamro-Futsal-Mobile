import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_court_item_model.dart';

/// Card for a single court in the slot selection page list: image, name,
/// court info chips, price for the selected date & slot, and an
/// expandable price list.
class CourtSlotCard extends StatefulWidget {
  const CourtSlotCard({
    super.key,
    required this.court,
    required this.selectedDate,
    this.selectedTime,
    this.slotLabel,
    this.onTap,
  });

  final VenueCourtItemModel court;
  final DateTime selectedDate;

  /// Selected slot time (e.g. '7:00 AM'), null when none selected.
  final String? selectedTime;

  /// Preformatted label for the selected date & slot.
  final String? slotLabel;
  final VoidCallback? onTap;

  @override
  State<CourtSlotCard> createState() => _CourtSlotCardState();
}

class _CourtSlotCardState extends State<CourtSlotCard> {
  bool _priceListExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final VenueCourtItemModel court = widget.court;
    final bool hasSlot = widget.selectedTime != null;
    final double price = court.priceFor(
      widget.selectedDate,
      widget.selectedTime,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: AppUtils().getMargin(bottom: AppDimens.marginX12),
        padding: AppUtils().getPadding(all: AppDimens.paddingX12),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.05),
              blurRadius: AppDimens.sizeX14,
              offset: const Offset(0, AppDimens.sizeX4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomImageView(
                  url: court.image,
                  width: AppDimens.sizeX80,
                  height: AppDimens.sizeX80,
                  fit: BoxFit.cover,
                  radius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              court.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextLarge?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sizeX8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                hasSlot
                                    ? 'Rs ${price.toStringAsFixed(0)}'
                                    : 'from Rs ${price.toStringAsFixed(0)}',
                                style: textTheme.bodyTextLarge?.copyWith(
                                  color: LightColor.secondaryColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                '/ hour',
                                style: textTheme.bodyMiniSubTitle?.copyWith(
                                  color: LightColor.hintTextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.sizeX8),
                      Wrap(
                        spacing: AppDimens.sizeX6,
                        runSpacing: AppDimens.sizeX6,
                        children: <Widget>[
                          _InfoChip(
                            icon: Icons.stadium_outlined,
                            label: court.courtType,
                          ),
                          _InfoChip(
                            icon: Icons.sports_soccer_rounded,
                            label: court.matchType,
                          ),
                          _InfoChip(
                            icon: Icons.groups_rounded,
                            label: '${court.maxPlayers} players',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX10),
            Container(
              width: double.infinity,
              padding: AppUtils().getPadding(
                horizontal: AppDimens.paddingX10,
                vertical: AppDimens.paddingX6,
              ),
              decoration: BoxDecoration(
                color: hasSlot
                    ? LightColor.secondarySoft
                    : LightColor.inputFillColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    hasSlot
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                    size: AppDimens.sizeX14,
                    color: hasSlot
                        ? LightColor.secondaryColor
                        : LightColor.hintTextColor,
                  ),
                  const SizedBox(width: AppDimens.sizeX6),
                  Expanded(
                    child: Text(
                      widget.slotLabel ?? 'Select a slot to see exact price',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: hasSlot
                            ? LightColor.secondaryColor
                            : LightColor.hintTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildPriceListSection(textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceListSection(FutsalTextTheme textTheme) {
    final VenueCourtItemModel court = widget.court;
    final CourtPriceRule? activeRule = court.ruleForTime(widget.selectedTime);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _priceListExpanded = !_priceListExpanded);
          },
          child: Padding(
            padding: AppUtils().getPadding(
              top: AppDimens.paddingX8,
              bottom: AppDimens.paddingX2,
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Price list',
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX4),
                AnimatedRotation(
                  turns: _priceListExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more_rounded,
                    size: AppDimens.sizeX18,
                    color: LightColor.hintTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: _priceListExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: AppUtils().getPadding(top: AppDimens.paddingX6),
            child: Column(
              children: <Widget>[
                ...court.priceList.map(
                  (CourtPriceRule rule) =>
                      _buildPriceRow(textTheme, rule, rule == activeRule),
                ),
                if (court.weekendSurcharge > 0)
                  Padding(
                    padding: AppUtils().getPadding(top: AppDimens.paddingX6),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.info_outline_rounded,
                          size: AppDimens.sizeX12,
                          color: LightColor.hintTextColor,
                        ),
                        const SizedBox(width: AppDimens.sizeX4),
                        Text(
                          '+ Rs ${court.weekendSurcharge.toStringAsFixed(0)} on Saturdays',
                          style: textTheme.bodyMiniSubTitle?.copyWith(
                            color: LightColor.hintTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    FutsalTextTheme textTheme,
    CourtPriceRule rule,
    bool active,
  ) {
    return Container(
      margin: AppUtils().getMargin(bottom: AppDimens.marginX4),
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: active ? LightColor.secondarySoft : LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              '${rule.label} · ${rule.timeRange}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySubTitle?.copyWith(
                color: active
                    ? LightColor.secondaryColor
                    : LightColor.primaryTextColor,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            'Rs ${rule.price.toStringAsFixed(0)}',
            style: textTheme.bodySubTitle?.copyWith(
              color: active
                  ? LightColor.secondaryColor
                  : LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
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
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
