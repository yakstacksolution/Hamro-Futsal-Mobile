import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';

class OpponentCountdownPill extends StatelessWidget {
  const OpponentCountdownPill({
    super.key,
    required this.value,
    required this.urgent,
    this.label = StringConstants.acceptWithin,
  });

  final String value;
  final bool urgent;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color fg = urgent ? LightColor.redColor : LightColor.secondaryColor;
    final Color bg = urgent
        ? LightColor.redLightColor
        : LightColor.secondaryColor.withValues(alpha: 0.10);
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX10,
        vertical: AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      ),
      child: Row(
        children: [
          Icon(
            urgent ? Icons.timer_rounded : Icons.timer_outlined,
            size: 14,
            color: fg,
          ),
          const SizedBox(width: AppDimens.paddingX6),
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w500,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: textTheme.bodyTextMedium?.copyWith(
              color: fg,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class OpponentCard extends StatelessWidget {
  const OpponentCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.paddingX14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class OpponentGuidanceCard extends StatelessWidget {
  const OpponentGuidanceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(
          color: LightColor.secondaryColor.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: AppDimens.sizeX36,
            height: AppDimens.sizeX36,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX20,
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
                const SizedBox(height: AppDimens.paddingX4),
                Text(
                  message,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OpponentSectionLabel extends StatelessWidget {
  const OpponentSectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX2,
        bottom: AppDimens.paddingX8,
      ),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }
}

class OpponentFieldLabel extends StatelessWidget {
  const OpponentFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(bottom: AppDimens.paddingX8),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}

class OpponentPillChip extends StatelessWidget {
  const OpponentPillChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
    this.padding,
  });

  final String label;
  final bool active, compact;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: compact ? AppDimens.sizeX36 : AppDimens.sizeX40,
          padding: padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? LightColor.secondaryColor : LightColor.background,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: active
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: active
                  ? LightColor.inverseTextColor
                  : LightColor.secondaryTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

class OpponentCountChip extends StatelessWidget {
  const OpponentCountChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final int count;
  final bool isSelected;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color fg = isSelected
        ? (filled ? LightColor.inverseTextColor : LightColor.secondaryColor)
        : LightColor.secondaryTextColor;
    final Color bg = !isSelected
        ? Colors.transparent
        : filled
        ? LightColor.secondaryColor
        : LightColor.secondaryColor.withValues(alpha: 0.10);
    final Color border = isSelected
        ? (filled
              ? LightColor.secondaryColor
              : LightColor.secondaryColor.withValues(alpha: 0.35))
        : LightColor.dividerColor;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: fg,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: AppDimens.paddingX6),
                // Mirrors the count badges in the segmented tab bar above.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingX6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (filled
                              ? LightColor.inverseTextColor.withValues(
                                  alpha: 0.22,
                                )
                              : LightColor.secondaryColor.withValues(
                                  alpha: 0.14,
                                ))
                        : LightColor.dividerColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                  ),
                  child: Text(
                    count.toString(),
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimens.fontBodySubTitle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class OpponentPickerRow extends StatelessWidget {
  const OpponentPickerRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX14,
          symmetricVertical: AppDimens.paddingX14,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: LightColor.secondaryTextColor),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingX8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: LightColor.hintTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class OpponentRowDivider extends StatelessWidget {
  const OpponentRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
      child: Divider(height: 1, color: LightColor.dividerColor),
    );
  }
}

class OpponentStatusBadge extends StatelessWidget {
  const OpponentStatusBadge({super.key, required this.status, this.label});
  final RequestStatus status;

  final String? label;

  @override
  Widget build(BuildContext context) {
    // A request I sent stays "Pending" until the opponent replies; a timed
    // out request reads as "Closed".
    final (Color fg, Color bg, String copy) = switch (status) {
      RequestStatus.accepted => (
        LightColor.successColor,
        LightColor.secondaryColor.withValues(alpha: 0.10),
        status.label,
      ),
      RequestStatus.rejected => (
        LightColor.redColor,
        LightColor.redLightColor,
        status.label,
      ),
      RequestStatus.pending || RequestStatus.sent => (
        LightColor.warningColor,
        LightColor.warningLightColor,
        'Pending',
      ),
      RequestStatus.fresh => (
        LightColor.secondaryColor,
        LightColor.secondaryColor.withValues(alpha: 0.10),
        status.label,
      ),
      RequestStatus.invitationSent => (
        LightColor.secondaryColor,
        LightColor.secondaryColor.withValues(alpha: 0.10),
        status.label,
      ),
      // Submitted and waiting on the admin review — same warning tone as a
      // request waiting on an opponent, since both are "nothing to do yet".
      RequestStatus.pendingApproval => (
        LightColor.warningColor,
        LightColor.warningLightColor,
        status.label,
      ),
      // A draft is mine and unpublished — neutral, not an alarm.
      RequestStatus.draft => (
        LightColor.secondaryTextColor,
        LightColor.dividerColor.withValues(alpha: 0.55),
        status.label,
      ),
      RequestStatus.expired || RequestStatus.cancelled => (
        LightColor.hintTextColor,
        LightColor.dividerColor,
        'Closed',
      ),
    };
    // The server's word wins when the row carried one; the tone above still
    // comes from the lifecycle status.
    final String text = (label?.trim().isNotEmpty ?? false)
        ? label!.trim()
        : copy;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

abstract final class OpponentLayout {
  static const double _minCardWidth = 440;
  static const double gap = 16;
  static const double requestCardMinWidth = 340;

  static double maxContentWidth(BuildContext context) => context.isDesktop
      ? 1200
      : context.isTablet
      ? 760
      : double.infinity;

  static int gridColumns(
    BuildContext context,
    double width, {
    double minCardWidth = _minCardWidth,
  }) {
    if (!context.isTabletOrWider) return 1;
    return columnsFor(
      availableWidth: width,
      minItemWidth: minCardWidth,
      spacing: gap,
      maxColumns: 3,
    );
  }
}

class OpponentGridRow extends StatelessWidget {
  const OpponentGridRow({
    super.key,
    required this.children,
    required this.columns,
    this.equalHeight = false,
  });

  final List<Widget> children;
  final int columns;
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    final Widget row = Row(
      crossAxisAlignment: equalHeight
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < columns; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: OpponentLayout.gap),
          Expanded(
            child: i < children.length ? children[i] : const SizedBox.shrink(),
          ),
        ],
      ],
    );
    return equalHeight ? IntrinsicHeight(child: row) : row;
  }
}
