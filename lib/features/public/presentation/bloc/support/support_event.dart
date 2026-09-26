part of 'support_bloc.dart';

sealed class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the FAQs from `GET /faqs`.
final class FetchFaqsEvent extends SupportEvent {
  const FetchFaqsEvent();
}

/// Loads the help topics from `GET /helps`.
final class FetchHelpsEvent extends SupportEvent {
  const FetchHelpsEvent();
}

/// Loads the video guides from `GET /youtube-videos`.
final class FetchVideosEvent extends SupportEvent {
  const FetchVideosEvent({this.isRefresh = false, this.completer});

  /// True for a pull-to-refresh, which keeps the current list visible.
  final bool isRefresh;

  /// Completed when the fetch finishes, success or not. Pull-to-refresh
  /// awaits this rather than a state change: an unchanged list emits an
  /// identical state that Bloc drops, and the spinner would never stop.
  final Completer<void>? completer;

  @override
  List<Object?> get props => <Object?>[isRefresh, completer];
}
