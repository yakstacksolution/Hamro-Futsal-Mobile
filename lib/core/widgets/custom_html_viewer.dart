import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomHtmlReader extends StatelessWidget {
  const CustomHtmlReader({
    super.key,
    required this.html,
    this.textStyle,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.showContainer = false,
  });

  final String html;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool showContainer;

  @override
  Widget build(BuildContext context) {
    final String normalized = html.trim();

    if (normalized.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = FutsalTheme.getTextTheme(context);
    final baseTextStyle =
        textStyle ??
        textTheme.bodyTextMedium?.copyWith(
          height: 1.6,
          color: LightColor.secondaryTextColor,
        );

    final content = HtmlWidget(
      normalized,
      textStyle: baseTextStyle,
      renderMode: RenderMode.column,
      onTapUrl: (url) async {
        final uri = Uri.tryParse(url);
        if (uri == null) return false;

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      },
      customStylesBuilder: (element) {
        final tag = element.localName?.toLowerCase() ?? '';

        switch (tag) {
          case 'body':
            return {'margin': '0', 'padding': '0'};

          case 'p':
            return {
              'margin': '0 0 ${AppDimens.marginX12}px 0',
              'line-height': '1.7',
            };

          case 'h1':
            return {
              'margin': '0 0 ${AppDimens.marginX16}px 0',
              'font-size': '${AppDimens.fontHeadingMedium}px',
              'font-weight': '700',
              'line-height': '1.3',
            };

          case 'h2':
            return {
              'margin': '0 0 ${AppDimens.marginX14}px 0',
              'font-size': '${AppDimens.fontHeadingXXSmall}px',
              'font-weight': '700',
              'line-height': '1.35',
            };

          case 'h3':
            return {
              'margin': '0 0 ${AppDimens.marginX12}px 0',
              'font-size': '${AppDimens.fontHeadingSmall}px',
              'font-weight': '600',
              'line-height': '1.4',
            };

          case 'h4':
            return {
              'margin': '0 0 ${AppDimens.marginX10}px 0',
              'font-size': '${AppDimens.fontHeadingSubTitle}px',
              'font-weight': '600',
              'line-height': '1.4',
            };

          case 'h5':
          case 'h6':
            return {
              'margin': '0 0 ${AppDimens.marginX8}px 0',
              'font-size': '${AppDimens.fontBodyTextLarge}px',
              'font-weight': '600',
              'line-height': '1.4',
            };

          case 'ul':
          case 'ol':
            return {
              'margin': '0 0 ${AppDimens.marginX12}px 0',
              'padding-left': '${AppDimens.paddingX20}px',
            };

          case 'li':
            return {
              'margin': '0 0 ${AppDimens.marginX8}px 0',
              'line-height': '1.6',
            };

          case 'blockquote':
            return {
              'margin': '${AppDimens.marginX8}px 0 ${AppDimens.marginX16}px 0',
              'padding': '${AppDimens.paddingX12}px ${AppDimens.paddingX16}px',
              'border-left':
                  '${AppDimens.sizeX4}px solid ${_colorHex(LightColor.dividerColor)}',
              'background-color': _colorHex(LightColor.inputFillColor),
            };

          case 'pre':
            return {
              'margin': '${AppDimens.marginX8}px 0 ${AppDimens.marginX16}px 0',
              'padding': '${AppDimens.paddingX14}px',
              'background-color': _colorHex(LightColor.primaryTextColor),
              'color': _colorHex(LightColor.inverseTextColor),
              'border-radius': '${AppDimens.radiusX10}px',
              'white-space': 'pre-wrap',
            };

          case 'code':
            return {
              'font-family': 'monospace',
              'background-color': _colorHex(LightColor.inputFillColor),
              'padding': '${AppDimens.paddingX2}px ${AppDimens.paddingX4}px',
              'border-radius': '${AppDimens.radiusX6}px',
            };

          case 'a':
            return {
              'color': _colorHex(LightColor.blueColor),
              'text-decoration': 'none',
              'font-weight': '500',
            };

          case 'img':
            return {
              'margin': '${AppDimens.marginX8}px 0 ${AppDimens.marginX14}px 0',
              'border-radius': '${AppDimens.radiusX12}px',
            };

          case 'table':
            return {
              'margin': '${AppDimens.marginX10}px 0 ${AppDimens.marginX16}px 0',
              'border-collapse': 'collapse',
              'width': '100%',
            };

          case 'th':
            return {
              'padding': '${AppDimens.paddingX10}px',
              'background-color': _colorHex(LightColor.inputFillColor),
              'font-weight': '600',
              'text-align': 'left',
              'border':
                  '${AppDimens.sizeX1}px solid ${_colorHex(LightColor.dividerColor)}',
            };

          case 'td':
            return {
              'padding': '${AppDimens.paddingX10}px',
              'border':
                  '${AppDimens.sizeX1}px solid ${_colorHex(LightColor.dividerColor)}',
            };

          case 'hr':
            return {
              'margin': '${AppDimens.marginX16}px 0',
              'border': 'none',
              'border-top':
                  '${AppDimens.sizeX1}px solid ${_colorHex(LightColor.dividerColor)}',
            };

          default:
            return null;
        }
      },
      customWidgetBuilder: (element) {
        final tag = element.localName?.toLowerCase() ?? '';

        if (tag == 'hr') {
          return Padding(
            padding: AppUtils().getPadding(vertical: AppDimens.paddingX16),
            child: Divider(
              height: AppDimens.sizeX1,
              thickness: AppDimens.sizeX1,
              color: LightColor.dividerColor.withValues(alpha: 0.7),
            ),
          );
        }

        return null;
      },
    );

    if (!showContainer) return content;

    return Container(
      width: double.infinity,
      padding: padding ?? AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: backgroundColor ?? LightColor.cardColor,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppDimens.radiusX16,
        ),
        border: Border.all(
          color: LightColor.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: content,
    );
  }

  String _colorHex(Color color) {
    final int value = color.toARGB32() & 0xFFFFFF;
    return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

class CustomHtmlViewer extends CustomHtmlReader {
  const CustomHtmlViewer({
    super.key,
    required super.html,
    super.textStyle,
    super.padding,
    super.backgroundColor,
    super.borderRadius,
    super.showContainer,
  });
}
