import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/routers/deep_link_service.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class LinkOpener {
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
