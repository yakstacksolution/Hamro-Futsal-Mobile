part of 'support_bloc.dart';

sealed class SupportEvent extends Equatable {
  const SupportEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchFaqsEvent extends SupportEvent {
  const FetchFaqsEvent();
}

final class FetchHelpsEvent extends SupportEvent {
  const FetchHelpsEvent();
}

final class FetchVideosEvent extends SupportEvent {
  const FetchVideosEvent({this.isRefresh = false, this.completer});

  final bool isRefresh;

  final Completer<void>? completer;

  @override
  List<Object?> get props => <Object?>[isRefresh, completer];
}
