import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_html_viewer.dart';

class CourtDescriptionSection extends StatefulWidget {
  const CourtDescriptionSection({
    super.key,
    required this.description,
    this.title = 'About this venue',
    this.subtitle = 'Overview and important details',
    this.icon = Icons.description_rounded,
    this.collapsedLines = 8,
  });

  final String description;
  final String title;
  final String subtitle;
  final IconData icon;

  final int collapsedLines;

  @override
  State<CourtDescriptionSection> createState() =>
      _CourtDescriptionSectionState();
}

class _CourtDescriptionSectionState extends State<CourtDescriptionSection> {
  final GlobalKey _contentKey = GlobalKey();
  bool _expanded = false;
  bool _exceedsCollapsedHeight = false;

  void _scheduleOverflowCheck(double collapsedMaxHeight) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final double contentHeight =
          _contentKey.currentContext?.size?.height ?? 0;
      final bool exceeds = contentHeight > collapsedMaxHeight + 1;
      if (exceeds != _exceedsCollapsedHeight) {
        setState(() => _exceedsCollapsedHeight = exceeds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String trimmed = widget.description.trim();
    if (trimmed.isEmpty) return const SizedBox.shrink();

    final textTheme = FutsalTheme.getTextTheme(context);
    final TextStyle? bodyStyle = textTheme.bodyTextMedium?.copyWith(
      color: LightColor.secondaryTextColor,
      fontWeight: FontWeight.w400,
      height: 1.75,
      letterSpacing: 0.1,
    );

    final double lineHeight =
        (bodyStyle?.fontSize ?? AppDimens.fontBodyTextMedium) *
        (bodyStyle?.height ?? 1.75);
    final double collapsedMaxHeight = lineHeight * widget.collapsedLines;

    _scheduleOverflowCheck(collapsedMaxHeight);

    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX12,
        left: AppDimens.paddingX16,
        right: AppDimens.paddingX16,
      ),
      child: Container(
        width: double.infinity,
        padding: AppUtils().getPadding(all: AppDimens.paddingX16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFF9FBFF)],
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          border: Border.all(
            color: LightColor.dividerColor.withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: AppDimens.sizeX18,
              offset: const Offset(0, AppDimens.sizeX8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: AppDimens.sizeX42,
                  height: AppDimens.sizeX42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        LightColor.blueLightColor,
                        LightColor.secondarySoft,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                  ),
                  child: Icon(
                    widget.icon,
                    color: LightColor.secondaryColor,
                    size: AppDimens.sizeX20,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: textTheme.bodyTextLarge!.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sizeX3),
                      Text(
                        widget.subtitle,
                        style: textTheme.bodyTextSmall!.copyWith(
                          color: LightColor.hintTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX12),
            Container(
              padding: AppUtils().getPadding(horizontal: AppDimens.paddingX6),
              child: _buildBody(trimmed, bodyStyle, collapsedMaxHeight),
            ),
            if (_exceedsCollapsedHeight) _buildToggle(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    String html,
    TextStyle? bodyStyle,
    double collapsedMaxHeight,
  ) {
    final Widget content = CustomHtmlReader(
      key: _contentKey,
      html: html,
      textStyle: bodyStyle,
    );

    if (_expanded) return content;

    // The scroll view lets the HTML lay out at its full height (so it can be
    // measured) while the constrained clip keeps only ~N lines visible.
    return ClipRect(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: collapsedMaxHeight),
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: content,
            ),
            if (_exceedsCollapsedHeight)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: AppDimens.sizeX40,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          const Color(0xFFF9FBFF),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX8,
        left: AppDimens.paddingX6,
      ),
      child: GestureDetector(
        onTap: () => setState(() => _expanded = !_expanded),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _expanded ? 'Read less' : 'Read more',
              style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppDimens.sizeX4),
            Icon(
              _expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: AppDimens.sizeX18,
              color: LightColor.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
