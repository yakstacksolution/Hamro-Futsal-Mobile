import 'package:flutter/widgets.dart';

/// Decides when an infinite list should ask for its next page.
///
/// A plain `extentAfter < threshold` check fires on *every* scroll
/// notification, and a freshly appended page emits one itself. On a list that
/// is short enough for the condition to stay true, each completed request
/// immediately triggers the next one — pages 1, 2, 3… in a second, with no
/// user action, until the server rate-limits (HTTP 429).
///
/// So a load is only asked for when all of these hold:
///  * the user actually scrolled forward (or finished a scroll), rather than
///    the list re-laying itself out,
///  * the viewport is near the end,
///  * nothing loaded in the last [cooldown].
class PaginationTrigger {
  PaginationTrigger({
    this.threshold = 260,
    this.cooldown = const Duration(milliseconds: 900),
  });

  /// How close to the end the viewport must be before the next page is asked
  /// for, in logical pixels.
  final double threshold;

  /// The quiet period after a load before another can be triggered.
  final Duration cooldown;

  DateTime? _lastRequestedAt;

  /// Whether [notification] should start the next page load.
  ///
  /// [canLoad] is the caller's own state — has more pages, not already
  /// loading, no error standing.
  bool shouldLoadMore(
    ScrollNotification notification, {
    required bool canLoad,
  }) {
    // Only a real scroll gesture asks for more. An update carrying no delta is
    // the list re-laying itself out — which is exactly what a freshly appended
    // page causes.
    final bool userScrolledForward =
        notification is ScrollUpdateNotification &&
        (notification.scrollDelta ?? 0) > 0;
    final bool settledAtEnd = notification is ScrollEndNotification;

    return allows(
      userDriven: userScrolledForward || settledAtEnd,
      extentAfter: notification.metrics.extentAfter,
      canLoad: canLoad,
    );
  }

  /// The decision itself, free of Flutter's notification types.
  bool allows({
    required bool userDriven,
    required double extentAfter,
    required bool canLoad,
    DateTime? now,
  }) {
    if (!canLoad || !userDriven) return false;
    if (extentAfter >= threshold) return false;

    final DateTime moment = now ?? DateTime.now();
    final DateTime? last = _lastRequestedAt;
    if (last != null && moment.difference(last) < cooldown) return false;

    _lastRequestedAt = moment;
    return true;
  }

  /// Called when a list is reset (a new search, a refresh) so the next page can
  /// be requested without waiting out the cooldown.
  void reset() => _lastRequestedAt = null;
}
