import 'package:flutter/material.dart';

abstract final class RootNavigatorKey {
  static final GlobalKey<NavigatorState> key = GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => key.currentState;
}
