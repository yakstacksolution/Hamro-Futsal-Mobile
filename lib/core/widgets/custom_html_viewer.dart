import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomHtmlViewer extends StatelessWidget {
  const CustomHtmlViewer({
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
    final theme = Theme.of(context);
    final normalized = html.trim();

    if (normalized.isEmpty) {
      return const SizedBox.shrink();
    }

    final baseTextStyle =
        textStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          height: 1.6,
          fontSize: 14,
          color: theme.colorScheme.onSurface,
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
            return {'margin': '0', 'padding': '0', 'font-family': 'system-ui'};

          case 'p':
            return {'margin': '0 0 12px 0', 'line-height': '1.7'};

          case 'h1':
            return {
              'margin': '0 0 16px 0',
              'font-size': '28px',
              'font-weight': '700',
              'line-height': '1.3',
            };

          case 'h2':
            return {
              'margin': '0 0 14px 0',
              'font-size': '24px',
              'font-weight': '700',
              'line-height': '1.35',
            };

          case 'h3':
            return {
              'margin': '0 0 12px 0',
              'font-size': '20px',
              'font-weight': '600',
              'line-height': '1.4',
            };

          case 'h4':
            return {
              'margin': '0 0 10px 0',
              'font-size': '18px',
              'font-weight': '600',
              'line-height': '1.4',
            };

          case 'h5':
          case 'h6':
            return {
              'margin': '0 0 8px 0',
              'font-size': '16px',
              'font-weight': '600',
              'line-height': '1.4',
            };

          case 'ul':
          case 'ol':
            return {'margin': '0 0 12px 0', 'padding-left': '20px'};

          case 'li':
            return {'margin': '0 0 8px 0', 'line-height': '1.6'};

          case 'blockquote':
            return {
              'margin': '8px 0 16px 0',
              'padding': '12px 16px',
              'border-left': '4px solid #D0D5DD',
              'background-color': '#F9FAFB',
            };

          case 'pre':
            return {
              'margin': '8px 0 16px 0',
              'padding': '14px',
              'background-color': '#111827',
              'color': '#F9FAFB',
              'border-radius': '10px',
              'white-space': 'pre-wrap',
            };

          case 'code':
            return {
              'font-family': 'monospace',
              'background-color': '#F3F4F6',
              'padding': '2px 4px',
              'border-radius': '6px',
            };

          case 'a':
            return {
              'color': '#1565C0',
              'text-decoration': 'none',
              'font-weight': '500',
            };

          case 'img':
            return {'margin': '8px 0 14px 0', 'border-radius': '12px'};

          case 'table':
            return {
              'margin': '10px 0 16px 0',
              'border-collapse': 'collapse',
              'width': '100%',
            };

          case 'th':
            return {
              'padding': '10px',
              'background-color': '#F3F4F6',
              'font-weight': '600',
              'text-align': 'left',
              'border': '1px solid #E5E7EB',
            };

          case 'td':
            return {'padding': '10px', 'border': '1px solid #E5E7EB'};

          case 'hr':
            return {
              'margin': '16px 0',
              'border': 'none',
              'border-top': '1px solid #E5E7EB',
            };

          default:
            return null;
        }
      },
      customWidgetBuilder: (element) {
        final tag = element.localName?.toLowerCase() ?? '';

        if (tag == 'hr') {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Divider(
              height: 1,
              thickness: 1,
              color: theme.dividerColor.withValues(alpha: 0.7),
            ),
          );
        }

        return null;
      },
    );

    if (!showContainer) return content;

    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: content,
    );
  }
}
