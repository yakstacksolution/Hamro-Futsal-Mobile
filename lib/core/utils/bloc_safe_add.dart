import 'package:flutter_bloc/flutter_bloc.dart';

/// Adding to a bloc that has already been closed throws
/// `Bad state: Cannot add new events after calling close`, which reaches the
/// zone as an unhandled error and is reported as a fatal crash.
///
/// It happens wherever a screen hands off — a dialog, a bottom sheet, a pushed
/// page, an API round-trip — and is disposed while that work is in flight: the
/// result comes back and asks a bloc that no longer exists to refresh.
/// `context.mounted` does not cover it, because the bloc is usually captured
/// before the await precisely to avoid using a stale context.
extension SafeBlocAdd<E, S> on Bloc<E, S> {
  /// Adds [event], or does nothing if this bloc has already been closed.
  ///
  /// A closed bloc has no listeners left to tell, so dropping the event is the
  /// correct outcome rather than a silent failure.
  void addIfOpen(E event) {
    if (isClosed) return;
    add(event);
  }
}
