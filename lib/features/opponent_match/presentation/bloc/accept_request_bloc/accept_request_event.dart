part of 'accept_request_bloc.dart';

sealed class AcceptRequestEvent extends Equatable {
  const AcceptRequestEvent();

  @override
  List<Object?> get props => [];
}

final class SubmitAcceptEvent extends AcceptRequestEvent {
  const SubmitAcceptEvent(this.request);
  final AcceptOpponentRequestRequest request;

  @override
  List<Object?> get props => [request];
}
