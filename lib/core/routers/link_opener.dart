import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/routers/deep_link_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens a URL the user tapped inside the app.
///
/// One rule, in one place: if the link is one of the app's own
/// (`hamrofutsal.com/venues/…`, `hamrofutsal://…`) it opens the screen behind
/// it without leaving the app; anything else goes to the browser. A shared
/// venue link is worth nothing if tapping it in a chat bounces the user out to
/// a web page they then have to find their way back from.
abstract final class LinkOpener {
  /// Returns true when the link was handled — in-app or by the browser.
  static Future<bool> open(Uri uri) async {
    if (DeepLinkService.instance.openInternal(uri)) return true;

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (error) {
      debugPrint('Could not open the tapped link $uri: $error');
      return false;
    }
  }
}
