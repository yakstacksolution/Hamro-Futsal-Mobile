part of 'accept_request_bloc.dart';

sealed class AcceptRequestEvent extends Equatable {
  const AcceptRequestEvent();

  @override
  List<Object?> get props => [];
}

/// Places the accept hold for [teamId] and loads the advance quote + QR.
final class LoadAcceptQuoteEvent extends AcceptRequestEvent {
  const LoadAcceptQuoteEvent({required this.requestId, required this.teamId});
  final String requestId;
  final String teamId;

  @override
  List<Object?> get props => [requestId, teamId];
}

/// Submits the accept with the hold token and payment proof.
final class SubmitAcceptEvent extends AcceptRequestEvent {
  const SubmitAcceptEvent(this.request);
  final AcceptOpponentRequestRequest request;

  @override
  List<Object?> get props => [request];
}

/// Discards the current quote (hold expired / team changed).
final class ResetAcceptQuoteEvent extends AcceptRequestEvent {
  const ResetAcceptQuoteEvent();
}
