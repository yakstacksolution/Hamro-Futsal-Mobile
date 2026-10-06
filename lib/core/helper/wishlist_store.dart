import 'package:flutter/foundation.dart';

class WishlistStore {
  WishlistStore._();

  static final WishlistStore instance = WishlistStore._();

  final ValueNotifier<Set<int>> ids = ValueNotifier<Set<int>>(<int>{});

  final Set<int> _pending = <int>{};

  void seed(List<int> venueIds) {
    final Set<int> next = <int>{...venueIds};
    for (final int pendingId in _pending) {
      if (ids.value.contains(pendingId)) {
        next.add(pendingId);
      } else {
        next.remove(pendingId);
      }
    }
    ids.value = next;
  }

  bool contains(int? venueId) => venueId != null && ids.value.contains(venueId);

  void toggleLocal(int venueId) {
    final Set<int> next = <int>{...ids.value};
    if (!next.remove(venueId)) next.add(venueId);
    ids.value = next;
  }

  void markPending(int venueId) => _pending.add(venueId);

  void clearPending(int venueId) => _pending.remove(venueId);

  void clear() {
    _pending.clear();
    ids.value = <int>{};
  }
}
