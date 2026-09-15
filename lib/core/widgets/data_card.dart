import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

/// The shared card language for record lists — the ledger on Finance &
/// payouts, the booking lists, and anything else that shows one record per
/// card.
///
/// The parts live here rather than in each feature so the screens cannot drift
/// apart: a card is a hairline-bordered panel with no shadow; its header is a
/// tinted glyph, a strong title, a quiet identifying line and a right-hand
/// figure with a status chip under it; its body is `label  value` rows whose
/// labels share a fixed column so the values align.
///
/// Everything elides rather than overflowing, and a missing value drops its
/// row instead of leaving a blank one.

/// Width of the label column in [DataCardField]. Fixed so the values of every
/// row in a card — and of every card in a list — start at the same x.
const double kDataCardLabelWidth = 92;

/// Title size for a card in a list — a point under the detail scale, so the
/// name and the figure lead the card without heading it.
const double kDataCardListTitleSize = 13;

/// How large a card's text runs.
///
/// A list is scanned, so it is set tight; a details page is read, and the same
/// facts there carry a step more size. Both use the same type, weights and
/// colours — only the scale differs — so a card still opens into a page that
/// looks like itself.
enum DataCardDensity {
  /// Lists: 10pt labels and values, 12pt titles.
  list,

  /// Details pages: 12pt labels and values, 14pt titles.
  detail;

  bool get isDetail => this == DataCardDensity.detail;

  /// Labels, captions and the quiet second line.
  double get labelSize => isDetail
      ? AppDimens.fontBodyTextSmall
      : AppDimens.fontBodySubTitle;

  /// Values and figures.
  double get valueSize => isDetail
      ? AppDimens.fontBodyTextSmall
      : AppDimens.fontBodySubTitle;

  /// A card's title and its amount.
  double get titleSize => isDetail
      ? AppDimens.fontBodyTextMedium
      : AppDimens.fontBodyTextSmall;
}

/// A bordered panel holding one record.
///
/// [selected] marks a card the reader has acted on — a product in the cart,
/// say. It tints the panel and accents its border with [accent] rather than
/// changing its shape, so a selected card still sits in the same grid as the
/// rest.
class DataCard extends StatelessWidget {
  const DataCard({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.accent,
    this.animate = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final Color? accent;

  /// Eases between the plain and selected looks. Off by default: a list of
  /// static records has nothing to animate.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusX14);
    final Color tint = accent ?? LightColor.secondaryColor;
    final BoxDecoration decoration = BoxDecoration(
      color: selected
          ? tint.withValues(alpha: 0.06)
          : LightColor.whiteColor,
      borderRadius: radius,
      border: Border.all(
        color: selected
            ? tint.withValues(alpha: 0.45)
            : LightColor.dividerColor,
      ),
    );
    final Widget panel = animate
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            decoration: decoration,
            child: child,
          )
        : Container(
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            decoration: decoration,
            child: child,
          );
    if (onTap == null) return panel;
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(borderRadius: radius, onTap: onTap, child: panel),
    );
  }
}

/// The tinted square glyph that opens a card's header.
class DataCardIcon extends StatelessWidget {
  const DataCardIcon({super.key, required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Icon(icon, size: 17, color: color),
    );
  }
}

/// A small state chip — `CREDIT`, `CONFIRMED`, `PENDING`.
///
/// Always carries its meaning in words: the colour is a reinforcement, never
/// the only cue, so the card survives a greyscale screenshot or a colour-blind
/// reader.
class DataCardChip extends StatelessWidget {
  const DataCardChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      ),
      child: Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: color,
          fontSize: AppDimens.fontBodySubTitle - 1,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          height: 1.2,
        ),
      ),
    );
  }
}

/// A count beside a label — the products already on a booking, say.
///
/// A true circle, not a pill: a badge that only sets a minimum width and lets
/// its height fall out of the text comes out visibly wider than it is tall on
/// a single digit. This is a fixed square with the digits centred in it, and
/// it stretches into a rounded pill only once the count needs three
/// characters, where a circle would clip them.
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    required this.background,
    required this.foreground,
    this.size = AppDimens.sizeX18,
  });

  final String count;
  final Color background;
  final Color foreground;

  /// Diameter of the dot. The default fits two digits at the badge's text
  /// size.
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool circular = count.length <= 2;
    return Container(
      width: circular ? size : null,
      height: size,
      constraints: circular ? null : BoxConstraints(minWidth: size),
      padding: circular
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: AppDimens.paddingX6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        // A circle cannot carry a border radius, so the pill case switches
        // shape rather than rounding a square.
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(size / 2),
      ),
      child: Text(
        count,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
          fontSize: AppDimens.fontBodySubTitle,
          // Without this the glyphs sit on the text's own leading and ride
          // high in the dot instead of centring in it.
          height: 1,
        ),
      ),
    );
  }
}

/// A card header: glyph, title, quiet identifying line, and an optional
/// right-hand column holding a figure and a chip.
///
/// The right column is capped at a share of the card so a long title shortens
/// itself rather than crowding the figure off the edge.
class DataCardHeader extends StatelessWidget {
  const DataCardHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.amount,
    this.amountColor,
    this.chipLabel,
    this.chipColor,
    this.titleMaxLines = 2,
    this.density = DataCardDensity.list,
    this.titleSize,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  /// The identifying line under the title — a reference, a court, a phone.
  final String? subtitle;

  /// Pre-formatted figure, shown in tabular digits so a list of cards forms a
  /// readable column.
  final String? amount;
  final Color? amountColor;
  final String? chipLabel;
  final Color? chipColor;
  final int titleMaxLines;
  final DataCardDensity density;

  /// Size for the title and the figure alone, overriding [density]. A list
  /// card sets it just under the detail scale so the name and the amount lead
  /// the card without heading it. See [kDataCardListTitleSize].
  final double? titleSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool hasTrailing = amount != null || chipLabel != null;
    final double titleScale = titleSize ?? density.titleSize;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double trailingWidth = (constraints.maxWidth * 0.42).clamp(
          96.0,
          200.0,
        );
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DataCardIcon(icon: icon, color: iconColor),
            const SizedBox(width: AppDimens.paddingX10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    maxLines: titleMaxLines,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontSize: titleScale,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontSize: density.labelSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hasTrailing) ...<Widget>[
              const SizedBox(width: AppDimens.paddingX10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: trailingWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    if (amount != null)
                      Text(
                        amount!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: amountColor ?? LightColor.primaryTextColor,
                          fontSize: titleScale,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                          // Digits of equal width, so figures line up down the
                          // list instead of jittering.
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    if (chipLabel != null) ...<Widget>[
                      if (amount != null) const SizedBox(height: 4),
                      DataCardChip(
                        label: chipLabel!,
                        color: chipColor ?? LightColor.secondaryTextColor,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

/// The hairline between a card's header and its fields.
class DataCardDivider extends StatelessWidget {
  const DataCardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX10),
      child: Divider(
        height: 1,
        thickness: 1,
        color: LightColor.dividerColor,
      ),
    );
  }
}

/// One `label  value` line in a card's body.
class DataCardField extends StatelessWidget {
  const DataCardField({
    super.key,
    required this.label,
    required this.value,
    this.maxLines = 1,
    this.valueColor,
    this.density = DataCardDensity.list,
  });

  final String label;
  final String value;
  final int maxLines;
  final Color? valueColor;
  final DataCardDensity density;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: kDataCardLabelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontSize: density.labelSize,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: valueColor ?? LightColor.secondaryTextColor,
              fontSize: density.valueSize,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// One cell of a [DataCardGrid]: a quiet label with its value beneath.
///
/// Stacked rather than side by side because a cell is only half the card wide
/// — a label column inside it would leave the value almost no room.
class DataCardCell extends StatelessWidget {
  const DataCardCell({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.maxLines = 2,
    this.density = DataCardDensity.list,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final int maxLines;
  final DataCardDensity density;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.hintTextColor,
            fontSize: density.labelSize - 1,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyTextSmall?.copyWith(
            color: valueColor ?? LightColor.primaryTextColor,
            fontSize: density.valueSize,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

/// A card's facts as a two-column grid — four cells make the usual 2×2.
///
/// Cells flow in pairs, so a card with an odd number keeps its last cell at
/// the left edge of its own row rather than stretching it across the card, and
/// a card with more than four simply grows by another row. Both columns take
/// exactly half the width, so the right column starts at the same x on every
/// card in a list.
class DataCardGrid extends StatelessWidget {
  const DataCardGrid({super.key, required this.cells});

  final List<Widget> cells;

  @override
  Widget build(BuildContext context) {
    if (cells.isEmpty) return const SizedBox.shrink();
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 2) {
      final Widget left = cells[i];
      final Widget? right = i + 1 < cells.length ? cells[i + 1] : null;
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: AppDimens.paddingX10));
      }
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: left),
            const SizedBox(width: AppDimens.paddingX12),
            // An empty half keeps the grid's columns where they are instead of
            // letting a lone cell spread across the card.
            Expanded(child: right ?? const SizedBox.shrink()),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}

/// Lays out a card's field rows with the spacing they share.
class DataCardFields extends StatelessWidget {
  const DataCardFields({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < children.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 5),
          children[i],
        ],
      ],
    );
  }
}
