import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:share_plus/share_plus.dart';

/// What came back from a share attempt.
enum ShareOutcome {
  /// The user picked a target in the share sheet.
  shared,

  /// The sheet opened and the user backed out of it.
  dismissed,

  /// The sheet opened but the platform cannot report what happened
  /// (Android and macOS only say "an action was picked").
  unknown,

  /// No share sheet on this device, so the text went to the clipboard.
  copiedToClipboard,

  /// Nothing was passed that could be shared.
  nothingToShare,
}

/// The app's single entry point to the OS share sheet.
///
/// Everything that shares goes through here so pages cannot drift into
/// different behaviours, and so the parts that are easy to get wrong are
/// handled once:
///
/// * share_plus refuses `uri` and `text` together, and refuses empty text, so
///   the two shapes are chosen deliberately in [buildParams] rather than by
///   whatever the caller happens to have.
/// * iPad and macOS anchor the sheet to a source rect. Without one the popover
///   has nothing to point at, so callers pass the key of the button that was
///   tapped.
/// * A device with no share target at all (bare emulators, some Android TV
///   builds) throws instead of opening anything, so the content is copied to
///   the clipboard rather than leaving the tap looking broken.
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

  /// Chooses between the two share shapes share_plus supports.
  ///
  /// A bare link is sent as a [Uri], which is what makes iOS and the richer
  /// Android targets render a link preview card instead of pasting the raw
  /// characters. As soon as there is a message to go with it the link has to be
  /// folded into `text`, because share_plus rejects `uri` and `text` together.
  ///
  /// Returns null when there is nothing worth opening a sheet for. Kept
  /// separate from [share] so this decision is testable without a platform.
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

  /// [message] with [link] on its own line, skipping the link when the message
  /// already quotes it (the backend's `message` sometimes includes it).
  static String _plainText({String? message, String? link}) {
    final String body = (message ?? '').trim();
    final String url = (link ?? '').trim();

    if (body.isEmpty) return url;
    if (url.isEmpty || body.contains(url)) return body;
    return '$body\n$url';
  }

  /// The tapped widget's rect in global coordinates, or null when it is not
  /// laid out — every platform except iPad/macOS ignores this anyway.
  static Rect? _originRect(GlobalKey? key) {
    final RenderObject? renderObject = key?.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }
}
