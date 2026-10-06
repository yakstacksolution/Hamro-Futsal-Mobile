import 'package:flutter/widgets.dart';

class PaginationTrigger {
  PaginationTrigger({
    this.threshold = 260,
    this.cooldown = const Duration(milliseconds: 900),
  });

  final double threshold;

  final Duration cooldown;

  DateTime? _lastRequestedAt;

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

  void reset() => _lastRequestedAt = null;
}
