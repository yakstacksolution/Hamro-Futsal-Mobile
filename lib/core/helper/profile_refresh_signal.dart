import 'package:flutter/foundation.dart';

abstract final class ProfileRefreshSignal {
  static final ValueNotifier<int> requests = ValueNotifier<int>(0);

  static void request() => requests.value++;
}
