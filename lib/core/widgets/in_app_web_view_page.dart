import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({
    super.key,
    required this.title,
    required this.url,
    this.mobileVariant = true,
  });

  final String title;
  final String url;

  /// Ask the site for its embedded (`type=mobile`) rendering.
  ///
  /// The pages opened in here — terms, privacy — serve a chrome-free variant
  /// for that flag, which is what belongs inside the app; the full page brings
  /// the marketing header, nav and footer with it. Turn it off for a URL that
  /// does not understand the flag.
  final bool mobileVariant;

  /// [url] with `type=mobile` added, leaving any query it already carries
  /// (and an explicit `type` of its own) intact.
  static Uri resolveUrl(String url, {bool mobileVariant = true}) {
    final Uri uri = Uri.parse(url);
    if (!mobileVariant || uri.queryParameters.containsKey('type')) return uri;
    return uri.replace(
      queryParameters: <String, String>{
        ...uri.queryParameters,
        'type': 'mobile',
      },
    );
  }

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(LightColor.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _errorMessage = null);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _progress = 100);
          },
          onWebResourceError: (WebResourceError error) {
            if (!mounted || error.isForMainFrame == false) return;
            setState(() {
              _errorMessage = error.description.trim().isEmpty
                  ? 'Could not load this page.'
                  : error.description.trim();
            });
          },
        ),
      )
      ..loadRequest(
        InAppWebViewPage.resolveUrl(
          widget.url,
          mobileVariant: widget.mobileVariant,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: widget.title,
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => _controller.reload(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: <Widget>[
            WebViewWidget(controller: _controller),
            if (_progress < 100)
              LinearProgressIndicator(
                value: _progress <= 0 ? null : _progress / 100,
                minHeight: 2,
                color: LightColor.secondaryColor,
                backgroundColor: LightColor.secondaryColor.withValues(
                  alpha: 0.10,
                ),
              ),
            if (_errorMessage case final message?)
              _WebViewError(message: message, onRetry: _controller.reload),
          ],
        ),
      ),
    );
  }
}

class _WebViewError extends StatelessWidget {
  const _WebViewError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      color: LightColor.background,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppDimens.paddingX24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.public_off_rounded,
            color: LightColor.secondaryTextColor,
            size: AppDimens.sizeX40,
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
