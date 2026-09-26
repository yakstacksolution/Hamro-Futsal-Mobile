import 'package:flutter/foundation.dart';

/// Asks every live `ProfileBloc` to re-fetch `/auth/me`.
///
/// The profile bloc is provided per route (dashboard, profile), so a screen on
/// a route of its own — rewards, for one — has no bloc above it to talk to.
/// It calls [request] instead, and each bloc listening here refreshes.
abstract final class ProfileRefreshSignal {
  static final ValueNotifier<int> requests = ValueNotifier<int>(0);

  static void request() => requests.value++;
}
