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
