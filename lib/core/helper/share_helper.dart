import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:share_plus/share_plus.dart';

enum ShareOutcome {
  shared,

  dismissed,

  unknown,

  copiedToClipboard,

  nothingToShare,
}

abstract final class ShareHelper {
  static Future<ShareOutcome> share(
    BuildContext context, {
    String? message,
    String? link,
    String? subject,
    GlobalKey? originKey,
  }) async {
    final ShareParams? params = buildParams(
      message: message,
      link: link,
      subject: subject,
      origin: _originRect(originKey),
    );
    if (params == null) return ShareOutcome.nothingToShare;

    HapticFeedback.lightImpact();

    try {
      final ShareResult result = await SharePlus.instance.share(params);
      switch (result.status) {
        case ShareResultStatus.success:
          return ShareOutcome.shared;
        case ShareResultStatus.dismissed:
          return ShareOutcome.dismissed;
        case ShareResultStatus.unavailable:
          return ShareOutcome.unknown;
      }
    } catch (_) {
      // Nothing on the device can handle a share. Falling back to the
      // clipboard keeps the content reachable; a link-only share has no
      // `text`, so rebuild the string from what the caller gave us.
      final String fallback = _plainText(message: message, link: link);
      if (fallback.isEmpty) return ShareOutcome.nothingToShare;

      await Clipboard.setData(ClipboardData(text: fallback));
      if (context.mounted) {
        AppUtils().showSnackBar(
          context,
          MsgType.success,
          StringConstants.linkCopiedToClipboard,
        );
      }
      return ShareOutcome.copiedToClipboard;
    }
  }

  @visibleForTesting
  static ShareParams? buildParams({
    String? message,
    String? link,
    String? subject,
    Rect? origin,
  }) {
    final String body = (message ?? '').trim();
    final String url = (link ?? '').trim();
    final String? cleanSubject = (subject ?? '').trim().isEmpty
        ? null
        : subject!.trim();

    if (body.isEmpty) {
      if (url.isEmpty) return null;

      final Uri? uri = Uri.tryParse(url);
      // A Uri needs a scheme to be a link rather than a bare path; without one
      // the OS has nothing to hand off, so send it as text instead.
      if (uri != null && uri.hasScheme) {
        return ShareParams(
          uri: uri,
          subject: cleanSubject,
          title: cleanSubject,
          sharePositionOrigin: origin,
        );
      }
    }

    final String text = _plainText(message: message, link: link);
    if (text.isEmpty) return null;

    return ShareParams(
      text: text,
      subject: cleanSubject,
      title: cleanSubject,
      sharePositionOrigin: origin,
    );
  }

  static String _plainText({String? message, String? link}) {
    final String body = (message ?? '').trim();
    final String url = (link ?? '').trim();

    if (body.isEmpty) return url;
    if (url.isEmpty || body.contains(url)) return body;
    return '$body\n$url';
  }

  static Rect? _originRect(GlobalKey? key) {
    final RenderObject? renderObject = key?.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
}
